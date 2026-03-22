extends Node

signal resource_updated(resource_type: String, amount: int)
signal supply_updated(current: int, max_amount: int)
signal game_ended(winning_team_name: String)
signal global_upgrades_changed

var drevo: int = 100
var zlato: int = 100
var current_food: int = 0
var max_food: int = 10

var global_bonus_hp: int = 0
var global_bonus_damage: int = 0

var unit_counts = {
	Entity.Team.PLAYER: 0,
	Entity.Team.ENEMY: 0
}

var game_ui: CanvasLayer

func _ready():
	resource_updated.emit("wood", drevo)
	resource_updated.emit("gold", zlato)
	supply_updated.emit(current_food, max_food)

func register_unit(unit: Unit):
	if unit.team in unit_counts:
		unit_counts[unit.team] += 1

func add_resource(type: String, amount: int):
	match type:
		"wood":
			drevo += amount
			resource_updated.emit("wood", drevo)
		"gold":
			zlato += amount
			resource_updated.emit("gold", zlato)

func increase_food_cap(amount: int):
	max_food += amount
	supply_updated.emit(current_food, max_food)

func use_food(amount: int):
	current_food += amount
	supply_updated.emit(current_food, max_food)

func free_food(amount: int):
	current_food -= amount
	if current_food < 0: current_food = 0
	supply_updated.emit(current_food, max_food)

func try_spend_resources(wood_cost: int, gold_cost: int, food_cost: int) -> bool:
	if food_cost > 0 and current_food + food_cost > max_food:
		return false

	if drevo >= wood_cost and zlato >= gold_cost:
		drevo -= wood_cost
		zlato -= gold_cost
		if food_cost > 0:
			use_food(food_cost)
		resource_updated.emit("wood", drevo)
		resource_updated.emit("gold", zlato)
		return true
		
	return false

func purchase_upgrade() -> bool:
	if try_spend_resources(50, 50, 0):
		global_bonus_hp += 10
		global_bonus_damage += 3
		global_upgrades_changed.emit()
		return true
	return false

func base_destroyed(losing_team: int):
	var winner_name = "Nikdo"
	if losing_team == Entity.Team.ENEMY:
		winner_name = "PLAYER"
	elif losing_team == Entity.Team.PLAYER:
		winner_name = "ENEMY"
	game_ended.emit(winner_name)
