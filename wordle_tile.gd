extends Control
class_name WordleTile

var unknown_color = Color("#262626ee")
var gray_color = Color("#474747ee")
var yellow_color = Color("#b38639ee")
var green_color = Color("#539c3dee")

var colors = {
	"unknown": unknown_color,
	"gray": gray_color,
	"yellow": yellow_color,
	"green": green_color
}

var elapsed: float = -1.0
var duration: float = 0.25
var target_letter: String = "?"
var target_color: Color = unknown_color

func set_tile(letter: String, color: String):
	target_color = colors[color]
	target_letter = letter
	elapsed = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if elapsed < 0:
		return
	elapsed = clampf(elapsed + delta, 0, duration)
	var pct = elapsed / duration
	rotation_degrees = pct * 180
	if pct >= 0.5:
		rotation_degrees += 180
		$ColorRect.color = target_color
		$Label.text = target_letter
	if pct >= 1.0:
		elapsed = -1.0
