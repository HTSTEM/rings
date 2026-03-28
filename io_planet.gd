extends StaticBody2D

var fn_prefix = "f(x)="
var alt_fn_prefix = "y="
var target_expressions = [
	["2x^2-10x+5"],
	["y+=x", "f(x)+=x", "+=x", "f(n-1)+x_n", "x_n+f(n-1)"]
]
var whitespace = RegEx.create_from_string("\\s+")
var available_level: int = 0
var current_level: int = 0
var previous_result: float = 0.0

func handle_input(value: String, is_voice: bool):
	if GameState.is_solved("math%d" % current_level) or is_voice:
		return

	var label: Label = get_node("Label")
	value = value.to_lower()
	value = whitespace.sub(value, "", true)
	if value.begins_with(fn_prefix):
		value = value.substr(len(fn_prefix))
	if value.begins_with(alt_fn_prefix):
		value = value.substr(len(alt_fn_prefix))
	value = value.substr(0, 20)
	
	if value.is_valid_float():
		var x = roundf(value.to_float() * 10.0) / 10.0
		var result = ((2 * pow(x, 2)) - (10 * x) + 5) if current_level == 0 else (previous_result + x)
		previous_result = result
		label.text = "f(%.1d)=%.1d" % [x, result]
	# TODO: tokenize?
	elif value in target_expressions[current_level]:
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
	available_level = 0
	if len(GameState._planets_solved) > 2:
		available_level += 1
	var is_solved = GameState.is_solved("math%d" % current_level)
	if is_solved:
		if current_level < available_level:
			current_level += 1
		else:
			$Fader.fade(false)
			$Label.text = (fn_prefix if current_level != 1 else "") + target_expressions[current_level][0]
	else:
		$Fader.direction = -1
