extends StaticBody2D
class_name WordleLane

var fading_from: float = -1.0
var fades_to: float = 2.0

func fade(force: bool):
	if fading_from >= 0.0:
		return
	fading_from = fades_to if force else 0.0
	for obj in get_children():
		if obj is CollisionPolygon2D or obj is CollisionPolygon2D:
			obj.disabled = true


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if fading_from < 0.0:
		return
	fading_from = clampf(fading_from + delta, 0.0, fades_to)
	$Cover.modulate = Color(1.0, 1.0, 1.0, 1.0 - (fading_from / fades_to))
	if fading_from >= fades_to:
		process_mode = Node.PROCESS_MODE_DISABLED
