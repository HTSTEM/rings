extends Area2D

var fading_from: float = -1.0
var fades_to: float = 2.0

# Called when the node enters the scene tree for the first time.
func _ready():
	if GameState.is_solved("wordle"):
		queue_free()
		return
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if fading_from < 0.0:
		return
	fading_from = clampf(fading_from + delta, 0, fades_to)
	$AnimatedSprite2D.modulate = Color(1.0, 1.0, 1.0, 1.0 - (fading_from / fades_to))
	if fading_from >= fades_to:
		GameState.solve("wordle")
		queue_free()
		return


func _on_body_entered(body):
	if body.name != "Player":
		return
	if fading_from >= 0.0:
		return
	fading_from = 0.0
