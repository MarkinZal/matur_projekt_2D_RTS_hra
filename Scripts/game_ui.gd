extends CanvasLayer

@onready var action_panel = $Control/ActionPanel

func _ready():
	action_panel.visible = false

func show_action(show : bool):
	action_panel.visible = show
