extends ColorRect


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var mat: ShaderMaterial = self.material
	var player: CharacterBody2D = get_node("/root/World/Level/Player")
	var sprite: Sprite2D = player.get_node("Sprite2D")
	mat.set_shader_parameter("radius", GameState.progression_radius + (sprite.get_rect().size.x * sprite.scale.x * 0.5))
	mat.set_shader_parameter("position", player.position)
