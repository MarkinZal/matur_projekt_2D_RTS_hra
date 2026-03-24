extends Building
class_name BaseBuilding

var unit_scene = preload("res://Scenes/unit_player.tscn")
var worker_scene = preload("res://Scenes/unit_worker.tscn")

var cost_soldier = {"wood": 10, "gold": 5, "food": 1}
var cost_worker = {"wood": 5, "gold": 0, "food": 1}

func _ready():
	can_train_units = true
	health_max = 200
	health_current = 200

func _input(event):
	if not is_selected:
		return
	if event.is_action_pressed("train_soldier"):
		if GameManager.try_spend_resources(cost_soldier.wood, cost_soldier.gold, cost_soldier.food):
			spawn_unit(unit_scene)
	elif event.is_action_pressed("train_worker"):
		if GameManager.try_spend_resources(cost_worker.wood, cost_worker.gold, cost_worker.food):
			spawn_unit(worker_scene)

func spawn_unit(scene_to_spawn):
	var new_unit = scene_to_spawn.instantiate()
	var angle = randf() * PI * 2
	var distance = randf_range(50.0, 80.0)
	var offset = Vector2(cos(angle), sin(angle)) * distance
	new_unit.global_position = global_position + offset
	get_parent().add_child(new_unit)

func _die():
	GameManager.base_destroyed(team)
	super._die()
