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
