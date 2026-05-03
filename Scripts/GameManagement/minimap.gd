extends TextureRect

var gm = null
var terrain_texture: ImageTexture = null
var terrain_generated: bool = false

func _ready():
	var managers = get_tree().get_nodes_in_group("game_manager")
	for manager in managers:
		if manager.get("terrain_layer") != null:
			gm = manager
			if gm.has_signal("game_ended"):
				gm.game_ended.connect(_on_game_ended)
			break
			
	if not gm:
		print("KRITICKÁ CHYBA MINIMAPY: Žádný GameManager nemá přiřazený terén!")

func _process(_delta):
	queue_redraw()

func _draw():
	if not gm: return
	
	var tile_size = 16.0
	var map_real_size = Vector2(gm.map_width * tile_size, gm.map_height * tile_size) 
	var scale_factor = size / map_real_size
	var minimap_tile_size = Vector2(size.x / gm.map_width, size.y / gm.map_height)

	if not terrain_generated and is_instance_valid(gm.terrain_layer):
		_vygeneruj_podklad_terenu()
		
	if terrain_texture:
		draw_texture_rect(terrain_texture, Rect2(Vector2.ZERO, size), false)
		
	if is_instance_valid(gm.fog_layer):
		for x in range(gm.map_width):
			for y in range(gm.map_height):
				if gm.fog_layer.get_cell_source_id(Vector2i(x, y)) != -1:
					var rect = Rect2(Vector2(x, y) * minimap_tile_size, minimap_tile_size)
					draw_rect(rect, Color(0, 0, 0, 1.0))

	for u in get_tree().get_nodes_in_group("UnitPlayer"):
		draw_circle(u.global_position * scale_factor, 2.0, Color.GREEN)
		
	for eu in get_tree().get_nodes_in_group("UnitEnemy"):
		if is_instance_valid(gm.fog_layer):
			var map_pos = gm.fog_layer.local_to_map(eu.global_position)
			if gm.fog_layer.get_cell_source_id(map_pos) == -1: 
				draw_circle(eu.global_position * scale_factor, 2.0, Color.RED)
		else:
			draw_circle(eu.global_position * scale_factor, 2.0, Color.RED)
		
	for m in get_tree().get_nodes_in_group("GoldMine"):
		if is_instance_valid(gm.fog_layer):
			var map_pos = gm.fog_layer.local_to_map(m.global_position)
			if gm.fog_layer.get_cell_source_id(map_pos) == -1:
				draw_circle(m.global_position * scale_factor, 2.0, Color.YELLOW)
		else:
			draw_circle(m.global_position * scale_factor, 2.0, Color.YELLOW)
		
	# Budovy
	for b in get_tree().get_nodes_in_group("Buildings"):
		if "team" in b and b.team == Entity.Team.ENEMY:
			if is_instance_valid(gm.fog_layer):
				var map_pos = gm.fog_layer.local_to_map(b.global_position)
				if gm.fog_layer.get_cell_source_id(map_pos) == -1:
					draw_circle(b.global_position * scale_factor, 3.0, Color.DARK_RED)
			else:
				draw_circle(b.global_position * scale_factor, 3.0, Color.DARK_RED)
		else:
			draw_circle(b.global_position * scale_factor, 3.0, Color.AQUA)

func _vygeneruj_podklad_terenu():
	print("Minimap: Generuji terénní podklad...")
	var img = Image.create(gm.map_width, gm.map_height, false, Image.FORMAT_RGB8)
	
	for x in range(gm.map_width):
		for y in range(gm.map_height):
			var pos2d = Vector2i(x, y)
			var color = Color(0.1, 0.1, 0.1)
			
			if gm.terrain_layer:
				var source_id = gm.terrain_layer.get_cell_source_id(pos2d)
				if source_id == gm.water_source_id:
					color = Color("387bb5")
				elif source_id == gm.terrain_source_id:
					color = Color("538d38")
				
			if gm.hill_layer and gm.hill_layer.get_cell_source_id(pos2d) != -1:
				color = Color("5b5b5b")
				
			img.set_pixel(x, y, color)
			
	terrain_texture = ImageTexture.create_from_image(img)
	terrain_generated = true
	print("Minimap: Terénní podklad vygenerován.")

func _on_game_ended(_winner):
	queue_redraw()
	set_process(false)
