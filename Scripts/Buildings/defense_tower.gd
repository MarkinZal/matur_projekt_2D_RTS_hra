extends Building
class_name DefenseTower

@export var attack_range: float = 150.0
@export var attack_rate: float = 1.0
@export var attack_damage: int = 10

var target_unit: Node2D = null
var last_attack_time: float = 0.0

func _ready():
	can_train_units = false
	
	health_max = 100
	health_current = 100

func _process(delta):
	_utok_logic()

func _utok_logic():
	if not is_instance_valid(target_unit):
		return
		
	var distance = global_position.distance_to(target_unit.global_position)
	if distance <= attack_range:
		_try_attack()

func _try_attack():
	var time = Time.get_unix_time_from_system()
	if time - last_attack_time < attack_rate:
		return
		
	last_attack_time = time
	if target_unit.has_method("take_damage"):
		target_unit.take_damage(attack_damage)

func _input(event):
	pass

func _on_detection_area_area_entered(area):
	if area is Unit and area.team != team:
		if not is_instance_valid(target_unit):
			target_unit = area

func _on_detection_area_area_exited(area):
	if area == target_unit:
		target_unit = null
