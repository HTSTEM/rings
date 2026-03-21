extends Node2D

var debug_msg = ""
var velocity = Vector2(0, 0)

# Called when the node enters the scene tree for the first time.
func _ready():
	var ws = get_node("/root/WSClient")
	ws.chat_message.connect(_on_chat_message)
	pass # Replace with function body.

func _unhandled_key_input(event):
	if event is InputEventKey:
		if event.pressed:
			if event.keycode == KEY_ENTER:
				var ws = get_node("/root/WSClient")
				ws.emit_message(debug_msg)
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
	var bonus = 0
	if content == content.to_upper():
		bonus = 2
	
	content = content.to_lower()
	if content == "up":
		velocity.y = -8 - bonus
	elif content == "down":
		velocity.y = 8 + bonus
	elif content == "left":
		velocity.x = -8 - bonus
	elif content == "right":
		velocity.x = 8 + bonus

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position.x += velocity.x
	position.y += velocity.y
	#velocity.x -= (velocity.x * 0.95 * delta)
	#velocity.y -= (velocity.y * 0.95 * delta)
	#velocity -= velocity * 0.9999 * delta
	var drag = 7
	
	if velocity.x < 0:
		velocity.x = min(0, velocity.x + (delta * drag))
	elif velocity.x > 0:
		velocity.x = max(0, velocity.x - (delta * drag))
		
	if velocity.y < 0:
		velocity.y = min(0, velocity.y + (delta * drag))
	elif velocity.y > 0:
		velocity.y = max(0, velocity.y - (delta * drag))
	pass
