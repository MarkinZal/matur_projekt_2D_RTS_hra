extends Node2D

@export var trees_to_cut_count : int = 3 
var current_cut_trees : int = 0


@onready var end_screen = $Scripts/end_screen

func _ready():
	var trees = get_tree().get_nodes_in_group("Tree")
	
	for tree in trees:
		if tree.has_signal("tree_destroyed"):
			tree.tree_destroyed.connect(_on_tree_destroyed)

func _on_tree_destroyed():
	current_cut_trees += 1
	print("Pokáceno stromů: ", current_cut_trees)
	
	if current_cut_trees >= trees_to_cut_count:
		finish_tutorial()

func finish_tutorial():
	if end_screen:
		end_screen.set_custom_message("Tutorial completed!")
