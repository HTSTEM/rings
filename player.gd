extends CharacterBody2D

var debug_msg = ""
var base_speed = 1000
var t_last_collison: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	WSClient.chat_message.connect(_on_chat_message)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func _unhandled_key_input(event):
	if event is InputEventKey:
		if event.pressed:
			if event.keycode == KEY_CTRL:
				var pointer = get_global_mouse_position()
				velocity = pointer - self.global_position
			elif event.keycode == KEY_ESCAPE:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED) 
			elif event.keycode == KEY_ENTER:
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
		
	elif content == "clear":
		var vp_container = get_node("%SubViewportContainer")
		var tween = get_tree().create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN).set_parallel(false)
		tween.tween_property(vp_container.material, "shader_parameter/u_offset", -2.5, 2.7)
		tween.tween_callback(func(): vp_container.material.shader = preload("res://no_fx.gdshader"))
		tween.tween_method(func(val): vp_container.material.set_shader_parameter("progress", val), 0.0, 1.0, 2).set_delay(-.3)

func _physics_process(delta):
	# TODO: can i add these as colision shapes at runtime? doesnt matter too much
	var is_in_radius = (position.x * position.x) + (position.y * position.y) < (GameState.progression_radius * GameState.progression_radius)
	if not is_in_radius:
		if (velocity.x < 0 and position.x < 0) or (velocity.x > 0 and position.x > 0):
			velocity.x = 0
		if (velocity.y < 0 and position.y < 0) or (velocity.y > 0 and position.y > 0):
			velocity.y = 0
			
	var v_before = velocity
	
	move_and_slide()
	
	var t_current = Time.get_ticks_msec()
	
	# hack because godot doesnt tell the TutorialPlanet about this >.>
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		var normal = collision.get_normal()
		
		if t_current - t_last_collison < 100: return
		
		if collider.name == "TutorialPlanet":
			GameState.solve("tutorial")
			
		elif collider.name.begins_with("Moon_") && v_before.length() >= 3.0:
				velocity = v_before.bounce(normal) * 1.1
				velocity.clamp(Vector2(-35,35),Vector2(-35,35))
				collider.call("collide")
				
		elif collider.name == "UnoCard" && v_before.length() >= 3.0:
			if t_current - t_last_collison < 200: return
				# ^ very possibly unnecessary in prod but dev mouse ctrl is too fast
			collider = collider as StaticBody2D
			var offset = (collision.get_position() - collider.global_position)
			var impulse = (-v_before).bounce(normal).normalized() * v_before.length() * 0.7
			collider.call("apply_impulse", impulse, offset)
			velocity = 1.5 * v_before.bounce(normal)
			
			GameState.solve_step('uno_card_found')
			collider.call("collide")
			
		t_last_collison = t_current
	
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
