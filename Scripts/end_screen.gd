extends Panel

@onready var header_text : Label = $HeaderText

func set_screen (winning_team : String):
	visible = true
	header_text.text = winning_team + " team has won!"

func _on_menu_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")
