extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for item in get_children(true):
		item.visible = false
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func show_xword(solved: bool = false) -> void:
	$xword.visible = true
	$xword/XwordFinished.visible = solved

func hide_xword() -> void:
	$xword.visible = false

func display_pencil(word: String) -> void:
	var mark = get_node("xword/{0}".format([word]))
	mark.visible = true
	mark.modulate.a = 0
	get_tree().create_tween().tween_property(mark, "modulate:a", 1.0, .3)

func show_chess(solved: bool = false, secret: bool = false) -> void:
	$chess.visible = true
	$chess/ChessFinished.visible = solved
	$chess/ChessFinished/Label.visible = secret

func hide_chess() -> void:
	$chess.visible = false
