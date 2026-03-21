extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	var ws = get_node("/root/WSClient")
	ws.chat_message.connect(_on_chat_message)
	pass # Replace with function body.

func _on_chat_message(content: String, is_voice: bool):
	content = content.to_lower()
	if content == "up":
		position.y += 10
	elif content == "down":
		position.y -= 10
	elif content == "left":
		position.x -= 10
	elif content == "right":
		position.x += 10
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
