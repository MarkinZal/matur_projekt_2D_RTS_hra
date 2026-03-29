extends Area2D
class_name Arrow

var speed = 200.0
var damage = 0
var target : Entity = null
var shooter_team = -1

func _ready():
	if has_node("Sprite2D"):
		$Sprite2D.texture = load("res://Assets.2/MiniWorldSprites/Objects/ArrowShort.png")
		$Sprite2D.hframes = 2
		$Sprite2D.vframes = 2
		$Sprite2D.frame = 0

func _physics_process(delta):
	if not is_instance_valid(target) or target.is_queued_for_deletion():
		queue_free()
		return
	
	var target_pos = target.global_position
	var direction = (target_pos - global_position).normalized()
	global_position += direction * speed * delta
	
	rotation = direction.angle() - PI / 2.0
	
	if global_position.distance_to(target_pos) < 20.0:
		_hit_target(target)

func _hit_target(hit_body: Entity):
	if hit_body.has_method("take_damage"):
		hit_body.take_damage(damage)
	queue_free()
