extends Area2D
@onready var ui = $"../PuzzlesSprites"
@export_storage var inside: bool = 0
@export var words: Dictionary[String, int] = {
"antidisestablishmentarianism": 0,
"tessie": 0,
"htstem": 0,
"hans": 0,
"lemxiqixils": 0,
"donottypemenotarealword": 0,
"glorpglorpglorp": 0,
"thankyoucatie": 0,
"thankyougizmote": 0,
"shoutoutstosimpleflips": 0,
"accordingtoallknownlaws...": 0,
"ringringringring": 0,
"owo": 0,
"pickupthephone": 0,
}
# gamestate ^  ?

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	WSClient.chat_message.connect(_on_message)

	
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
	content = content.to_lower()
	if inside:
		if words.has(content) && !words[content]:
			words[content] = 1
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
		var count = len(words.values().filter(func(__): return __))
		if count > 3 && !GameState.is_step_solved("xword_solved"):
			ui.show_xword(true)
			GameState.solve_step("xword_solved")
			$"../AudioStreamPlayer".stream = preload("res://stamp.mp3")
			$"../AudioStreamPlayer".play()
