extends Node
class_name DefenderCommander

@export_category("Základní Nastavení")
@export var decision_interval: float = 3.0
@export var enemy_base: Node2D
@export var player_base: Node2D

@export_category("Budování a Ekonomika")
@export var tower_scene: PackedScene 
@export var tower_build_spots: Array[Marker2D] 
@export var tower_cost: int = 150

@export_category("Armáda")
@export var enemy_barracks: Array[Node2D]
@export var max_army_size: int = 20
@export var unit_cost: int = 50

var current_enemy_gold: int = 200
var my_army: Array[Node2D] = []

@onready var decision_timer: Timer = Timer.new()

func _ready():
	add_child(decision_timer)
	decision_timer.wait_time = decision_interval
	decision_timer.timeout.connect(_on_decision_tick)
	decision_timer.start()

func _on_decision_tick():
	update_army_list()
	manage_economy()
	build_defenses()
	train_army()
	manage_tactics()

func update_army_list():
	my_army.assign(get_tree().get_nodes_in_group("UnitEnemy"))

func manage_economy():
	current_enemy_gold += 15 

func build_defenses():
	if current_enemy_gold >= tower_cost and not tower_build_spots.is_empty():
		var build_spot = tower_build_spots.pop_front()
		
		if is_instance_valid(build_spot) and tower_scene:
			var new_tower = tower_scene.instantiate()
			get_parent().add_child(new_tower) 
			new_tower.global_position = build_spot.global_position
			current_enemy_gold -= tower_cost
			
			new_tower.add_to_group("BuildingEnemy")

func train_army():
	if enemy_barracks.is_empty(): return
	
	if my_army.size() < max_army_size and current_enemy_gold >= unit_cost:
		var spawner = enemy_barracks.pick_random()
		if is_instance_valid(spawner) and spawner.has_method("spawn_unit"):
			spawner.spawn_unit()
			current_enemy_gold -= unit_cost

func manage_tactics():
	var idle_army = get_idle_units()
	
	if my_army.size() >= max_army_size and is_instance_valid(player_base):
		for unit in idle_army:
			var ai_node = unit.get_node_or_null("UnitAI")
			if ai_node:
				ai_node.target_node = player_base
				ai_node.change_state(ai_node.State.CHASE)
	else:
		if is_instance_valid(enemy_base):
			for unit in idle_army:
				if unit.global_position.distance_to(enemy_base.global_position) > 150.0:
					var ai_node = unit.get_node_or_null("UnitAI")
					if ai_node:
						ai_node.target_node = enemy_base
						ai_node.change_state(ai_node.State.CHASE)

func get_idle_units() -> Array[Node2D]:
	var idle_units: Array[Node2D] = []
	for unit in my_army:
		var ai_node = unit.get_node_or_null("UnitAI")
		if ai_node and ai_node.current_state == ai_node.State.IDLE:
			idle_units.append(unit)
	return idle_units
