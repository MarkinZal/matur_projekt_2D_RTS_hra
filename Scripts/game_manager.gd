extends Node2D

var units = {
	Unit.Team.Player: 0,
	Unit.Team.AI: 0
}

@onready var end_screen = $CanvasLayer/EndScreen

func _ready ():
	for unit in get_tree().get_nodes_in_group("Unit"):
		if unit is not Unit:
			continue
		
		units[unit.team] += 1
		unit.OnDie.connect(_on_unit_die)

func _on_unit_die (unit : Unit):
	units[unit.team] -= 1
	_check_win_condition()

func _check_win_condition ():
	var winner = 0
	var teams_alive = 0
	
	for team in units:
		if units[team] > 0:
			teams_alive += 1
			winner = team
	
	if teams_alive > 1:
		return
	
	var team_name = Unit.Team.keys()[winner]
	end_screen.set_screen(team_name)
