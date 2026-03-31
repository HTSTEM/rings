extends Node

var _save_file_name = "user://tessie._save"
var _serializable: Array[String] = ["_planets_solved", "_steps_solved", "clicker_clicks", "clicker_purchases", "clicker_lifetime", "seen_intro"]

var _planets_solved: Array[String] = []
var _steps_solved: Array[String] = []

var _base_progression_radius = 1250
var _incremental_progression_radius = 500
var _target_progression_radius = _base_progression_radius
var _radius_animating_from = -1
var _radius_animation_elapsed = -1
var progression_radius = _target_progression_radius

var clicker_clicks = 0.0
var clicker_lifetime = 0.0
var clicker_text_base = 0.1
var clicker_text_cps = clicker_text_base
var clicker_cps = 0.0
var clicker_rates = {
	"text": .1,
	"image": 1,
	"video": 10,
	"meta": 50,
	"chess": 100
}
var clicker_costs = {
	"text": 10.0,
	"image": 50.0,
	"video": 100.0,
	"meta": 500.0,
	"chess": 1000.0
}
var clicker_purchases = {
	"text": 0,
	"image": 0,
	"video": 0,
	"meta": 0,
	"chess": 0
}
var clicker_names = {
	"text": "Text",
	"image": "Image",
	"video": "Video",
	"meta": "Meta",
	"chess": "Chessboard"
}
var clicker_by_name = {}
var clicker_next_cost = {}
var seen_intro = false

func update_cookie_data():
	clicker_cps = 0
	clicker_text_cps = clicker_text_base
	for key in clicker_costs:
		var purchased = clicker_purchases[key]
		clicker_next_cost[key] = int(ceilf(float(clicker_costs[key]) * pow(1.1, purchased)))
		var cps = purchased * clicker_rates[key]
		clicker_cps += cps
		if key == "text":
			clicker_text_cps += cps

func _save():
	var data: Dictionary[String, Variant] = {}
	for i in _serializable:
		data[i] = get(i)
	print("data", data)
	
	var save_file = FileAccess.open(_save_file_name, FileAccess.WRITE)
	save_file.store_string(JSON.stringify(data))
	save_file.close()
	print("saved")

func _set_new_radius():
	_target_progression_radius = _base_progression_radius + (_incremental_progression_radius * len(_planets_solved))
	_radius_animating_from = progression_radius
	_radius_animation_elapsed = 0
	print("stuff ", _planets_solved, " ", len(_planets_solved), " ", _target_progression_radius, " ", _radius_animating_from, " ", _radius_animation_elapsed)

func solve(planet: String):
	if planet in _planets_solved:
		return
	# TODO: this maybe could be positional, we'd have to get a player on each planet for not much payoff
	var player: AudioStreamPlayer = get_parent().find_child("SuccessPlayer")
	player.play()
	_planets_solved.append(planet)
	_set_new_radius()
	_save()
	
func success_and_save():
	var player: AudioStreamPlayer = get_node("/root/World/SuccessPlayer")
	player.play()
	_save()

func solve_step(step: String):
	if is_step_solved(step):
		return
	_steps_solved.append(step)
	_save()

func is_solved(planet: String) -> bool:
	return planet in _planets_solved

func is_step_solved(step: String) -> bool:
	return step in _steps_solved

func click(amount: float):
	clicker_clicks += amount
	clicker_lifetime += amount

func clicker_purchase(upgrade: String) -> bool:
	var cost = float(clicker_next_cost[upgrade])
	if clicker_clicks < cost:
		return false
	clicker_clicks -= cost
	clicker_purchases[upgrade] += 1
	update_cookie_data()
	_save()
	return true

func _ready():
	for i in clicker_names:
		clicker_by_name[clicker_names[i].to_lower()] = i
	update_cookie_data()
	
	
	if FileAccess.file_exists(_save_file_name):
		var save_file = FileAccess.open(_save_file_name, FileAccess.READ)
		var json_string = save_file.get_line().strip_edges()
		print("exists", json_string)
		var json = JSON.parse_string(json_string)
		if json:
			print("JSON", json)
			for i in json.keys():
				# hack for it refusing to save the array
				if json[i] is Array:
					get(i).append_array(json[i])
				elif json[i] is Dictionary:
					for x in json[i]:
						get(i)[x] = json[i][x]
				else:
					set(i, json[i])
				print("set ", i, " ", json[i], " ", self.get(i))
			_set_new_radius()
			progression_radius = _target_progression_radius
			_radius_animating_from = -1
			_radius_animation_elapsed = -1
			update_cookie_data()
		save_file.close()

func _process(delta):
	if _radius_animating_from != -1 and _radius_animation_elapsed != -1:
		_radius_animation_elapsed += delta
		var elapsed_pct = clampf(float(_radius_animation_elapsed)/3.0, 0.0, 1.0)
		progression_radius = lerp(float(_radius_animating_from), float(_target_progression_radius), ease(elapsed_pct, -3))
		if elapsed_pct >= 1.0:
			_radius_animating_from = -1
			_radius_animation_elapsed = -1
