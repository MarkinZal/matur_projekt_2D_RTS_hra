extends Unit
class_name Building

var is_selected : bool = false
var unit_scene = preload("res://Scenes/unit_player.tscn")
var worker_scene = preload("res://Scenes/unit_worker.tscn")

func _ready():
	move_speed = 0.0

func _process(delta):
	pass

func _input(event):
	if not is_selected:
		return
		
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_Y:
			spawn_unit(unit_scene)
		elif event.keycode == KEY_X:
			spawn_unit(worker_scene)

func spawn_unit(scene_to_spawn):
	var new_unit = scene_to_spawn.instantiate()
	
	var angle = randf() * PI * 2
	var distance = randf_range(50.0, 80.0)
	var offset = Vector2(cos(angle), sin(angle)) * distance
	
	new_unit.global_position = global_position + offset
	get_parent().add_child(new_unit)

func move_to_target(target: Vector2):
	pass
