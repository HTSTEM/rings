extends StaticBody2D

var fn_prefix = "f(x)="
var target_expr = "2x+15"

func handle_input(value: String, is_voice: bool):
	if GameState.is_solved("math") or is_voice:
		return

	var label: Label = get_node("Label")
	if value.begins_with(fn_prefix):
		var expr = value.substr(len(fn_prefix))
		# TODO: tokenize lib
		if expr == "2x+15":
			GameState.solve("math")
			label.text = fn_prefix + target_expr
		else:
			label.text = "f(x)≠" + expr
	elif value.is_valid_float():
		var number = value.to_float()
		var result = number * 2 + 15
		label.text = "f(" + str(number) + ")=" + str(result)


# Called when the node enters the scene tree for the first time.
func _ready():
	if GameState.is_solved("math"):
		get_node("Label").text = fn_prefix + target_expr
	
	WSClient.chat_message.connect(handle_input)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
