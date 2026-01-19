extends Node

var unit_counts = {
	Unit.Team.PLAYER: 0,
	Unit.Team.ENEMY: 0
}

signal resource_updated(resource_type: String, amount: int)
var drevo : int = 0


@export var end_screen : Node
@export var unit_controller : Node2D 

func _ready ():
	var all_units = get_tree().get_nodes_in_group("Unit")
	
	for unit in all_units:
		if unit is Unit:
			unit_counts[unit.team] += 1
			unit.unit_death.connect(_on_unit_die)
	resource_updated.emit("wood", drevo)

func add_wood(amount : int):
	drevo += amount
	resource_updated.emit("wood", drevo)

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
