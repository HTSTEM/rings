extends Node2D

@export var radius: float = 290.0
@export var speed: float = 0.04
var items: int
var elapsed: float
@export_storage var notes_inputted: String
@export var target: String = "CGGAGTT"
var correct_count = 0
var last_c_c = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	items = get_child_count()
	if GameState.is_solved("music"):
		speed = 0.04 * 8
	distribute(radius)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	elapsed += delta*speed
	distribute(radius, elapsed)
	

func distribute(rad: float, time: float = 0) -> void:
	for i in range(items):
		var angle = (2 * PI * i) / items
		var x = cos(angle+time) * rad
		var y = sin(angle+time) * rad
		get_child(i).position = Vector2(x, y)
		

func update_notes(letter: String) -> void:
	if GameState.is_solved("music"):
		speed = 0.04 * 8
		return
	notes_inputted += letter
	if notes_inputted.length() > 7:
		notes_inputted = notes_inputted.substr(1)
	correct_count = 0
	for i in range(target.length(), 0, -1):
		if notes_inputted.ends_with(target.substr(0, i)):
			correct_count = i
			break

	if correct_count == target.length():
		GameState.solve("music")
	
	# TODO: remove
	$"../Label".text = notes_inputted
	$"../Label2".text = str(correct_count)
	
	speed = 0.04 * (correct_count+1)
	if last_c_c < correct_count:
		anim_correct_note()
		print("+2 buddy you earned it")
		
	last_c_c = correct_count

func anim_correct_note() -> void:
	var animateable = [$"../Fader", $"../CollisionShape2D", $"../Sprite2D"]
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT).set_parallel(true)
	for item in animateable:
		tween.tween_property(item, "scale", Vector2(.9,.9), 0.3)
		tween.tween_property(item, "scale", Vector2(0.71,0.71), 0.2).set_delay(.3)
	
