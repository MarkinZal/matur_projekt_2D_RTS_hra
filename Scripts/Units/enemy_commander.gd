extends Node
class_name EnemyCommander

@export var decision_interval: float = 3.0
@export var max_army_size: int = 10
@export var attack_wave_size: int = 5

@export var enemy_barracks: Array[Node2D]
@export var player_base: Node2D

var current_enemy_gold: int = 500
var my_army: Array[Node2D] = []

@onready var decision_timer: Timer = Timer.new()

func _ready():
	add_child(decision_timer)
	decision_timer.wait_time = decision_interval
	decision_timer.timeout.connect(_on_decision_tick)
	decision_timer.start()

func _on_decision_tick():
	update_army_list()
	manage_economy_and_production()
	manage_military_tactics()

func update_army_list():
	my_army = get_tree().get_nodes_in_group("UnitAI")

func manage_economy_and_production():
	current_enemy_gold += 10 
	
	if my_army.size() < max_army_size and current_enemy_gold >= 50:
		train_unit()

func train_unit():
	if enemy_barracks.is_empty(): return
	
	var spawner = enemy_barracks.pick_random()
	if spawner.has_method("spawn_unit"):
		spawner.spawn_unit()
		current_enemy_gold -= 50

func manage_military_tactics():
	var idle_army = get_idle_units()
	
	if idle_army.size() >= attack_wave_size and is_instance_valid(player_base):
		for unit in idle_army:
			var ai_node = unit.get_node_or_null("UnitAI")
			if ai_node:
				ai_node.target_node = player_base
				ai_node.change_state(ai_node.State.CHASE)

func get_idle_units() -> Array[Node2D]:
	var idle_units: Array[Node2D] = []
	for unit in my_army:
		var ai_node = unit.get_node_or_null("UnitAI")
		if ai_node and ai_node.current_state == ai_node.State.IDLE:
			idle_units.append(unit)
	return idle_units
