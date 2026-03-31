extends Entity
class_name Building

var is_selected: bool = false
var can_train_units: bool = false
var is_training_grounds: bool = false

func _ready():
	add_to_group("Unit")
	add_to_group("Buildings")
