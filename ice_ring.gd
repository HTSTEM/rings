extends Area2D

# Called when the node enters the scene tree for the first time.
func _ready():
	if GameState.is_solved("ice"):
		queue_free()
		return


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body):
	if body.name != "Player":
		return
	GameState.solve("ice")
	queue_free()
