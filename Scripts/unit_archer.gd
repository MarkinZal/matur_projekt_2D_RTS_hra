extends Unit
class_name UnitArcher

func _ready():
	super._ready()
	
	move_speed = 40.0
	health_max = 12
	health_current = 12
	
	attack_range = 120.0
	attack_rate = 1.0
	attack_damage = 8
