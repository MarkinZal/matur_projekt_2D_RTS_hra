extends Area2D
class_name Unit

signal health_changed (health : int)
signal unit_death (unit : Unit)

@export_group("Atributy")
@export var move_speed : float = 30.0
@export var health_max : int = 20
@export var health_current : int = 20

@export_group("Utok")
@export var attack_range : float = 20.0
@export var attack_rate : float = 0.5
@export var attack_damage : int = 5

enum Team { PLAYER, ENEMY }
@export var team : Team

var target_unit : Unit = null
var last_attack_time : float = 0.0

@onready var agent : NavigationAgent2D = $NavigationAgent2D


func _process (delta):
	if not agent.is_navigation_finished():
		_move(delta)
	
	_utok_logic()

func _move (delta):
	var next_position = agent.get_next_path_position()
	var direction = global_position.direction_to(next_position)
	var movement = direction * move_speed * delta
	
	translate(movement)


func _utok_logic ():
	if target_unit == null:
		return
	
	var distance = global_position.distance_to(target_unit.global_position)
	
	if distance <= attack_range:
		agent.target_position = global_position
		_try_attack()
	else:
		agent.target_position = target_unit.global_position

func _try_attack ():
	var time = Time.get_unix_time_from_system()
	
	if time - last_attack_time < attack_rate:
		return
	
	last_attack_time = time
	target_unit.take_damage(attack_damage)

func move_to_target (target : Vector2):
	agent.target_position = target
	target_unit = null

func set_target (target : Unit):
	if target.team == team:
		return
	
	target_unit = target

func take_damage (amount : int):
	health_current -= amount
	health_changed.emit(health_current)
	
	if health_current <= 0:
		_die()

func _die ():
	unit_death.emit(self)
	queue_free()
