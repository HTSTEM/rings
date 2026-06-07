extends Area2D
@onready var ui = $"../PuzzlesSprites"
@export_storage var inside: bool = 0
# gamestate ^  ?

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	WSClient.chat_message.connect(_on_message)
	for key in GameState.xword_words:
		if GameState.xword_words[key]:
			ui.display_pencil(key)

	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_body_entered(body):
	print("aaaa")
	if body.name != "Player":
		return
	ui.show_xword(GameState.is_step_solved("xword_solved"))
	inside = true

func _on_body_exited(body):
	if body.name != "Player":
		return
	ui.hide_xword()
	inside = false

func _on_message(content: String, is_voice: bool, uid: String):
	var original_content = content
	content = content.to_lower()
	if inside:
		if GameState.xword_words.has(content) && !GameState.xword_words[content]:
			WSClient.emit_message_consumed(original_content)
			GameState.xword_words[content] = 1
			ui.display_pencil(content)
			$"../AudioStreamPlayer".stream = preload("res://pencil_marks.mp3")
			$"../AudioStreamPlayer".play()
		#var count = words.values().reduce(func(datum): return datum==1,acc)
		# i fr must be stupid
		# ...
		# >>>another way of thinking about it is that reduce in GDScript silently
		# >    turns into foldl1 when Nothing is passed to foldl as the
		# >    initial value for the accumulator.
		# oh,,, ofc,.. ive been waiting for a language like this:fire::100:
		var count = len(GameState.xword_words.values().filter(func(__): return __))
		if count > 3 && !GameState.is_step_solved("xword_solved"):
			ui.show_xword(true)
			GameState.solve_step("xword_solved")
			$"../AudioStreamPlayer".stream = preload("res://stamp.mp3")
			$"../AudioStreamPlayer".play()
