extends CanvasLayer

@onready var action_panel = $Control/ActionPanel

@export var wood_label : Label

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
