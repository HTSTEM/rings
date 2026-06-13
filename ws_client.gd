extends Node


signal chat_message(content, is_voice, user_id)
signal consumed_message(content)

@export var websocket_url = "ws://localhost:5733"

var voice_prefix = "[VOICE]"
var user_prefix = RegEx.create_from_string("^\\{([^}]+)\\}")
var connection_attempts = 0
var recently_consumed: Array[String] = []


func emit_message_consumed(text: String):
	if text in recently_consumed:
		return
	recently_consumed.append(text)
	consumed_message.emit(text)


func connect_socket():
	pass


# Called when the node enters the scene tree for the first time.
func _ready():
	connect_socket()


func emit_message(packet_text: String):
	var is_voice = false
	var user_id = "unknown"
	var user_id_match = user_prefix.search(packet_text)
	if user_id_match:
		user_id = user_id_match.get_string(1)
		packet_text = packet_text.substr(len(user_id_match.get_string()))
	if packet_text.begins_with(voice_prefix):
		packet_text = packet_text.substr(voice_prefix.length())
		is_voice = true
	packet_text = packet_text.strip_edges()
	if packet_text.is_empty():
		return
	if GameState.in_intro and packet_text.to_lower() != "take control":
		packet_text = "" # avoid pre commands
	chat_message.emit(packet_text, is_voice, user_id)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	recently_consumed.clear()
