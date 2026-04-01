extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready():
	if GameState.is_solved("ice"):
		$Fader.fade(true)


func _process(delta):
	if GameState.is_solved("ice"):
		$Fader.fade(false)
