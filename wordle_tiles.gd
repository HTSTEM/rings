extends HBoxContainer

var max_since_guess = 1.0
var since_guess = 1.0
var max_since_solve = 5.0
var since_solve = max_since_solve
var word_regex = RegEx.create_from_string("^[A-Z]{5}$")
var words: Array[String] = []
var goal_words: Array[String] = [
	"STEAM",
	"ARENA",
	"RHYME",
	"SNOOT",
	"RINGS"
]
var requirements: Array[int] = [3, 2, 1, 4, 5]
var current_index: int = 0
var current_word: String = goal_words[current_index]
var guessed_word: String = "?????"
@onready var lanes = range(5).map(get_wordle_lane)

func get_wordle_lane(idx: int) -> WordleLane:
	return get_node("../").find_child("WordleLane%s" % ("" if idx == 0 else str(idx + 1)))

# Called when the node enters the scene tree for the first time.
func _ready():
	WSClient.chat_message.connect(_on_message)
	
	var file = FileAccess.open("res://valid_wordle_words.txt", FileAccess.READ)
	while file.get_position() < file.get_length():
		var content = file.get_line().strip_edges().to_upper()
		words.append(content)
	file.close()
	
	while GameState.is_step_solved("wordle%d" % current_index):
		lanes[current_index].fade(true)
		current_index += 1
		if current_index >= len(goal_words):
			for i in range(len(current_word)):
				var tile: WordleTile = get_child(i)
				var chr = current_word[i]
				tile.set_tile(chr, "green")
			# process_mode = Node.PROCESS_MODE_DISABLED
			break
		current_word = goal_words[current_index]

func _on_message(content: String, is_voice: bool, user_id: String):
	var original_content = content
	if current_index >= len(goal_words):
		return
	if since_guess < max_since_guess:
		return
	if since_solve < max_since_solve:
		return
	content = content.to_upper()
	if content == guessed_word:
		return
	var reg_match = word_regex.search(content)
	if reg_match == null:
		return
	if content not in words:
		return
	
	since_guess = 0
	guessed_word = content
	WSClient.emit_message_consumed(original_content)
	
	var remaining_word: String = current_word
	# greens
	for x in range(len(remaining_word)):
		var guess_letter = guessed_word[x]
		if remaining_word[x] == guess_letter:
			if len(GameState._planets_solved) >= requirements[x]:
				get_child(x).set_tile(guess_letter, "green")
			remaining_word[x] = "?"
			guessed_word[x] = "!"
	if guessed_word == "!!!!!":
		if current_index == (len(goal_words) - 1):
			# force show all letters at the end
			for i in range(len(current_word)):
				var tile: WordleTile = get_child(i)
				var chr = current_word[i]
				tile.set_tile(chr, "green")
		since_solve = 0.0
		lanes[current_index].fade(false)
		GameState.solve_step("wordle%d" % current_index)
		GameState.success_and_save()
		return
	# yellows
	for x in range(len(guessed_word)):
		# ignore already guessed letters
		if remaining_word[x] == "?":
			continue
		# find a matching letter
		var letter = guessed_word[x]
		if letter == "!":
			continue # !?
		for y in range(len(remaining_word)):
			if letter == remaining_word[y]:
				if len(GameState._planets_solved) >= requirements[x]:
					get_child(x).set_tile(letter, "yellow")
				remaining_word[y] = "?"
				guessed_word[x] = "!"
	# grays
	for x in range(len(guessed_word)):
		# ignore already guessed letters
		if guessed_word[x] == "!":
			continue
		if len(GameState._planets_solved) >= requirements[x]:
			get_child(x).set_tile(guessed_word.substr(x, 1), "gray")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if since_guess < max_since_guess:
		since_guess = minf(since_guess + delta, max_since_guess)
	if since_solve < max_since_solve:
		since_solve = minf(since_solve + delta, max_since_solve)
		if since_solve >= max_since_solve:
			current_index += 1
			if current_index >= len(goal_words):
				# process_mode = Node.PROCESS_MODE_DISABLED
				return
			current_word = goal_words[current_index]
			for i in range(len(current_word)):
				var tile: WordleTile = get_child(i)
				var chr: String = "?"
				tile.set_tile(chr, "unknown")
