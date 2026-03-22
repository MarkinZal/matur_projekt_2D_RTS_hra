extends Building
class_name Barracks

@export var food_supply_amount: int = 5

func _ready():
	GameManager.increase_food_cap(food_supply_amount)

func _die():
	GameManager.increase_food_cap(-food_supply_amount)
	super._die()
