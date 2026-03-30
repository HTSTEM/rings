extends StaticBody2D

# collision logic in player.gd, notes & win logic in moons_ring.gd

# Called when the node enters the scene tree for the first time.
func _ready():
	if GameState.is_solved("music"):
		print("is solved mus")
		$Fader.fade(true)


func _process(delta):
	if GameState.is_solved("music"):
		$Fader.fade(false)
