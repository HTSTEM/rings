extends Label

var fading_from: float = -1.0
var fades_to: float = 3.0

func fade(force: bool):
	if fading_from >= 0.0:
		return
	fading_from = fades_to if force else 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if fading_from >= 0.0:
		fading_from = minf(fading_from + delta, fades_to)
	var pct = fading_from / fades_to
	modulate = Color(1.0, 1.0, 1.0, pct)
	if pct >= 1.0:
		process_mode = Node.PROCESS_MODE_DISABLED
