extends Unit
class_name UnitSiege

func _ready():
	super._ready()
	move_speed = 20.0
	health_max = 25
	health_current = 25
	attack_range = 150.0
	attack_rate = 2.5
	attack_damage = 15

func _try_attack():
	var time = Time.get_unix_time_from_system()
	if time - last_attack_time < attack_rate:
		return
	
	if is_instance_valid(target_unit) and target_unit.has_method("take_damage"):
		last_attack_time = time
		
		var final_damage = attack_damage
		if target_unit is Building:
			final_damage *= 3 
			
		target_unit.take_damage(final_damage)
