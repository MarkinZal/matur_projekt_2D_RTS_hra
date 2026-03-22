extends ProgressBar

var entity : Entity

func _ready():
	entity = get_parent() as Entity
	visible = false
	
	if entity != null:
		max_value = entity.health_max
		value = entity.health_current
		
		entity.health_changed.connect(_on_health_changed)

func _on_health_changed(new_health : int):
	value = new_health
	visible = value < max_value
