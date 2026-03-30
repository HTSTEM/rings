extends StaticBody2D

var velocity: Vector2 = Vector2.ZERO
var angular_velocity: float = 1.3
var initial: float = angular_velocity
var mass: float = 1.0
var drag: float = 0.3
var angular_drag: float = 0.9

func _process(delta: float) -> void:
	_physics_process(delta)

func apply_impulse(impulse: Vector2, offset: Vector2):
	velocity += impulse / mass

	var torque = clampf(offset.x * impulse.y - offset.y * impulse.x, -50, 50)
	print(torque)
	angular_velocity += torque / mass
	print(angular_velocity)

func _physics_process(delta):
	position += velocity * delta
	rotation += clampf(angular_velocity * delta, -1.5, 1.5) / 4
	velocity = velocity.lerp(Vector2.ZERO, drag * delta)
	angular_velocity = lerp(angular_velocity, initial, clampf(angular_drag * delta, 0.0, .02) / 3)

func collide() -> void:
	GameState.success_and_save()
	var animateable = [$Sprite2D, $CollisionShape2D]
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	for item in animateable:
		tween.tween_property(item, "scale", Vector2(0.06,0.06), 1.4)
		tween.tween_callback(self.queue_free).set_delay(5)
