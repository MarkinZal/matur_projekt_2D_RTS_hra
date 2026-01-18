extends Node

@onready var unit : Unit = get_parent()

var detection_range : float = 400.0
var scan_timer : float = 0.0
var scan_interval : float = 0.25

func _process(delta):
	if unit == null or not is_instance_valid(unit) or unit.health_current <= 0:
		return
	
	if is_instance_valid(unit.target_unit):
		var dist = unit.global_position.distance_to(unit.target_unit.global_position)
		if dist > detection_range * 1.5:
			unit.target_unit = null

	scan_timer -= delta
	if scan_timer <= 0:
		scan_timer = scan_interval
		_find_closest_enemy()

func _find_closest_enemy():
	var shortest_dist = detection_range
	var closest_target = null
	
	var all_units = get_tree().get_nodes_in_group("Unit")
	
	for target in all_units:
		if not is_instance_valid(target):
			continue
			
		if target == unit:
			continue
		
		if target.team == unit.team:
			continue
			
		var dist = unit.global_position.distance_to(target.global_position)
		
		if dist < shortest_dist:
			shortest_dist = dist
			closest_target = target
	
	if closest_target != null:
		unit.set_target(closest_target)
