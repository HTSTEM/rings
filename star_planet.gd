extends StaticBody2D


# Called when the node enters the scene tree for the first time.
func _ready():
	WSClient.chat_message.connect(handle_input)

func handle_input(value: String, is_voice: bool):
	GameState.clicker_clicks += GameState.clicker_text_cps

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	GameState.clicker_clicks += GameState.clicker_cps * delta
	pass
