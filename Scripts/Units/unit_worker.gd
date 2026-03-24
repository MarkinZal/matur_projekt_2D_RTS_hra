extends Unit
class_name Worker

var is_building: bool = false
var build_position: Vector2
var scene_to_build: PackedScene
var build_range: float = 60.0

func _ready():
	super._ready()
	move_speed = 60.0
	health_max = 20
	health_current = 20
	attack_range = 15
	attack_damage = 5
	attack_rate = 1.0

func command_build(pos: Vector2, scene: PackedScene):
	is_building = true
	build_position = pos
	scene_to_build = scene
	move_to_target(pos)

func _process(delta):
	super._process(delta)
	
	if is_building:
		if global_position.distance_to(build_position) <= build_range:
			_perform_build()

func _perform_build():
	is_building = false
	agent.target_position = global_position
	
	var building_instance = scene_to_build.instantiate()
	building_instance.global_position = build_position
	building_instance.team = team
	get_tree().current_scene.add_child(building_instance)

func set_target(target: Node2D):
	if target is Entity and target.team != team:
		target_unit = null
		return
		
	super.set_target(target)

func _try_attack():
	if not is_instance_valid(target_unit):
		return
		
	if target_unit.is_in_group("GoldMine"):
		if target_unit.add_worker(self):
			target_unit = null
		return
		
	var time = Time.get_unix_time_from_system()
	if time - last_attack_time < attack_rate:
		return
		
	if target_unit.is_in_group("Tree"):
		last_attack_time = time
		if target_unit.has_method("take_damage"):
			target_unit.take_damage(attack_damage)
