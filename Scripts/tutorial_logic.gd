extends Node2D

var total_trees_count : int = 0
var current_cut_trees : int = 0

@export var end_screen : Control 

func _ready():
	var trees = get_tree().get_nodes_in_group("Tree")
	
	total_trees_count = trees.size()
	print("Celkem stromů na mapě: ", total_trees_count)
	
	if total_trees_count == 0:
		print("Varování: Žádné stromy nenalezeny!")
		finish_tutorial()
		return

	for tree in trees:
		if tree.has_signal("tree_destroyed"):
			tree.tree_destroyed.connect(_on_tree_destroyed)

func _on_tree_destroyed():
	current_cut_trees += 1
	print("Pokáceno: ", current_cut_trees, " / ", total_trees_count)
	
	if current_cut_trees >= total_trees_count:
		finish_tutorial()

func finish_tutorial():
	if end_screen:
		if end_screen.has_method("set_custom_message"):
			end_screen.set_custom_message("Tutorial Dokončen!")
		else:
			end_screen.visible = true
			var label = end_screen.get_node_or_null("HeaderText")
			if label:
				label.text = "Tutorial Dokončen!"
	else:
		print("CHYBA: Není připojen EndScreen v Inspektoru!")
