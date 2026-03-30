@tool
extends Node2D

@export var radius: float = 20.0
@export var height: float = 100.0
@export var width: float = 2.0
@export var color: Color

func _process(delta):
	if Engine.is_editor_hint():
		queue_redraw()

func _draw():
	var half_height = height / 2.0
	var center_left = Vector2(-half_height + radius, 0)
	var center_right = Vector2(half_height - radius, 0)

	var top_y = -radius
	var bottom_y = radius

	draw_line(Vector2(center_left.x, top_y),Vector2(center_right.x, top_y),color,width)

	draw_line(Vector2(center_left.x, bottom_y),Vector2(center_right.x, bottom_y),color,width)

	draw_arc(center_left,radius,PI/2,3*PI/2,32,color,width)

	draw_arc(center_right,radius,-PI/2, PI/2,32,color,width)
