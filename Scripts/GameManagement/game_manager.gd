extends Node

@export var terrain_layer: TileMapLayer
@export var hill_layer: TileMapLayer
@export var fog_layer: TileMapLayer
@export var map_width: int = 100
@export var map_height: int = 100
@export var player_base_scene: PackedScene

var player_start_world_pos: Vector2 

var occupied_hill_spots = {}

var tree_scene = preload("res://Scenes/tree.tscn")
var goldmine_scene = preload("res://Scenes/goldmine.tscn")

var terrain_noise = FastNoiseLite.new()
var forest_noise = FastNoiseLite.new()

var terrain_source_id = 1
var rock_source_id = 5
var water_source_id = 4
var water_rock_source_id = 6
var fog_source_id = 7
var map_size: int = 100

var grass_variants = [
	Vector2i(0,0), Vector2i(1,0), Vector2i(2,0),
	Vector2i(0,1), Vector2i(1,1), Vector2i(2,1),
]

var water_variants = [
	Vector2i(3, 0), 
	Vector2i(4, 0)
]


signal resource_updated(resource_type: String, amount: int)
signal supply_updated(current: int, max_amount: int)
signal game_ended(winning_team_name: String)
signal global_upgrades_changed

var drevo: int = 100
var zlato: int = 100
var current_food: int = 0
var max_food: int = 10

var global_bonus_hp: int = 0
var global_bonus_damage: int = 0

var unit_counts = {
	Entity.Team.PLAYER: 0,
	Entity.Team.ENEMY: 0
}

var game_ui: CanvasLayer

var cost_barracks = {"wood": 50, "gold": 20, "food": 0}
var cost_tower = {"wood": 40, "gold": 50, "food": 0}
var cost_training = {"wood": 100, "gold": 100, "food": 0}

func can_afford(wood_cost: int, gold_cost: int, food_cost: int) -> bool:
	if food_cost > 0 and current_food + food_cost > max_food:
		return false
	if drevo >= wood_cost and zlato >= gold_cost:
		return true
	return false

func _ready():
	add_to_group("game_manager")
	
	terrain_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	terrain_noise.frequency = 0.03
	forest_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	forest_noise.frequency = 0.08
	
	if Global.chci_nacist_hru:
		Global.chci_nacist_hru = false
		call_deferred("load_game")
	else:
		terrain_noise.seed = randi()
		forest_noise.seed = randi() + 1
		if terrain_layer:
			generate_map()
	
	create_fog()
	var fog_timer = Timer.new()
	fog_timer.wait_time = 0.1
	fog_timer.autostart = true
	fog_timer.timeout.connect(update_all_fog)
	add_child(fog_timer)

func create_fog():
	if not fog_layer:
		return
	for x in range(-map_size, map_size):
		for y in range(-map_size, map_size):
			fog_layer.set_cell(Vector2i(x, y), fog_source_id, Vector2i(0, 0))

func reveal_fog_around(world_pos: Vector2, vision_radius: int):
	if not fog_layer: return
	
	var map_pos = fog_layer.local_to_map(world_pos)
	
	for x in range(-vision_radius, vision_radius + 1):
		for y in range(-vision_radius, vision_radius + 1):
			if Vector2(x, y).length() <= vision_radius:
				fog_layer.erase_cell(map_pos + Vector2i(x, y))

func update_all_fog():
	var units = get_tree().get_nodes_in_group("UnitPlayer")
	for unit in units:
		reveal_fog_around(unit.global_position, 6) 
		
	var buildings = get_tree().get_nodes_in_group("Buildings")
	for building in buildings:
		reveal_fog_around(building.global_position, 8)

func generate_map():
	terrain_layer.clear()
	if hill_layer:
		hill_layer.clear()
	occupied_hill_spots.clear()
	
	var start_x = randi_range(6, 14)
	var start_y = randi_range(6, 14)
	var player_spawn = Vector2(start_x, start_y)
	
	player_start_world_pos = Vector2(start_x * 16, start_y * 16)
	
	var enemy_spawn = Vector2(map_width - 10, map_height - 10)
	var path_width = 4.0
	
	for x in range(map_width):
		for y in range(map_height):
			var pos = Vector2i(x, y)
			
			var dist_to_path = _distance_to_segment(Vector2(x, y), player_spawn, enemy_spawn)
			var is_safe_path = dist_to_path <= path_width
			
			var elev = terrain_noise.get_noise_2d(x, y)
			
			if elev < -0.1 and not is_safe_path:
				terrain_layer.set_cell(pos, water_source_id, water_variants.pick_random()) 
				
				if elev < -0.25 and hill_layer and not occupied_hill_spots.has(pos) and randf() < 0.15:
					_build_water_rock(x, y)
				
			elif elev > 0.3 and not is_safe_path:
				terrain_layer.set_cell(pos, terrain_source_id, grass_variants.pick_random())
				
				if hill_layer and not occupied_hill_spots.has(pos):
					_build_large_rock(x, y)
				
			else:
				terrain_layer.set_cell(pos, terrain_source_id, grass_variants.pick_random())
				
				if not is_safe_path:
					_spawn_objects(pos, x, y)

	if player_base_scene:
		var base = player_base_scene.instantiate()
		base.global_position = player_start_world_pos
		get_tree().current_scene.call_deferred("add_child", base)
		

