extends CharacterBody2D

var debug_msg = ""
var base_speed = 1000
var t_last_collison: int = 0
var _base_directions: Dictionary[String, Vector2] = {
	"left": Vector2(-1.0, 0.0),
	"right": Vector2(1.0, 0.0),
	"up": Vector2(0.0, -1.0),
	"down": Vector2(0.0, 1.0)
}
var directions: Dictionary[String, Vector2] = {}
var other_animations: Array[String] = []
# avoid circulars (not actually sure if this is needed)
var randomizing_anim: bool = false
var tessie_on_ice: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	# load alt anims
	for x in $AnimatedSprite2D.sprite_frames.get_animation_names():
		if x == "default":
			continue
		other_animations.append(x)
	# load dirs
	for x in _base_directions:
		directions[x] = _base_directions[x]
		for i in range(len(x) - 1):
			i += 1
			var substr = x.substr(0, i)
			var pct: float = float(i) / float(len(x))
			directions[substr] = _base_directions[x] * pct
	# im listening
	WSClient.chat_message.connect(_on_chat_message)

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

func _on_chat_message(content: String, is_voice: bool, user_id: String):
	# speed boost for all caps lol
	var speed = base_speed
	for x in range(len(content)):
		if content[x] == content[x].to_upper():
			speed *= 1.1

	content = content.to_lower()
	
	if content not in directions:
		return

	var current_velocity = Vector2(velocity)
	var set_velocity = Vector2(directions[content]) * speed
	if tessie_on_ice: current_velocity = orthogonalize(current_velocity)
	if !tessie_on_ice || (tessie_on_ice && velocity.length() <= 0.1): velocity += set_velocity
	
	var max_x = maxf(abs(current_velocity.x), abs(set_velocity.x))
	velocity.x = clampf(velocity.x, -max_x, max_x)
	
	var max_y = maxf(abs(current_velocity.y), abs(set_velocity.y))
	velocity.y = clampf(velocity.y, -max_y, max_y)
	

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
	
	if !tessie_on_ice:
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

func _on_animated_sprite_2d_frame_changed():
	if $AnimatedSprite2D.frame == 15:
		# just some random safe point to reset this
		randomizing_anim = false
		return
	if randomizing_anim:
		return
	if $AnimatedSprite2D.frame != 8:
		return
	if $AnimatedSprite2D.animation != "default":
		randomizing_anim = true
		$AnimatedSprite2D.animation = "default"
		$AnimatedSprite2D.frame = 8
		return
	if (randi() % 10) != 0:
		return
	var new_animation = other_animations[randi() % len(other_animations)]
	randomizing_anim = true
	$AnimatedSprite2D.animation = new_animation
	$AnimatedSprite2D.frame = 8


func _on_ice_planet_body_entered(body: Node2D) -> void:
	if body.name != "Player":
		return
	tessie_on_ice = true


func _on_ice_planet_body_exited(body: Node2D) -> void:
	if body.name != "Player":
		return
	tessie_on_ice = false

func orthogonalize(v: Vector2):
	if abs(v.x) > abs(v.y):
		return Vector2(v.x, 0)
	else:
		return Vector2(0, v.y)
