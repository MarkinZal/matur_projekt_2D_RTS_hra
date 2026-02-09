extends Panel

@onready var header_text : Label = $HeaderText

func _ready():
	GameManager.game_ended.connect(set_screen)
	visible = false

func set_screen (winning_team : String):
	visible = true
	header_text.text = winning_team + " team has won!"
	get_tree().paused = true

func set_custom_message(message : String):
	visible = true
	header_text.text = message

func _on_menu_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")
