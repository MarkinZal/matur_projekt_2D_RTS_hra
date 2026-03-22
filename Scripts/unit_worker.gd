extends Unit
class_name Worker

func _ready():
	super._ready()
	move_speed = 60.0
	health_max = 20
	health_current = 20
	attack_range = 15.0
	attack_damage = 5
	attack_rate = 1.0

func _try_attack():
	if not is_instance_valid(target_unit):
		return
		
	if target_unit.is_in_group("GoldMine"):
		if target_unit.add_worker(self):
			target_unit = null
		return
		
	var time = Time.get_unix_time_from_system()
	if time - last_attack_time < attack_rate:
		return
		
	if target_unit.is_in_group("Tree") or target_unit.has_method("take_damage"):
		last_attack_time = time
		target_unit.take_damage(attack_damage)
