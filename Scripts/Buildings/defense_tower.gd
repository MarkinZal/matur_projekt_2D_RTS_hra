extends Area2D
class_name DefenseTower

@export var is_player_tower: bool = true 
@export var attack_damage: int = 15
@export var attack_rate: float = 1.0

var target_node: Node2D = null
var enemy_group: String = ""

@onready var detection_area: Area2D = $DetectionArea
@onready var shoot_timer: Timer = $ShootTimer

func _ready():
	shoot_timer.wait_time = attack_rate
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)
	
	detection_area.area_entered.connect(_on_target_detected)
	detection_area.body_entered.connect(_on_target_detected)
	detection_area.area_exited.connect(_on_target_lost)
	detection_area.body_exited.connect(_on_target_lost)
	
	if is_player_tower:
		add_to_group("Buildings")
		enemy_group = "UnitEnemy"
	else:
		add_to_group("BuildingEnemy")
		add_to_group("Buildings")
		enemy_group = "UnitPlayer"

func _process(_delta):
	if is_instance_valid(target_node) and shoot_timer.is_stopped():
		shoot_timer.start()
		_on_shoot_timer_timeout() 
	elif not is_instance_valid(target_node) and not shoot_timer.is_stopped():
		shoot_timer.stop()

func _on_shoot_timer_timeout():
	if is_instance_valid(target_node) and target_node.has_method("take_damage"):
		target_node.take_damage(attack_damage)

func _on_target_detected(node: Node2D):
	if target_node == null and node.is_in_group(enemy_group):
		target_node = node

func _on_target_lost(node: Node2D):
	if node == target_node:
		target_node = null
		for overlapping_node in detection_area.get_overlapping_areas():
			if overlapping_node.is_in_group(enemy_group):
				target_node = overlapping_node
				break
