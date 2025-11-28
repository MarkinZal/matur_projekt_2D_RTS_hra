extends Area2D
class_name Unit

signal OnTakeDamage (health : int)
signal OnDie (unit : Unit)

@export var move_speed : float = 30.0

@export var cur_hp : int = 20
@export var max_hp : int = 20

@export var attack_range : float = 20.0
@export var attack_rate : float = 0.5
var last_attack_time : float
@export var attack_damage : int = 5

enum Team { Player, AI }
@export var team : Team

var attack_target : Unit

@onready var agent : NavigationAgent2D = $NavigationAgent2D

func _ready():
	set_move_to_target(Vector2.ZERO)

func _process (delta):
	_move(delta)

func _move (delta):
	var move_pos = agent.get_next_path_position()
	var move_dir = global_position.direction_to(move_pos)
	var movement = move_dir * move_speed * delta
	
	translate(movement)


func _target_check ():
	pass

func _try_attack_target ():
	pass

func set_move_to_target (target : Vector2):
	agent.target_position = target
	attack_target = null

func set_attack_target (target : Unit):
	pass

func take_damage (amount : int):
	pass

func _die ():
	pass
