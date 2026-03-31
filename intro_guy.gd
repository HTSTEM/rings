extends AnimatedSprite2D

var factor: int = 8
var left_spawn: int = 64
var right_spawn: int = 1344
var real_position: Vector2 = Vector2(0.0, 0.0)
var min_x: int = 280
var max_x: int = 1140
var walking_in: bool = true
var walking_towards: int = 1
var walking_for: float = 0.0
var waiting_for: float = 0.0
var speed = 40

# Called when the node enters the scene tree for the first time.
func _ready():
	var x: int
	if randf() < 0.5:
		x = left_spawn
		walking_towards = 1
	else:
		x = right_spawn
		walking_towards = -1
	real_position = Vector2(float(x), 816.0)


func update_position(delta: float):
	var movement_delta = walking_towards * speed * delta
	
	if walking_in:
		real_position.x += movement_delta
		if real_position.x > min_x and real_position.x < max_x:
			walking_in = false
			walking_for = 0.5 + (randf() * 3)
		else:
			return
	
	if walking_for > 0.0:
		walking_for = maxf(0.0, walking_for - delta)
		real_position.x = clampf(real_position.x + movement_delta, min_x, max_x)
		
		if walking_for <= 0.0 or real_position.x <= min_x or real_position.x >= max_x:
			walking_for = 0.0
			waiting_for = 1.0 + (randf() * 2)
			frame = 0
		return
	
	if waiting_for > 0.0:
		waiting_for = maxf(0.0, waiting_for - delta)
		
		if waiting_for <= 0.0:
			walking_for = 2.0 + (randf() * 2.5)
			if abs(real_position.x - min_x) < 40:
				walking_towards = 1
			elif abs(max_x - real_position.x) < 40:
				walking_towards = -1
			elif randf() < 0.5:
				walking_towards = 1
			else:
				walking_towards = -1
		return

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update_position(delta)
	var new_position = Vector2(round(real_position.x / 8) * 8, round(real_position.y / 8) * 8)
	if new_position.x != position.x:
		frame = (frame + 1) % 2
	position = new_position
