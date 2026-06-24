extends StaticBody2D

var fn_prefix = "f(x)="
var alt_fn_prefix = "y="
var target_expressions = [
	["2x^2-10x+5","5-10x+2x^2"],
	["sqrt(abs(x))", "sqrt(|x|)"]
]
var whitespace = RegEx.create_from_string("\\s+")
var available_level: int = 0
var current_level: int = 0
var previous_result: float = 0.0
var riddle: float = 0.0

func handle_input(value: String, is_voice: bool, user_id: String):
	if value.strip_edges().to_lower() == "f(x)=cucumber":
		riddle = 10.0
		WSClient.emit_message_consumed(value)
		$Label.text = "Tell Chessie hi for me!"
		return
	
	if GameState.is_solved("math%d" % current_level):
		return

	var original_content = value

	var label: Label = get_node("Label")
	value = value.to_lower()
	value = whitespace.sub(value, "", true)
	while value.begins_with("$"):
		value = value.substr(1)
	while value.ends_with("$"):
		value = value.substr(0, len(value) - 1)
	if value.begins_with(fn_prefix):
		value = value.substr(len(fn_prefix))
	if value.begins_with(alt_fn_prefix):
		value = value.substr(len(alt_fn_prefix))
	value = value.substr(0, 20)
	
	if value.is_valid_float():
		var as_float = value.to_float()
		if as_float > 10000000 or as_float < -10000000 or is_nan(10000000):
			return
		WSClient.emit_message_consumed(original_content)
		var x = roundf(value.to_float() * 10.0) / 10.0
		var result = ((2 * pow(x, 2)) - (10 * x) + 5) if current_level == 0 else sqrt(abs(x))
		previous_result = result
		label.text = "f(%.1d)=%.1d" % [x, result]
	# TODO: tokenize?
	elif value in target_expressions[current_level]:
		WSClient.emit_message_consumed(original_content)
		GameState.solve("math%d" % current_level)
		$Fader.fade(false)
		label.text = (fn_prefix if current_level != 1 else "") + target_expressions[current_level][0]
	else:
		label.text = "f(x)≠" + value


# Called when the node enters the scene tree for the first time.
func _ready():
	WSClient.chat_message.connect(handle_input)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	riddle -= delta
	available_level = 0
	if len(GameState._planets_solved) > 3:
		available_level += 1
	var is_solved = GameState.is_solved("math%d" % current_level)
	if is_solved:
		if current_level < available_level:
			current_level += 1
		elif riddle <= 0.0:
			$Fader.fade(false)
			$Label.text = (fn_prefix if current_level != 1 else "") + target_expressions[current_level][0]
	else:
		$Fader.direction = -1
