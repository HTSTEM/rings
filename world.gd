extends Node

func fade_in():
	print("i'm fading in too")
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN).set_parallel(false)
	$UI/IntroFadeIn.modulate = Color(1.0, 1.0, 1.0, 1.0)
	tween.tween_property($UI/IntroFadeIn, "modulate", Color(1.0, 1.0, 1.0, 0.0), 3).set_delay(2)
	tween.tween_callback(func (): $MainMusic.play())

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
