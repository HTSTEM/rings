extends StaticBody2D


func check(force: bool):
	if len(GameState._planets_solved) > 0 or GameState.is_solved("riddle"):
		$VBoxContainer/Label0.fade(force)
	if len(GameState._planets_solved) > 1 or GameState.is_solved("riddle"):
		$VBoxContainer/Label1.fade(force)
	if len(GameState._planets_solved) > 2 or GameState.is_solved("riddle"):
		$VBoxContainer/Label2.fade(force)
	if len(GameState._planets_solved) > 3 or GameState.is_solved("riddle"):
		$VBoxContainer/Label3.fade(force)
	if GameState.is_solved("riddle"):
		$VBoxContainer/LabelX.fade(force)


func _ready():
	check(true)
	WSClient.chat_message.connect(_on_message)

func _on_message(content: String, is_voice: bool, user_id: String):
	if not is_voice:
		return
	var original_content = content
	content = content.to_lower().strip_edges()
	if content != "cucumber":
		return
	WSClient.emit_message_consumed(original_content)
	GameState.solve("riddle")

func _process(delta):
	check(false)
	pass
