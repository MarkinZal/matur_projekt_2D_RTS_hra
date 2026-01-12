extends ProgressBar

@onready var unit : Unit = get_parent()

func _ready ():
	max_value = unit.health_max
	value = max_value
	visible = false
	
	unit.health_changed.connect(_update_value)

func _update_value (health : int):
	value = health
	visible = value < max_value
