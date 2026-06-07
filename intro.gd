class_name IntroPlayer
extends Node2D

@onready var guy = preload("res://intro_guy.tscn")
var guys: Array[String] = []
var remaining: float = 15.0
var particles_at: float = 10.0
var rocket_terminal_speed: float = 10.0
var rocket_speed: float = 1.0
var rocket_velocity: float = 0.0
var animating: bool = false
var clearing: bool = false
var since_rocket_sfx: float = 0.0
var lowering_rocket_sfx: bool = false

func fade_in_game():
	GameState.solve_step('clear_filter')
	print("i'm fading out")
	# it's time to leave this cruel world
	var subview = $SubViewportContainer/SubViewport
	var world = $SubViewportContainer/SubViewport/World
	world.fade_in()
	subview.remove_child(world)
	get_tree().change_scene_to_node(world)

func _ready():
	# IDK why these are being weird
	$TextBG.visible = false
	$VBoxContainer.visible = false
	$WorldPreview.visible = false
	$SubViewportContainer.visible = false
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	
	if GameState.is_step_solved("clear_filter"):
		fade_in_game()
		return
	
	var one_hour: float = 60.0 * 60.0
	#remaining = one_hour - fmod(Time.get_unix_time_from_system(), one_hour)
	
	$IntroMusicPlayer.play()


func spawn_guy():
	var new_guy = guy.instantiate()
	$CameraFeed.add_sibling(new_guy)

func on_message(content: String, is_voice: bool, user_id: String):
	if content.to_lower() == "take control":
		if $TakeControlText.modulate.a <= 0.0:
			return
		clear_filter()
		return
	if user_id in guys:
		return
	guys.append(user_id)
	spawn_guy()

func _unhandled_key_input(event):
	if event is InputEventKey:
		if event.pressed:
			if event.keycode == KEY_SPACE:
				spawn_guy()
			# TODO: Move out of intro to whereever is best
			# and add 'enter' chat trigger to replace dev key triggers
			elif event.keycode == KEY_BACKSPACE:
				clear_filter()
			if !GameState.is_step_solved('clear_filter'):
				get_viewport().set_input_as_handled()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	remaining -= delta

	var total_seconds = absi(ceili(remaining))
	var remaining_sec = total_seconds % 60
	var remaining_min = floori(floor(total_seconds) / 60.0)
	var remaining_sign = "+" if signf(remaining) < 0.0 else "-"
	$Label.text = "T%s%02d:%02d" % [remaining_sign, remaining_min, remaining_sec]
	
	if animating:
		return
	
	if remaining < particles_at:
		$RocketShip/GPUParticles2D.emitting = true
		since_rocket_sfx += delta
		if since_rocket_sfx > 0.1:
			$RocketPlayer.play()
			since_rocket_sfx = 0
	
	if remaining < 0.0:
		rocket_velocity = minf(rocket_terminal_speed, rocket_velocity + (rocket_speed * delta))
		$RocketShip.position.y = maxf(-100, $RocketShip.position.y - rocket_velocity)
		if not lowering_rocket_sfx:
			lowering_rocket_sfx = true
			var tween = get_tree().create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT).set_parallel(false)
			tween.tween_property($RocketPlayer, "volume_db", -25.0, 3.5).set_delay(0.5)
	
	if remaining < -4.0:
		animating = true
		$AnimationPlayer.play("intro")

func clear_filter() -> void:
	if clearing:
		return
	clearing = true
	$AnimationPlayer.stop(true)
	var vp = %WorldPreview
	var parallel_tween = get_tree().create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN).set_parallel(true)
	parallel_tween.tween_property($TakeControlText, "modulate", Color(1.0, 1.0, 1.0, 0.0), 2.0)
	parallel_tween.tween_property($TakeControlText2, "modulate", Color(1.0, 1.0, 1.0, 0.0), 2.0)
	parallel_tween.tween_property($IntroMusicPlayer, "volume_db", -50.0, 4.0)
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN).set_parallel(false)
	tween.tween_property(vp.material, "shader_parameter/u_offset", -2.5, 2.0)
	tween.tween_property($IntroFadeOut, "modulate", Color(1.0, 1.0, 1.0, 1.0), 2)
	tween.tween_callback(fade_in_game)
	#tween.tween_callback(func():
		#vp.material.shader = preload("res://no_fx.gdshader")
		#vp.material.set_shader_parameter("progress", 1.0)
	#)
	#tween.tween_method(func(val): vp.material.set_shader_parameter("progress", val), 0.0, 1.0, 2).set_delay(2)
