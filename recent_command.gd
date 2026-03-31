extends Node2D

var target_y: float = 35
var animate_for: float = 0.5
var elapsed: float = 0.0
var die_at: float = 5.0
var die_for: float = 1.0

func set_text(text: String):
	$Label.text = text

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	elapsed += delta
	var since_die = elapsed - die_at
	if since_die < 0.0:
		var eased = ease(clampf(elapsed / animate_for, 0.0, 1.0), 0.6)
		position.y = lerpf(0.0, -target_y, eased)
		$Label.modulate.a = lerpf(0.0, 1.0, eased) # i know this lerp is useless but its easier to read
	else:
		var eased = ease(clampf(since_die / animate_for, 0.0, 1.0), 2)
		$Label.modulate.a = lerpf(1.0, 0.0, eased)
		
		if since_die >= die_for:
			queue_free()
