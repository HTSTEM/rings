extends Node

var _save_file_name = "user://tessie._save"
var _serializable: Array[String] = ["_planets_solved", "_steps_solved", "clicker_clicks", "clicker_purchases", "clicker_lifetime"]

var all_planets: Array[String] = ["wordle", "clicker", "riddle", "tutorial", "music", "math0", "math1", "games", "ice", "arg"]
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
	"chess": 100,
	"805": 1000000
}
var clicker_costs = {
	"text": 10.0,
	"image": 50.0,
	"video": 100.0,
	"meta": 500.0,
	"chess": 1000.0,
	"805": 500000.0,
}
var clicker_purchases = {
	"text": 0,
	"image": 0,
	"video": 0,
	"meta": 0,
	"chess": 0,
	"805": 0
}
var clicker_names = {
	"text": "Text",
	"image": "Image",
	"video": "Video",
	"meta": "Meta",
	"chess": "Chessboard",
	"805": "80/5"
}
var clicker_by_name = {}
var clicker_next_cost = {}
var in_intro: bool = true
var running_credits: bool = false

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

func start_credits():
	if running_credits:
		return
	running_credits = true
	
	var music_tween = get_tree().create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN).set_parallel(false)
	music_tween.tween_property(get_world().get_node("MainMusic"), "volume_db", -80.0, 5.0).set_delay(0.5)
	
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN).set_parallel(false)
	tween.tween_property(get_world().get_node("UI/OutroFadeOut"), "modulate", Color(1.0, 1.0, 1.0, 1.0), 5.0).set_delay(0.5)
	tween.tween_callback(func (): get_tree().change_scene_to_file("res://ending.tscn"))

func solve(planet: String):
	if planet in _planets_solved:
		return
	if planet not in all_planets:
		push_error("Unknown planet %s" % planet)
	# TODO: this maybe could be positional, we'd have to get a player on each planet for not much payoff
	_planets_solved.append(planet)
	_set_new_radius()
	success_and_save()
	
	if len(_planets_solved) >= len(all_planets):
		start_credits()

func get_world():
	var nested = get_node("/root/Intro/SubViewportContainer/SubViewport/World")
	if nested:
		return nested
	return get_node("/root/World")

func success_and_save():
	var player: AudioStreamPlayer = get_world().get_node("SuccessPlayer")
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
