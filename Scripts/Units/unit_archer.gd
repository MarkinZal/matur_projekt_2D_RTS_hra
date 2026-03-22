extends Unit
class_name UnitRanged

func _ready():
	super._ready()
	move_speed = 40.0
	health_max = 10
	health_current = 10
	attack_range = 150.0
	attack_damage = 8
	attack_rate = 1.0
