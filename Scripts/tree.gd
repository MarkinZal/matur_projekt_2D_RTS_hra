extends Area2D
class_name ResourceTree

var health : int = 25
var is_dead : bool = false
var wood_per_hit : int = 1

signal tree_destroyed

@onready var sprite_tree = $SpriteTree
@onready var sprite_stump = $SpriteStump
@onready var collision_shape = $CollisionShape2D
@onready var nav_obstacle = $NavigationObstacle2D
@onready var health_bar = $ProgressBar
@onready var hide_timer = $HideTimer

func _ready():
	add_to_group("Tree")
	
	sprite_tree.visible = true
	sprite_stump.visible = false
	health_bar.visible = false
	
	health_bar.max_value = health
	health_bar.value = health
	
	hide_timer.timeout.connect(_on_hide_timer_timeout)

func take_damage(amount):
	if is_dead:
		return
	
	health -= amount
	
	GameManager.add_wood(wood_per_hit)
	
	health_bar.visible = true
	health_bar.value = health
	
	hide_timer.start()
	
	if health <= 0:
		die()

func die():
	is_dead = true
	sprite_tree.visible = false
	sprite_stump.visible = true
	health_bar.visible = false
	
	if collision_shape:
		collision_shape.set_deferred("disabled", true)
	
	nav_obstacle.queue_free()
	
	tree_destroyed.emit()

func _on_hide_timer_timeout():
	health_bar.visible = false
