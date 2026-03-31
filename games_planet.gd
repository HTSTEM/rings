extends StaticBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if GameState.is_step_solved("uno_solved") && GameState.is_step_solved("xword_solved") && \
	GameState.is_step_solved("chess_solved") && !GameState.is_solved("games"):
		
		GameState.solve('games')
		print('yayay')
