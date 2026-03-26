extends CharacterBody2D

var debug_msg = ""
var base_speed = 1000

# Called when the node enters the scene tree for the first time.
func _ready():
	WSClient.chat_message.connect(_on_chat_message)

func _unhandled_key_input(event):
	if event is InputEventKey:
		if event.pressed:
			if event.keycode == KEY_ENTER:
				WSClient.emit_message(debug_msg)
				debug_msg = ""
			elif event.keycode == KEY_BACKSPACE:
				if len(debug_msg) == 1:
					debug_msg = ""
				elif len(debug_msg) > 1:
					debug_msg = debug_msg.substr(0, len(debug_msg) - 1)
			elif event.keycode >= KEY_SPACE && event.keycode <= KEY_SECTION:
				var keycode = char(event.unicode)
				debug_msg += keycode
			
			var cmd = get_node("DebugCommand")
			cmd.text = debug_msg

func _on_chat_message(content: String, is_voice: bool):
	# speed boost for all caps lol
	var speed = base_speed
	if content == content.to_upper():
		speed += 1
	
	content = content.to_lower()
	if content == "up":
		velocity.y = -speed
	elif content == "down":
		velocity.y = speed
	elif content == "left":
		velocity.x = -speed
	elif content == "right":
		velocity.x = speed

func _physics_process(delta):
	# TODO: can i add these as colision shapes at runtime? doesnt matter too much
	var is_in_radius = (position.x * position.x) + (position.y * position.y) < (GameState.progression_radius * GameState.progression_radius)
	if not is_in_radius:
		if (velocity.x < 0 and position.x < 0) or (velocity.x > 0 and position.x > 0):
			velocity.x = 0
		if (velocity.y < 0 and position.y < 0) or (velocity.y > 0 and position.y > 0):
			velocity.y = 0
	
	move_and_slide()
	
	# hack because godot doesnt tell the TutorialPlanet about this >.>
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider().name == "TutorialPlanet":
			GameState.solve("tutorial")
	
	var drag = base_speed
	
	if velocity.x < 0:
		velocity.x = min(0, velocity.x + (delta * drag))
	elif velocity.x > 0:
		velocity.x = max(0, velocity.x - (delta * drag))
		
	if velocity.y < 0:
		velocity.y = min(0, velocity.y + (delta * drag))
	elif velocity.y > 0:
		velocity.y = max(0, velocity.y - (delta * drag))
	
	var sprite: AnimatedSprite2D = get_node("AnimatedSprite2D")
	sprite.speed_scale = 1 + (max(abs(velocity.x), abs(velocity.y)) / base_speed * 5)
