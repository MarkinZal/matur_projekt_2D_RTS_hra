extends TextureRect

@onready var gm = get_tree().get_first_node_in_group("game_manager")

func _process(delta):
	queue_redraw()

func _draw():
	if not gm: return
	
	var map_real_size = Vector2(gm.map_width * 16, gm.map_height * 16) 
	
	var scale_factor = size / map_real_size
	
	var units = get_tree().get_nodes_in_group("UnitPlayer")
	for u in units:
		draw_circle(u.global_position * scale_factor, 2.0, Color.GREEN)
		
	var mines = get_tree().get_nodes_in_group("GoldMine")
	for m in mines:
		draw_circle(m.global_position * scale_factor, 2.0, Color.YELLOW)
		
	var buildings = get_tree().get_nodes_in_group("Buildings")
	for b in buildings:
		draw_circle(b.global_position * scale_factor, 3.0, Color.AQUA)
