extends Area2D
@export_storage var inside = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	WSClient.chat_message.connect(_on_message)
	$Label.visible = GameState.is_solved("arg")

func _on_body_entered(body):
	if body.name != "Player":
		return
	inside = true

func _on_body_exited(body):
	if body.name != "Player":
		return
	inside = false

func _on_message(content: String, is_voice: bool, uid: String) -> void:
	if inside and content.contains("AA") and GameState.is_step_solved("chessie_hi"):
		WSClient.emit_message_consumed(content)
		GameState.solve("arg")
		$Label.visible = true
