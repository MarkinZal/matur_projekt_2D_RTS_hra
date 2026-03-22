extends Building
class_name DefenseTower

func _ready():
	super._ready()
	can_train_units = false
	
	health_max = 100
	health_current = 100
	
	attack_range = 150.0
	attack_rate = 1.0
	attack_damage = 10

func _process(delta):
	_utok_logic()

func _input(event):
	pass

func _on_detection_area_area_entered(area):
	if area is Unit and area.team != team:
		if not is_instance_valid(target_unit):
			target_unit = area

func _on_detection_area_area_exited(area):
	if area == target_unit:
		target_unit = null