func _build_large_rock(x: int, y: int):
	if x + 2 >= map_width or y + 2 >= map_height: 
		return
	
	for i in range(3):
		for j in range(3):
			if occupied_hill_spots.has(Vector2i(x + i, y + j)): 
				return

	var top_left     = Vector2i(0, 0);
	var top_mid      = Vector2i(1, 0);
	var top_right    = Vector2i(2, 0)
	var mid_left     = Vector2i(0, 1);
	var center       = Vector2i(1, 1);
	var mid_right    = Vector2i(2, 1)
	var bottom_left  = Vector2i(0, 2);
	var bottom_mid   = Vector2i(1, 2);
	var bottom_right = Vector2i(2, 2)
	
	hill_layer.set_cell(Vector2i(x, y), rock_source_id, top_left)
	hill_layer.set_cell(Vector2i(x + 1, y), rock_source_id, top_mid)
	hill_layer.set_cell(Vector2i(x + 2, y), rock_source_id, top_right)
	hill_layer.set_cell(Vector2i(x, y + 1), rock_source_id, mid_left)
	hill_layer.set_cell(Vector2i(x + 1, y + 1), rock_source_id, center)
	hill_layer.set_cell(Vector2i(x + 2, y + 1), rock_source_id, mid_right)
	hill_layer.set_cell(Vector2i(x, y + 2), rock_source_id, bottom_left)
	hill_layer.set_cell(Vector2i(x + 1, y + 2), rock_source_id, bottom_mid)
	hill_layer.set_cell(Vector2i(x + 2, y + 2), rock_source_id, bottom_right)
	
	for i in range(3):
		for j in range(3): occupied_hill_spots[Vector2i(x + i, y + j)] = true

func _build_water_rock(x: int, y: int):
	if x + 1 >= map_width or y + 1 >= map_height: return
	for i in range(2):
		for j in range(2):
			if occupied_hill_spots.has(Vector2i(x + i, y + j)): return

	var top_left     = Vector2i(0, 0);
	var top_right    = Vector2i(2, 0)
	var bottom_left  = Vector2i(0, 2);
	var bottom_right = Vector2i(2, 2)
	
	hill_layer.set_cell(Vector2i(x, y), water_rock_source_id, top_left)
	hill_layer.set_cell(Vector2i(x + 1, y), water_rock_source_id, top_right)
	hill_layer.set_cell(Vector2i(x, y + 1), water_rock_source_id, bottom_left)
	hill_layer.set_cell(Vector2i(x + 1, y + 1), water_rock_source_id, bottom_right)
	
	for i in range(2):
		for j in range(2): occupied_hill_spots[Vector2i(x + i, y + j)] = true

func _spawn_objects(grid_pos: Vector2i, x: int, y: int):
	var world_pos = Vector2(x * 16 + 8, y * 16 + 8)
	var tree_density = forest_noise.get_noise_2d(x, y)
	
	if tree_density > 0.3:
		if randf() < 0.7: 
			var tree = tree_scene.instantiate()
			tree.global_position = world_pos
			terrain_layer.add_child(tree)
			
	elif randf() < 0.005:
		var mine = goldmine_scene.instantiate()
		mine.global_position = world_pos
		terrain_layer.add_child(mine)

func _distance_to_segment(p: Vector2, v: Vector2, w: Vector2) -> float:
	var l2 = v.distance_squared_to(w)
	if l2 == 0: return p.distance_to(v)
	var t = max(0, min(1, (p - v).dot(w - v) / l2))
	var projection = v + t * (w - v)
	return p.distance_to(projection)

func register_unit(unit: Unit):
	if unit.team in unit_counts:
		unit_counts[unit.team] += 1

func add_resource(type: String, amount: int):
	match type:
		"wood":
			drevo += amount
			resource_updated.emit("wood", drevo)
		"gold":
			zlato += amount
			resource_updated.emit("gold", zlato)

func increase_food_cap(amount: int):
	max_food += amount
	supply_updated.emit(current_food, max_food)

