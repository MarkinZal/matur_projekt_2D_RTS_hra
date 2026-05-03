extends Building
class_name Barracks

@export var food_supply_amount: int = 5

var scene_melee = preload("res://Scenes/player_scenes/unit_player.tscn")
var scene_ranged = preload("res://Scenes/player_scenes/unit_archer.tscn")

var cost_melee = {"wood": 10, "gold": 5, "food": 1}
var cost_ranged = {"wood": 15, "gold": 15, "food": 1}

func _ready():
	super._ready()
	
	can_train_units = true
	
	if team == Entity.Team.PLAYER:
		GameManager.increase_food_cap(food_supply_amount)


func _input(event):
	if not is_selected or team != Entity.Team.PLAYER:
		return
		
	if event.is_action_pressed("train_melee"):
		_try_train_unit(scene_melee, cost_melee)
	elif event.is_action_pressed("train_ranged"):
		_try_train_unit(scene_ranged, cost_ranged)

func _try_train_unit(unit_scene: PackedScene, cost: Dictionary):
	if GameManager.current_food + cost.food > GameManager.max_food:
		print("Není dostatek míst v domech!")
		return
		
	if GameManager.try_spend_resources(cost.wood, cost.gold, cost.food):
		_spawn_unit(unit_scene)
	else:
		print("Nemáš suroviny!")


func _spawn_unit(scene_to_spawn: PackedScene):
	if scene_to_spawn:
		var new_unit = scene_to_spawn.instantiate()
		
		var angle = randf() * PI * 2
		var distance = randf_range(40.0, 50.0)
		var offset = Vector2(cos(angle), sin(angle)) * distance
		new_unit.global_position = global_position + offset
		
		new_unit.team = self.team 
		
		get_parent().add_child(new_unit)

func _die():
	if team == Entity.Team.PLAYER:
		GameManager.increase_food_cap(-food_supply_amount)
	super._die()
