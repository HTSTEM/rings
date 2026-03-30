extends RigidBody2D

# collision logic in player.gd

func _ready():
	pass

func _process(delta):
	pass

func collide() -> void:
	#var animateable = [$Sprite2D, $CollisionShape2D]
	var animateable = [$Sprite2D, $Col]
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	for item in animateable:
		tween.tween_property(item, "scale", Vector2(0.06,0.06), 2.4)
		#tween.tween_callback(self.queue_free).set_delay(5)
		
		GameState.success_and_save()
