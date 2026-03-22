extends CanvasLayer

@onready var base_panel = $Control/BasePanel
@onready var tg_panel = $Control/TGPanel

@export var wood_label : Label
@export var gold_label : Label
@export var food_label : Label

signal train_soldier_pressed
signal train_worker_pressed

func _ready():
	GameManager.game_ui = self
	
	GameManager.resource_updated.connect(_update_resource)
	GameManager.supply_updated.connect(_update_supply)
	
	hide_actions()

func _update_resource(type : String, amount : int):
	if type == "wood" and wood_label != null:
		wood_label.text = "Dřevo: " + str(amount)
	elif type == "gold" and gold_label != null:
		gold_label.text = "Zlato: " + str(amount)

func _update_supply(current : int, max_amount : int):
	if food_label != null:
		food_label.text = "Jídlo: " + str(current) + " / " + str(max_amount)
		
		if current >= max_amount:
			food_label.modulate = Color.RED
		else:
			food_label.modulate = Color.WHITE

func show_action(action_type : String):
	hide_actions()
	if action_type == "base" and base_panel:
		base_panel.visible = true
	elif action_type == "training" and tg_panel:
		tg_panel.visible = true

func update_ui(selected_object):
	hide_actions()

	if selected_object == null:
		return

	if selected_object is Building:
		if selected_object.can_train_units and base_panel:
			base_panel.visible = true
		elif selected_object.is_training_grounds and tg_panel:
			tg_panel.visible = true

func hide_actions():
	if base_panel:
		base_panel.visible = false
	if tg_panel:
		tg_panel.visible = false

func _on_train_soldier_button_pressed():
	pass
