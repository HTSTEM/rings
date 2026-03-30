extends StaticBody2D

# actual logic for solving is in player.gd this is just dummy for updating the fade

func _ready():
	if GameState.is_solved("tutorial"):
		print("is solved tutorial")
		$Fader.fade(true)


func _process(delta):
	if GameState.is_solved("tutorial"):
		$Fader.fade(false)
