extends Node2D

class_name Fader

var fade_from: Node2D = null
var fade_to: Node2D = null
var fade_elapsed: float = -1.0
@export var fade_over: float = 2.0
var direction: int = 1

func fade(force: bool):
	direction = 1
	if fade_elapsed >= 0.0:
		return
	print("it's happening yeah")
	fade_elapsed = fade_over if force else 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	var children = get_children()
	for child in children:
		if child is Node2D:
			if not fade_from:
				fade_from = child
			else:
				fade_to = child
				break
	assert(fade_to != null)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if fade_from == null || fade_to == null:
		return
	if fade_elapsed >= 0.0:
		fade_elapsed = clampf(fade_elapsed + (delta * float(direction)), 0.0, fade_over)
	var amt = fade_elapsed / fade_over
	fade_from.modulate = Color(1, 1, 1, 1.0 - amt)
	fade_to.modulate = Color(1, 1, 1, amt)
