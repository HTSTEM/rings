@tool
extends Node2D

@export var radius: float = 100.0
@export var walls_count: int = 40
@export var wall_obj: StaticBody2D
@export_range(0, 360, 0.1, "radians_as_degrees") var cutout_start
@export var tessie_entrance_size: float = 20
var cutout_end
#@export_range(0, 360, 0.1, "radians_as_degrees") var cutout_end

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Engine.is_editor_hint():
		return
	#if cutout_start > cutout_end:
		#var temp = cutout_end
		#cutout_end = cutout_start
		#cutout_start = temp
	distribute(radius)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Engine.is_editor_hint(): return queue_redraw()


func distribute(rad: float, time: float = 0) -> void:
	cutout_end = cutout_start + 2*asin(tessie_entrance_size / (2*radius))
	for i in range(walls_count):
		var angle = (2 * PI * i) / walls_count
		if angle >= cutout_start && angle <= cutout_end:
			continue
		var x = cos(angle+time) * rad
		var y = sin(angle+time) * rad
		wall_obj.visible = true
		var new_wall = wall_obj.duplicate()
		new_wall.position = Vector2(x, y)
		new_wall.rotate(angle+PI/2)
		add_child(new_wall)
	wall_obj.queue_free()

func _draw() -> void:
	cutout_end = cutout_start + 2*asin(tessie_entrance_size / (2*radius))
	if !Engine.is_editor_hint(): return
	var xy_start = Vector2(cos(cutout_start) * radius,sin(cutout_start) * radius)
	var xy_end = Vector2(cos(cutout_end) * radius,sin(cutout_end) * radius)
	draw_line(xy_start,xy_end, Color.BLUE_VIOLET, 4)
