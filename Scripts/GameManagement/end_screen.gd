extends Panel

@onready var header_text : Label = $HeaderText

func _ready():
	GameManager.game_ended.connect(set_screen)
	visible = false

func set_screen_color(color: Color):
	self.modulate = color

func set_screen(winning_team : String):
	visible = true
	header_text.text = winning_team + " team has won!"
	
	if winning_team == "PLAYER":
		set_screen_color(Color.GREEN)
	elif winning_team == "ENEMY":
		set_screen_color(Color.RED)

func set_custom_message(message : String):
	visible = true
	header_text.text = message

func _on_menu_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")
