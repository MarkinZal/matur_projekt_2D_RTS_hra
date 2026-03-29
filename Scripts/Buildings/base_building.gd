extends Building
class_name BaseBuilding

var scene_melee = preload("res://Scenes/unit_player.tscn")
var scene_worker = preload("res://Scenes/unit_worker.tscn")
var scene_ranged = preload("res://Scenes/unit_archer.tscn")
var scene_siege = preload("res://Scenes/unit_siege.tscn")

var cost_melee = {"wood": 10, "gold": 5, "food": 1}
var cost_worker = {"wood": 5, "gold": 0, "food": 1}
var cost_ranged = {"wood": 15, "gold": 15, "food": 1}
var cost_siege = {"wood": 50, "gold": 30, "food": 2}

func _ready():
	can_train_units = true
	health_max = 200
	health_current = 200

func _input(event):
	if not is_selected:
		return
		
	if event.is_action_pressed("train_melee"):
		_try_train_unit(scene_melee, cost_melee)
	elif event.is_action_pressed("train_worker"):
		_try_train_unit(scene_worker, cost_worker)
	elif event.is_action_pressed("train_ranged"):
		_try_train_unit(scene_ranged, cost_ranged)
	elif event.is_action_pressed("train_siege"):
		_try_train_unit(scene_siege, cost_siege)

func _try_train_unit(unit_scene: PackedScene, cost: Dictionary):
	if GameManager.current_food + cost.food > GameManager.max_food:
		print("Neni dostatek mist v domech!")
		return
		
	if GameManager.try_spend_resources(cost.wood, cost.gold, cost.food):
		_spawn_unit(unit_scene)
	else:
		print("Nemas suroviny!")

func _spawn_unit(scene_to_spawn: PackedScene):
	var new_unit = scene_to_spawn.instantiate()
	var angle = randf() * PI * 2
	var distance = randf_range(30.0, 30.0)
	var offset = Vector2(cos(angle), sin(angle)) * distance
	new_unit.global_position = global_position + offset
	new_unit.team = team
	get_parent().add_child(new_unit)

func _die():
	GameManager.base_destroyed(team)
	super._die()
