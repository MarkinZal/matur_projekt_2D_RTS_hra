extends Node

var unit_counts = {
	Unit.Team.PLAYER: 0,
	Unit.Team.ENEMY: 0
}

signal resource_updated(resource_type: String, amount: int)
var drevo : int = 0
var zlato : int = 0
var jidlo : int = 0

@export var end_screen : Node
@export var unit_controller : Node2D 

func _ready ():
	var all_units = get_tree().get_nodes_in_group("Unit")
	
	for unit in all_units:
		if unit is Unit:
			unit_counts[unit.team] += 1
			unit.unit_death.connect(_on_unit_die)
	resource_updated.emit("wood", drevo)

func add_resource(type: String, amount: int):
	match type:
		"wood":
			drevo += amount
			resource_updated.emit("wood", drevo)
		"gold":
			zlato += amount
			resource_updated.emit("gold", zlato)
		"food":
			jidlo += amount
			resource_updated.emit("food", jidlo)

func try_spend_resources(wood_cost: int, gold_cost: int, food_cost: int) -> bool:
	if drevo >= wood_cost and zlato >= gold_cost and jidlo >= food_cost:
		drevo -= wood_cost
		zlato -= gold_cost
		jidlo -= food_cost
		
		resource_updated.emit("wood", drevo)
		resource_updated.emit("gold", zlato)
		resource_updated.emit("food", jidlo)
		return true
	return false

func _on_unit_die (unit : Unit):
	unit_counts[unit.team] -= 1
	_check_game_over()

func _check_game_over ():
	var winner = 0
	var teams_alive = 0
	
	for team in unit_counts:
		if unit_counts[team] > 0:
			teams_alive += 1
			winner = team
	
	if teams_alive > 1:
		return
	
	if unit_controller != null:
		unit_controller._deselect_all()
		unit_controller.set_process_input(false)
	
	if end_screen != null:
		var team_name = Unit.Team.keys()[winner]
		end_screen.set_screen(team_name)
