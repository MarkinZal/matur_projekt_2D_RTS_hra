extends Area2D
class_name Entity

signal health_changed(health: int)
signal entity_death(entity: Entity)

enum Team { PLAYER, ENEMY }
@export var team: Team

@export var health_max: int = 20
@export var health_current: int = 20

func take_damage(amount: int):
	health_current -= amount
	health_changed.emit(health_current)
	if health_current <= 0:
		_die()

func _die():
	entity_death.emit(self)
	queue_free()
