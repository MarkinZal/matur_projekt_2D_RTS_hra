extends Entity
class_name Unit

@export var move_speed: float = 30.0
@export var attack_range: float = 20.0
@export var attack_rate: float = 0.5
@export var attack_damage: int = 1
@export var separation_radius: float = 35.0
@export var separation_strength: float = 200.0
@export var vision_radius : int = 5

var target_unit: Node2D = null
var last_attack_time: float = 0.0
var base_health_max: int
var base_attack_damage: int

@onready var agent: NavigationAgent2D = $NavigationAgent2D
@onready var animation_tree: AnimationTree = get_node_or_null("AnimationTree")

var current_velocity: Vector2 = Vector2.ZERO
var last_facing_direction: Vector2 = Vector2.DOWN
var is_attacking: bool = false

func _ready():
	add_to_group("Unit")
	add_to_group("UnitPlayer")
	GameManager.register_unit(self)
	base_health_max = health_max
	base_attack_damage = attack_damage
	if team == Team.PLAYER:
		GameManager.global_upgrades_changed.connect(_on_upgrade_received)
		_on_upgrade_received()
		
	if animation_tree:
		animation_tree.active = true

func _process(delta):
	if not agent.is_navigation_finished():
		_move(delta)
	else:
		current_velocity = Vector2.ZERO
		
	_utok_logic()
	_update_animation_tree()
	

func _move(delta):
	var next_position = agent.get_next_path_position()
	var direction = global_position.direction_to(next_position)
	var velocity = direction * move_speed
	var separation = Vector2.ZERO
	var neighbors = get_overlapping_areas()
	var count = 0
	
	for neighbor in neighbors:
		if neighbor is Unit and neighbor != self:
			var dist = global_position.distance_to(neighbor.global_position)
			if dist < separation_radius:
				var push_dir = global_position - neighbor.global_position
				if dist < 0.1:
					push_dir = Vector2(randf_range(-1, 1), randf_range(-1, 1))
					dist = 0.1
				separation += push_dir.normalized() / dist
				count += 1
	
	if count > 0:
		separation = separation / count * separation_strength
		velocity += separation
	
	current_velocity = velocity
	translate(velocity * delta)

func _utok_logic():
	if not is_instance_valid(target_unit):
		is_attacking = false
		return
		
	var distance = global_position.distance_to(target_unit.global_position)
	if distance <= attack_range:
		agent.target_position = global_position
		is_attacking = true
		_try_attack()
	else:
		agent.target_position = target_unit.global_position
		is_attacking = false

func _try_attack():
	var time = Time.get_unix_time_from_system()
	if time - last_attack_time < attack_rate:
		return
	last_attack_time = time
	
	if target_unit.has_method("take_damage"):
		target_unit.take_damage(attack_damage)

func move_to_target(target: Vector2):
	agent.target_position = target
	target_unit = null

func set_target(target: Node2D):
	if target is Entity and target.team == team:
		return
	target_unit = target

func _on_upgrade_received():
	var health_missing = health_max - health_current
	health_max = base_health_max + GameManager.global_bonus_hp
	attack_damage = base_attack_damage + GameManager.global_bonus_damage
	health_current = health_max - health_missing
	health_changed.emit(health_current)

func _update_animation_tree():
	if not animation_tree:
		return
		
	if current_velocity.length() > 0.1:
		last_facing_direction = current_velocity.normalized()
		
	if is_attacking and is_instance_valid(target_unit):
		last_facing_direction = global_position.direction_to(target_unit.global_position)

	animation_tree.set("parameters/Move/blend_position", last_facing_direction)
	animation_tree.set("parameters/Idle/blend_position", last_facing_direction)
	animation_tree.set("parameters/Attack/blend_position", last_facing_direction)
	
	if is_attacking:
		animation_tree.set("parameters/conditions/is_attacking", true)
		animation_tree.set("parameters/conditions/is_moving", false)
		animation_tree.set("parameters/conditions/is_idle", false)
	elif current_velocity.length() > 0.1:
		animation_tree.set("parameters/conditions/is_attacking", false)
		animation_tree.set("parameters/conditions/is_moving", true)
		animation_tree.set("parameters/conditions/is_idle", false)
	else:
		animation_tree.set("parameters/conditions/is_attacking", false)
		animation_tree.set("parameters/conditions/is_moving", false)
		animation_tree.set("parameters/conditions/is_idle", true)
