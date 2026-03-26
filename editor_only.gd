@tool
extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready():
	if not Engine.is_editor_hint():
		visible = false
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
