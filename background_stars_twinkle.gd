extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var noise_texture: NoiseTexture2D = texture
	var noise: FastNoiseLite = noise_texture.noise
	var amt = delta * 10
	noise.offset.x += amt
	noise.offset.y += amt
	noise.offset.z += amt
	pass
