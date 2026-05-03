extends Node
class_name DefenderCommander

@export_category("Základní Nastavení")
@export var decision_interval: float = 3.0

@export_category("Scény Budov")
@export var barracks_scene: PackedScene
@export var tower_scene: PackedScene 

@export_category("Scény Jednotek")
@export var worker_scene: PackedScene
@export var melee_scene: PackedScene
@export var archer_scene: PackedScene

@export_category("Ekonomika a Limity")
@export var max_workers: int = 2
@export var max_barracks: int = 2
@export var max_towers: int = 3
@export var max_army_size: int = 20

var cost_worker = 30
var cost_barracks = 100
var cost_tower = 150
var cost_unit = 50

var current_enemy_gold: int = 200

var enemy_workers: Array[Node2D] = []
var enemy_barracks: Array[Node2D] = []
var enemy_towers: Array[Node2D] = []
var enemy_army: Array[Node2D] = []

var enemy_base: Node2D
var player_base: Node2D

@onready var decision_timer: Timer = Timer.new()

func _ready():
	enemy_base = get_parent()
	add_child(decision_timer)
	decision_timer.wait_time = decision_interval
	decision_timer.timeout.connect(_on_decision_tick)
	decision_timer.start()

func _on_decision_tick():
	_find_player_base()
	_update_lists()
	
	current_enemy_gold += 15 
	
	_make_decision()
	
	_manage_tactics()

func _make_decision():
	if enemy_workers.size() < max_workers:
		if current_enemy_gold >= cost_worker:
			_spawn_from_base(worker_scene)
			current_enemy_gold -= cost_worker
			print("AI: Trénuji dělníka!")
		return 

	if enemy_barracks.size() < max_barracks:
		if current_enemy_gold >= cost_barracks:
			_build_structure_near_base(barracks_scene, "BuildingEnemy")
			current_enemy_gold -= cost_barracks
			print("AI: Dělník staví Kasárna poblíž základny!")
		return 
		
	if enemy_towers.size() < max_towers and enemy_army.size() >= 5:
		if current_enemy_gold >= cost_tower:
			_build_structure_near_base(tower_scene, "BuildingEnemy")
			current_enemy_gold -= cost_tower
			print("AI: Dělník staví Věž poblíž základny!")
		return

	if enemy_barracks.size() > 0 and enemy_army.size() < max_army_size:
		if current_enemy_gold >= cost_unit:
			_train_army_from_barracks()
			current_enemy_gold -= cost_unit
			print("AI: Kasárna trénují vojáka!")


func _spawn_from_base(scene: PackedScene):
	if is_instance_valid(enemy_base) and enemy_base.has_method("_spawn_unit"):
		enemy_base._spawn_unit(scene)

func _build_structure_near_base(scene: PackedScene, group_name: String):
	if not is_instance_valid(enemy_base) or not scene: return
	
	var new_building = scene.instantiate()
	
	var angle = randf() * PI * 2
	var distance = randf_range(80.0, 150.0) 
	var offset = Vector2(cos(angle), sin(angle)) * distance
	
	new_building.global_position = enemy_base.global_position + offset
	if "team" in new_building:
		new_building.team = Entity.Team.ENEMY
		
	new_building.add_to_group(group_name)
	
	enemy_base.get_parent().add_child(new_building)

func _train_army_from_barracks():
	var spawner = enemy_barracks.pick_random()
	if is_instance_valid(spawner) and spawner.has_method("_spawn_unit"):
		var random_scene = archer_scene if randf() > 0.5 else melee_scene
		spawner._spawn_unit(random_scene)


func _update_lists():
	enemy_workers.clear()
	enemy_army.clear()
	
	var all_enemy_units = get_tree().get_nodes_in_group("UnitEnemy")
	for unit in all_enemy_units:
		if "is_worker" in unit and unit.is_worker:
			enemy_workers.append(unit)
		else:
			enemy_army.append(unit)
			
	enemy_barracks.assign(get_tree().get_nodes_in_group("BuildingEnemy"))

func _manage_tactics():
	if enemy_army.size() >= max_army_size and is_instance_valid(player_base):
		for unit in enemy_army:
			_send_unit_to(unit, player_base)
	elif enemy_army.size() >= 8:
		var attackers = 0
		for unit in enemy_army:
			if attackers < 3:
				_send_unit_to(unit, player_base)
				attackers += 1
			else:
				_defend_base(unit)
	else:
		for unit in enemy_army:
			_defend_base(unit)

func _send_unit_to(unit: Node2D, target: Node2D):
	if not is_instance_valid(unit) or not is_instance_valid(target): return
	var ai = unit.get_node_or_null("UnitAI")
	if ai and ai.target_node != target:
		ai.target_node = target
		ai.change_state(ai.State.CHASE)

func _defend_base(unit: Node2D):
	if is_instance_valid(enemy_base) and unit.global_position.distance_to(enemy_base.global_position) > 200.0:
		_send_unit_to(unit, enemy_base)

func _find_player_base():
	if is_instance_valid(player_base): return
	var bldgs = get_tree().get_nodes_in_group("Buildings")
	for b in bldgs:
		if "team" in b and b.team == Entity.Team.PLAYER and "can_train_units" in b:
			player_base = b
			break
