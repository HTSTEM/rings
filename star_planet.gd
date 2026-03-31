extends StaticBody2D

var purchase_regex = RegEx.create_from_string("^buy (\\w+) poster$")
var target = 33101.0
var since_save = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	WSClient.chat_message.connect(handle_input)
	if GameState.is_solved("clicker"):
		$Fader.fade(true)

func handle_input(value: String, is_voice: bool, user_id: String):
	GameState.click(GameState.clicker_text_cps)
	var regex_match = purchase_regex.search(value.to_lower())
	if regex_match:
		var upgrade_name = regex_match.get_string(1)
		if upgrade_name in GameState.clicker_by_name:
			WSClient.emit_message_consumed(value)
			GameState.clicker_purchase(GameState.clicker_by_name[upgrade_name])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	GameState.click(GameState.clicker_cps * delta)
	if GameState.clicker_clicks >= target:
		GameState.solve("clicker")
		$Fader.fade(false)
		
	get_node("Label").text = "%.1f" % GameState.clicker_clicks
	
	var scale = lerp(0.8, 1.2, clampf(GameState.clicker_lifetime / target, 0, 1))
	$StarAlways.scale = Vector2(scale, scale)
	$Fader.scale = Vector2(scale, scale)
	$CollisionShape2D.scale = Vector2(scale, scale)
	
	since_save += delta
	if since_save >= 10.0:
		GameState._save()
		since_save = 0.0
