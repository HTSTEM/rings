extends Node2D

var debug_msg = ""

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
			else:
				# todo: do there need to be filters here for sane characters?
				debug_msg += OS.get_keycode_string(event.get_keycode_with_modifiers())
			
			var cmd = get_node("DebugCommand")
			cmd.text = debug_msg

func _on_chat_message(content: String, is_voice: bool):
	content = content.to_lower()
	if content == "up":
		position.y -= 10
	elif content == "down":
		position.y += 10
	elif content == "left":
		position.x -= 10
	elif content == "right":
		position.x += 10

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
