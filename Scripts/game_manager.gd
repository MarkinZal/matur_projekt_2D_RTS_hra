extends Node

var unit_counts = {
	Unit.Team.PLAYER: 0,
	Unit.Team.ENEMY: 0
}

signal resource_updated(resource_type: String, amount: int)
signal supply_updated(current: int, max_amount: int)

var drevo : int = 100
var zlato : int = 100

var current_food : int = 0
var max_food : int = 10

var game_ui : CanvasLayer

func _ready():
	resource_updated.emit("wood", drevo)
	resource_updated.emit("gold", zlato)
	supply_updated.emit(current_food, max_food)

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
	if food_cost > 0:
		if current_food + food_cost > max_food:
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
