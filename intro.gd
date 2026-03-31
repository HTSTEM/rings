extends Node2D

@onready var guy = preload("res://intro_guy.tscn")
var guys: Array[String] = []
var remaining: float = 10.0
var particles_at: float = 5.0
var rocket_terminal_speed: float = 10.0
var rocket_speed: float = 1.0
var rocket_velocity: float = 0.0
var animating: bool = false

func _ready():
	# IDK why these are being weird
	$TextBG.visible = false
	$VBoxContainer.visible = false
	$WorldPreview.visible = false
	$SubViewportContainer.visible = false
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)


func spawn_guy():
	var new_guy = guy.instantiate()
	$CameraFeed.add_sibling(new_guy)

func on_message(content: String, is_voice: bool, user_id: String):
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
	
	$RocketShip/GPUParticles2D.emitting = remaining < particles_at
	
	if remaining < 0.0:
		rocket_velocity = minf(rocket_terminal_speed, rocket_velocity + (rocket_speed * delta))
		$RocketShip.position.y = maxf(-100, $RocketShip.position.y - rocket_velocity)
	
	if remaining < -4.0:
		animating = true
		$AnimationPlayer.play("intro")

func clear_filter() -> void:
	GameState.solve_step('clear_filter')
	var vp = %WorldPreview
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN).set_parallel(false)
	tween.tween_property(vp.material, "shader_parameter/u_offset", -2.5, 2.7)
	tween.tween_callback(func(): vp.material.shader = preload("res://no_fx.gdshader"))
	tween.tween_method(func(val): vp.material.set_shader_parameter("progress", val), 0.0, 1.0, 2).set_delay(2)
