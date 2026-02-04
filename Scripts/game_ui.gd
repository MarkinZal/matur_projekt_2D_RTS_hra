extends CanvasLayer

@onready var action_panel = $Control/ActionPanel

@export var wood_label : Label
@export var gold_label : Label
@export var food_label : Label

func _ready():
	action_panel.visible = false
	
	if get_node("/root/GameManager"): 
		var gm = get_node("/root/GameManager")
		if gm.has_signal("resource_updated"):
			gm.resource_updated.connect(_update_resource)

func show_action(show : bool):
	action_panel.visible = show

func _update_resource(type : String, amount : int):
	if type == "wood" and wood_label != null:
		wood_label.text = "Dřevo: " + str(amount)
	elif type == "gold" and gold_label != null:
		gold_label.text = "Zlato: " + str(amount)
	elif type == "food" and food_label != null:
		food_label.text = "Jídlo: " + str(amount)
