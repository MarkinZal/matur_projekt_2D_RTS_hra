extends Unit
class_name SiegeEngine

@onready var sprite = $Sprite

@export var bolt_scene = preload("res://Scenes/bolt.tscn")

func _ready():
	super._ready()
	health_max = 80
	health_current = 80
	move_speed = 30.0
	attack_range = 150.0
	attack_rate = 4.0
	attack_damage = 15

func _process(delta):
	super._process(delta)
	
	if is_instance_valid(target_unit) and is_attacking:
		var direction_to_target = global_position.direction_to(target_unit.global_position)
		sprite.rotation = direction_to_target.angle()
	elif current_velocity.length() > 0.1:
		sprite.rotation = current_velocity.angle()


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
	
	_spawn_boulder()

func _spawn_boulder():
	if is_instance_valid(target_unit):
		var projectile = bolt_scene.instantiate()
		projectile.global_position = global_position
		projectile.damage = attack_damage
		projectile.target = target_unit
		projectile.shooter_team = team
		get_tree().current_scene.add_child(projectile)
