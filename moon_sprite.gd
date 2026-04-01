extends Sprite2D


func _process(delta):
	# i tried to make this Area2D based but godot was firing the events once ever then dying so i gave up
	z_index = 2 if get_node("../../").position.y >= -10 else 0
	$Sprite2D.modulate.a = lerpf(0.0, 0.75, clampf(float(len(GameState._planets_solved)) / float(len(GameState.all_planets) - 1), 0.0, 1.0))
