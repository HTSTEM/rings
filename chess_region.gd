extends Area2D
@onready var ui = $"../PuzzlesSprites"
@export_storage var inside = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	WSClient.chat_message.connect(_on_message)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_body_entered(body):
	if body.name != "Player":
		return
	ui.show_chess()
	inside = true

func _on_body_exited(body):
	if body.name != "Player":
		return
	ui.hide_chess()
	inside = false

func _on_message(content: String, is_voice: bool, uid: String) -> void:
	if inside && content == "Rh4#":
		ui.show_chess(true)
		GameState.solve_step("chess_solved")
		$"../AudioStreamPlayer".stream = preload("res://chess_move.mp3")
		$"../AudioStreamPlayer".play()
