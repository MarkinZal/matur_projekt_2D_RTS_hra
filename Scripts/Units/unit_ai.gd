extends Node
class_name UnitAI

enum State { IDLE, CHASE, ATTACK }
var current_state: State = State.IDLE
var target_node: Node2D = null

@onready var parent_unit: Unit = get_parent() 
@onready var detection_area: Area2D = $DetectionArea

func _ready():
	detection_area.area_entered.connect(_on_target_detected)
	detection_area.body_entered.connect(_on_target_detected)
	detection_area.area_exited.connect(_on_target_lost)
	detection_area.body_exited.connect(_on_target_lost)

func _physics_process(_delta: float):
	if current_state in [State.CHASE, State.ATTACK]:
		if not is_instance_valid(target_node) or target_node.is_queued_for_deletion():
			target_node = null
			parent_unit.set_target(null)
			change_state(State.IDLE)
			return
			
	if current_state in [State.CHASE, State.ATTACK] and is_instance_valid(target_node):
		parent_unit.set_target(target_node)

func change_state(new_state: State):
	current_state = new_state

func _on_target_detected(node: Node2D):
	if current_state == State.IDLE:
		if node.is_in_group("UnitPlayer") or (node.is_in_group("Buildings") and not node.is_in_group("BuildingEnemy")):
			target_node = node
			change_state(State.CHASE)

func _on_target_lost(node: Node2D):
	if node == target_node and current_state == State.CHASE:
		target_node = null
		parent_unit.set_target(null)
		change_state(State.IDLE)
