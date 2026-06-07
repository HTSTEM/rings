extends Node


signal chat_message(content, is_voice, user_id)
signal consumed_message(content)

@export var websocket_url = "ws://localhost:5733"

var socket = WebSocketPeer.new()
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
	var err = socket.connect_to_url(websocket_url)
	if err == OK:
		print("Connecting to %s..." % websocket_url)
	else:
		push_error("Unable to connect.")
		var wait_for = min(pow(2, connection_attempts), 12)
		connection_attempts += 1
		await get_tree().create_timer(wait_for).timeout
		connect_socket()


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
	
	# Call this in `_process()` or `_physics_process()`.
	# Data transfer and state updates will only happen when calling this function.
	socket.poll()

	# get_ready_state() tells you what state the socket is in.
	var state = socket.get_ready_state()

	# `WebSocketPeer.STATE_OPEN` means the socket is connected and ready
	# to send and receive data.
	if state == WebSocketPeer.STATE_OPEN:
		while socket.get_available_packet_count():
			var packet = socket.get_packet()
			if socket.was_string_packet():
				var packet_text = packet.get_string_from_utf8()
				emit_message(packet_text)

	# `WebSocketPeer.STATE_CLOSING` means the socket is closing.
	# It is important to keep polling for a clean close.
	elif state == WebSocketPeer.STATE_CLOSING:
		pass

	# `WebSocketPeer.STATE_CLOSED` means the connection has fully closed.
	# It is now safe to stop polling.
	elif state == WebSocketPeer.STATE_CLOSED:
		# The code will be `-1` if the disconnection was not properly notified by the remote peer.
		var code = socket.get_close_code()
		print("WebSocket closed with code: %d. Clean: %s" % [code, code != -1])
		connect_socket()
