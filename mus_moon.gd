extends StaticBody2D
@onready var player = $"../../AudioStreamPlayer"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func collide() -> void:
	var note_name = str(self.name)[-1]
	get_parent().call("update_notes", note_name)
	player.stream = preload("res://floraphonic-glass-clink-2-184006.mp3")
	match note_name:
		"C":
			#get_parent().call("update_notes", "G")
			#get_parent().call("update_notes", "G")
			#get_parent().call("update_notes", "A")
			#get_parent().call("update_notes", "G")
			#get_parent().call("update_notes", "T")
			player.pitch_scale = 1.2
		"B":
			player.pitch_scale = 0.95
		"A":
			player.pitch_scale = 0.67
		"G":
			player.pitch_scale = 0.59
		"T":
			player.stream = preload("res://metal-thud_Gyr48iN__NWM.mp3")
			player.pitch_scale = 1
	player.play()
