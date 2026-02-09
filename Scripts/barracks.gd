extends Building
class_name BarracksBuilding

@export var food_supply_amount : int = 5

func _ready():
	super._ready()
	GameManager.increase_food_cap(food_supply_amount)

func _input(event):
	pass

func _die():
	GameManager.increase_food_cap(-food_supply_amount)
	queue_free()
