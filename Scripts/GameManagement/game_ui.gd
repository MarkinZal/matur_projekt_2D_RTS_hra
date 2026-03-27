extends CanvasLayer

@onready var base_panel = $Control/BasePanel
@onready var tg_panel = $Control/TGPanel
@onready var worker_panel = $Control/WorkerPanel
@onready var mine_panel = $Control/MinePanel
@onready var mine_akce = $Control/MinePanel/MineAkce

@export var wood_label : Label
@export var gold_label : Label
@export var food_label : Label
@export var build_indicator_label : Label

signal train_soldier_pressed
signal train_worker_pressed
signal build_mode_requested(building_type: String)

func _ready():
	GameManager.game_ui = self
	
	GameManager.resource_updated.connect(_update_resource)
	GameManager.supply_updated.connect(_update_supply)
	
	hide_actions()
	hide_build_indicator()

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
	elif selected_object is Worker and worker_panel:
		worker_panel.visible = true
	elif selected_object.is_in_group("GoldMine") and mine_panel:
		mine_panel.visible = true
		if mine_akce:
			mine_akce.text = "[E] Odstranit dělníka " + str(selected_object.current_workers.size()) + " / " + str(selected_object.max_workers)

func hide_actions():
	if base_panel:
		base_panel.visible = false
	if tg_panel:
		tg_panel.visible = false
	if worker_panel:
		worker_panel.visible = false
	if mine_panel:
		mine_panel.visible = false

func set_build_indicator(text: String):
	if build_indicator_label:
		build_indicator_label.text = text
		build_indicator_label.visible = true

func hide_build_indicator():
	if build_indicator_label:
		build_indicator_label.visible = false

func _on_build_barracks_pressed():
	build_mode_requested.emit("barracks")

func _on_build_tower_pressed():
	build_mode_requested.emit("tower")

func _on_build_tg_pressed():
	build_mode_requested.emit("training_grounds")

func _on_train_soldier_button_pressed():
	pass
