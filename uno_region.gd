extends Area2D

@export_storage var inside: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	WSClient.chat_message.connect(_on_message)
	$"../UnoCard".visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$"../UnoCard".visible = GameState.is_step_solved('uno_card_found')


func _on_body_entered(body):
	if body.name != "Player":
		return
	inside = true

func _on_body_exited(body):
	if body.name != "Player":
		return
	inside = false


func _on_message(content: String, is_voice: bool):
	if content.to_lower() == "uno"  && inside && !GameState.is_step_solved("uno_solved") && \
	GameState.is_step_solved("uno_card_found"):
		
		var cardsprite = $"../UnoCard/Sprite2D"
		GameState.solve_step("uno_solved")
		var tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT).set_parallel(true)
		tween.tween_property(cardsprite, "rotation", 0.0, 0.7)
		tween.tween_property(cardsprite, "position", Vector2(0.0,0.0), 1.0)
		$"../AudioStreamPlayer".stream = preload("res://card_rustle.mp3")
		$"../AudioStreamPlayer".play()
