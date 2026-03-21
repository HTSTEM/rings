extends PanelContainer

var fadein = 0

var waitfor = 3

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var wsclient = get_node("/root/WSClient")
	var state: WebSocketPeer.State = wsclient.socket.get_ready_state()
	if state == WebSocketPeer.STATE_OPEN:
		fadein = max(0, fadein - delta)
	else:
		fadein = min(waitfor + 1, fadein + delta)
	
	self.position.x = lerp(-self.size.x, 0.0, ease(clampf(fadein-waitfor, 0, 1), 0.2))
