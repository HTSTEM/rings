extends Node


signal chat_message(content, is_voice)

@export var websocket_url = "ws://localhost:5733"

var socket = WebSocketPeer.new()
var voice_prefix = "[VOICE]"


# Called when the node enters the scene tree for the first time.
func _ready():
	var err = socket.connect_to_url(websocket_url)
	if err == OK:
		print("Connecting to %s..." % websocket_url)
		# Wait for the socket to connect.
		await get_tree().create_timer(2).timeout
	else:
		push_error("Unable to connect.")
		# todo: exponential falloff/retry?
		set_process(false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
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
				var effective_text = packet_text
				var is_voice = false
				if packet_text.begins_with(voice_prefix):
					effective_text = packet_text.substr(voice_prefix.length())
					is_voice = true
				chat_message.emit(effective_text, is_voice)

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
		set_process(false) # Stop processing. # TODO: retry?
