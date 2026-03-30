extends Unit
class_name Archer

@export var arrow_scene = preload("res://Scenes/arrow.tscn")

func _ready():
	super._ready()
	health_max = 30
	health_current = 30
	move_speed = 70.0
	attack_range = 100.0
	attack_rate = 0.9
	attack_damage = 5

func _try_attack():
	if not is_instance_valid(target_unit):
		return
	
	var time = Time.get_unix_time_from_system()
	if time - last_attack_time < attack_rate:
		return
		
	if global_position.distance_to(target_unit.global_position) > attack_range:
		move_to_target(target_unit.global_position)
		return
	
	agent.target_position = global_position
	last_attack_time = time
	
	_spawn_arrow()

func _spawn_arrow():
	if is_instance_valid(target_unit):
		var projectile = arrow_scene.instantiate()
		projectile.global_position = global_position
		projectile.damage = attack_damage
		projectile.target = target_unit
		projectile.shooter_team = team
		get_tree().current_scene.add_child(projectile)