func use_food(amount: int):
	current_food += amount
	supply_updated.emit(current_food, max_food)

func free_food(amount: int):
	current_food -= amount
	if current_food < 0: current_food = 0
	supply_updated.emit(current_food, max_food)

func try_spend_resources(wood_cost: int, gold_cost: int, food_cost: int) -> bool:
	if food_cost > 0 and current_food + food_cost > max_food:
		return false

	if drevo >= wood_cost and zlato >= gold_cost:
		drevo -= wood_cost
		zlato -= gold_cost
		if food_cost > 0:
			use_food(food_cost)
		resource_updated.emit("wood", drevo)
		resource_updated.emit("gold", zlato)
		return true
		
	return false

func purchase_upgrade() -> bool:
	if try_spend_resources(50, 50, 0):
		global_bonus_hp += 10
		global_bonus_damage += 3
		global_upgrades_changed.emit()
		return true
	return false

func base_destroyed(losing_team: int):
	var winner_name = "Nikdo"
	if losing_team == Entity.Team.ENEMY:
		winner_name = "PLAYER"
	elif losing_team == Entity.Team.PLAYER:
		winner_name = "ENEMY"
	game_ended.emit(winner_name)

func get_save_path() -> String:
	var save_dir = ""
	
	if OS.has_feature("editor"):
		save_dir = "res://Saves"
	else:
		save_dir = OS.get_executable_path().get_base_dir() + "/Saves"
		
	if not DirAccess.dir_exists_absolute(save_dir):
		DirAccess.make_dir_absolute(save_dir)
		
	return save_dir + "/savegame.json"

func save_game():
	var save_data = {
		"seeds": {
			"terrain": terrain_noise.seed,
			"forest": forest_noise.seed
		},
		"resources": {
			"wood": drevo,
			"gold": zlato,
			"current_food": current_food,
			"max_food": max_food
		},
		"upgrades": {
			"bonus_hp": global_bonus_hp,
			"bonus_damage": global_bonus_damage
		},
		"units": [],
		"buildings": []
	}
	
	var units = get_tree().get_nodes_in_group("UnitPlayer")
	for unit in units:
		save_data["units"].append({
			"pos_x": unit.global_position.x,
			"pos_y": unit.global_position.y,
			"team": unit.team,
			"scene_path": unit.scene_file_path,
			"health_current": unit.health_current
		})
		
	var buildings = get_tree().get_nodes_in_group("Buildings")
	for building in buildings:
		save_data["buildings"].append({
			"pos_x": building.global_position.x,
			"pos_y": building.global_position.y,
			"team": building.team,
			"scene_path": building.scene_file_path
		})
	
	var file = FileAccess.open(get_save_path(), FileAccess.WRITE)
	file.store_string(JSON.stringify(save_data))
	print("Ulozeno do: ", get_save_path())

func load_game():
	var path = get_save_path()
	if not FileAccess.file_exists(path): 
		return
	
	var file = FileAccess.open(path, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	
	terrain_noise.seed = data["seeds"]["terrain"]
	forest_noise.seed = data["seeds"]["forest"]
	if terrain_layer:
		generate_map()
	
	drevo = data["resources"]["wood"]
	zlato = data["resources"]["gold"]
	current_food = data["resources"]["current_food"]
	max_food = data["resources"]["max_food"]
	
	global_bonus_hp = data["upgrades"]["bonus_hp"]
	global_bonus_damage = data["upgrades"]["bonus_damage"]
	
	resource_updated.emit("wood", drevo)
	resource_updated.emit("gold", zlato)
	supply_updated.emit(current_food, max_food)
	global_upgrades_changed.emit()
	
	for u in get_tree().get_nodes_in_group("UnitPlayer"): 
		u.queue_free()
	for b in get_tree().get_nodes_in_group("Buildings"): 
		b.queue_free()
	
	for u_data in data["units"]:
		var specific_scene = load(u_data["scene_path"]) 
		if specific_scene:
			var new_unit = specific_scene.instantiate()
			new_unit.global_position = Vector2(u_data["pos_x"], u_data["pos_y"])
			new_unit.team = u_data["team"]
			new_unit.health_current = u_data["health_current"]
			
			get_tree().current_scene.add_child(new_unit) 
			
	for b_data in data["buildings"]:
		var specific_scene = load(b_data["scene_path"]) 
		if specific_scene:
			var new_building = specific_scene.instantiate()
			new_building.global_position = Vector2(b_data["pos_x"], b_data["pos_y"])
			new_building.team = b_data["team"]
			
			get_tree().current_scene.add_child(new_building)
			
	print("Nacteno z: ", path)
