extends Control

var animation_elapsed: float = 0.0
@export var animates_for: float = 3.0

# Called when the node enters the scene tree for the first time.
func _ready():
	if len(GameState._planets_solved) > 0:
		animation_elapsed = animates_for
	else:
		modulate = Color(1, 1, 1, 0)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var solved = len(GameState._planets_solved)
	if solved < 1:
		return
	$Label.text = "%d" % solved
	animation_elapsed = min(animation_elapsed + delta, animates_for)
	modulate = Color(1, 1, 1, animation_elapsed / animates_for)
