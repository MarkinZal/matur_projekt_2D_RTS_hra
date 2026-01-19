extends Unit
class_name Worker

func _ready():
	move_speed = 60.0
	health_max = 20
	health_current = 20
	attack_range = 10.0
	attack_damage = 5
	attack_rate = 1.0


func _process(delta):
	super._process(delta)

func _try_attack():
	if not is_instance_valid(target_unit):
		return
		
	if target_unit.is_in_group("Tree"):
		if attack_rate <= 0:
			target_unit.take_damage(attack_damage)
			attack_rate = attack_rate
