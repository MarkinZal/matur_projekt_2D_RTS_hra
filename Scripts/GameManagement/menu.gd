extends Control

func _on_play_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/main.tscn")

func _on_load_button_pressed():
	Global.chci_nacist_hru = true
	get_tree().change_scene_to_file("res://Scenes/main.tscn")

func _on_tutorial_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/tutorial.tscn")

func _on_quit_button_pressed():
	get_tree().quit()
