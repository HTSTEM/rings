extends Node2D


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if GameState.is_solved("arg"):
		queue_free()
