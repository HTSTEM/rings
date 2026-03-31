extends ColorRect


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var mat: ShaderMaterial = self.material
	var player: CharacterBody2D = get_node("../../Level/Player")
	var collision: CollisionShape2D = player.get_node("CollisionShape2D")
	var shape: CircleShape2D = collision.shape
	mat.set_shader_parameter("radius", GameState.progression_radius + shape.radius)
	mat.set_shader_parameter("position", player.position)
