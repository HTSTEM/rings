extends Node2D

@export var item: String = "text"
@export var texture: Texture2D
@export var offset: float = 0.0
var sprite: Sprite2D

func update_label():
	var next_cost = GameState.clicker_next_cost[item]
	$GleepGlorp/Label.text = "[%d⭐] \"Buy %s Poster\"" % [next_cost, GameState.clicker_names[item]]
	if GameState.clicker_clicks >= next_cost:
		$GleepGlorp/Label.remove_theme_color_override("font_color")
		$GleepGlorp/Label.add_theme_color_override("font_color", Color("#76e85e"))
	else:
		$GleepGlorp/Label.remove_theme_color_override("font_color")
		$GleepGlorp/Label.add_theme_color_override("font_color", Color("#e85f5f"))

# Called when the node enters the scene tree for the first time.
func _ready():
	sprite = Sprite2D.new()
	sprite.texture = texture
	sprite.scale = Vector2(0.5, 0.5)
	sprite.position = Vector2(20.0, 90.0)
	$GleepGlorp.add_child(sprite)
	update_label()
	$GleepGlorp/AnimationPlayer.seek(offset)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update_label()
