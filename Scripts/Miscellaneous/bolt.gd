extends Area2D
class_name Bolt

var speed = 150.0 
var damage = 0
var target : Entity = null
var shooter_team = -1

func _ready():
	pass

func _physics_process(delta):
	if not is_instance_valid(target) or target.is_queued_for_deletion():
		queue_free()
		return
	
	var target_pos = target.global_position
	var direction = (target_pos - global_position).normalized()
	global_position += direction * speed * delta
	
	rotation = direction.angle() + PI / 2.0
	
	if global_position.distance_to(target_pos) < 25.0:
		_hit_target(target)

func _hit_target(hit_body: Entity):
	if hit_body.has_method("take_damage"):
		hit_body.take_damage(damage)
	queue_free()
