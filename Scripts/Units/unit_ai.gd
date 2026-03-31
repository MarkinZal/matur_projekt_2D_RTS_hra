extends Node
class_name UnitAI

@export var speed: float = 100.0
@export var attack_damage: int = 10
@export var attack_range: float = 40.0

enum State { IDLE, CHASE, ATTACK }
var current_state: State = State.IDLE

var target_node: Node2D = null

@onready var parent_unit: Area2D = get_parent()
@onready var nav_agent: NavigationAgent2D = $"../NavigationAgent2D"
@onready var detection_area: Area2D = $DetectionArea
@onready var attack_timer: Timer = $AttackTimer

func _ready():
	attack_timer.one_shot = true
	detection_area.area_entered.connect(_on_target_detected)
	detection_area.body_entered.connect(_on_target_detected)
	detection_area.area_exited.connect(_on_target_lost)
	detection_area.body_exited.connect(_on_target_lost)

func _physics_process(delta: float):
	if current_state in [State.CHASE, State.ATTACK]:
		if not is_instance_valid(target_node) or target_node.is_queued_for_deletion():
			target_node = null
			change_state(State.IDLE)
			return
	
	match current_state:
		State.IDLE:
			pass
		State.CHASE:
			process_chase(delta)
		State.ATTACK:
			process_attack(delta)

func process_chase(delta: float):
	nav_agent.target_position = target_node.global_position
	
	var dist_to_target = parent_unit.global_position.distance_to(target_node.global_position)
	
	if dist_to_target <= attack_range or nav_agent.is_navigation_finished():
		change_state(State.ATTACK)
		return
		
	var next_path_position = nav_agent.get_next_path_position()
	var direction = parent_unit.global_position.direction_to(next_path_position)
	
	parent_unit.global_position += direction * speed * delta

func process_attack(_delta: float):
	var dist_to_target = parent_unit.global_position.distance_to(target_node.global_position)
	
	if dist_to_target > attack_range + 5.0 and not nav_agent.is_navigation_finished():
		change_state(State.CHASE)
		return
		
	if attack_timer.is_stopped():
		perform_attack()
		attack_timer.start()

func perform_attack():
	if is_instance_valid(target_node) and target_node.has_method("take_damage"):
		target_node.take_damage(attack_damage)

func change_state(new_state: State):
	if current_state == new_state: return
	
	if current_state == State.ATTACK:
		attack_timer.stop()
		
	current_state = new_state

func _on_target_detected(node: Node2D):
	if current_state == State.IDLE:
		if node.is_in_group("UnitPlayer") or node.is_in_group("Buildings"):
			target_node = node
			change_state(State.CHASE)

func _on_target_lost(node: Node2D):
	if node == target_node and current_state == State.CHASE:
		target_node = null
		change_state(State.IDLE)
