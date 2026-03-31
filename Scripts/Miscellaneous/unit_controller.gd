extends Node2D

var selected_units : Array = []
var dragging : bool = false
var drag_start : Vector2 = Vector2.ZERO
var is_drag_active : bool = false

var build_mode: bool = false
var current_build_type: String = ""
var ghost_sprite: Sprite2D = null
var is_choosing_building: bool = false

var scene_barracks = preload("res://Scenes/player_scenes/barracks.tscn")
var scene_tower = preload("res://Scenes/player_scenes/barracks.tscn")
var scene_tg = preload("res://Scenes/player_scenes/training_grounds.tscn")

func _ready():
	z_index = 100
	await get_tree().process_frame
	if GameManager.game_ui != null:
		GameManager.game_ui.build_mode_requested.connect(_on_build_mode_requested)

func _input(event):
	var has_worker = false
	var valid_units = []
	
	for entity in selected_units:
		if is_instance_valid(entity):
			valid_units.append(entity)
			if entity is Worker:
				has_worker = true
				
	selected_units = valid_units

	if has_worker:
		if event.is_action_pressed("open_build_menu"):
			is_choosing_building = true
			
		if is_choosing_building or build_mode:
			if event.is_action_pressed("select_barracks"):
				_on_build_mode_requested("barracks")
			elif event.is_action_pressed("select_tower"):
				_on_build_mode_requested("tower")
			elif event.is_action_pressed("select_tg"):
				_on_build_mode_requested("training_grounds")

	if build_mode and event.is_action_pressed("right_click"):
		build_mode = false
		is_choosing_building = false
		if is_instance_valid(ghost_sprite): ghost_sprite.queue_free()
		if GameManager.game_ui != null: GameManager.game_ui.hide_build_indicator()
		return
		
	if build_mode and event.is_action_pressed("left_click"):
		var pos = get_global_mouse_position()
		if _can_place_building(pos):
			_confirm_build(pos)
		else:
			print("Zde nelze stavět nebo nemáš suroviny!")
		return

	if event.is_action_pressed("left_click"):
		dragging = true
		drag_start = get_global_mouse_position()
		is_drag_active = false
	elif event.is_action_released("left_click"):
		dragging = false
		queue_redraw()
		
		if not is_drag_active:
			_select_entity_at_point(get_global_mouse_position())
		
		is_drag_active = false
		_update_ui()
	
	elif event is InputEventMouseMotion and dragging:
		var current_pos = get_global_mouse_position()
		
		if not is_drag_active and drag_start.distance_to(current_pos) > 10:
			is_drag_active = true
			_deselect_all()
			
		if is_drag_active:
			queue_redraw()
			_update_selection_in_box(drag_start, current_pos)

	elif event.is_action_pressed("right_click"):
		_command_selected_units()

func _draw():
	if dragging and is_drag_active:
		var current_pos = get_global_mouse_position()
		var rect = Rect2(to_local(drag_start), to_local(current_pos) - to_local(drag_start))
		draw_rect(rect, Color(0, 1, 0, 0.2), true)
		draw_rect(rect, Color(0, 1, 0, 1), false, 2.0)

func _update_selection_in_box(start : Vector2, end : Vector2):
	var space = get_world_2d().direct_space_state
	var query = PhysicsShapeQueryParameters2D.new()
	var shape = RectangleShape2D.new()
	
	var center = (start + end) / 2
	var size = (end - start).abs()
	
	shape.size = size
	query.shape = shape
	query.transform = Transform2D(0, center)
	query.collide_with_areas = true
	
	var result = space.intersect_shape(query)
	
	var units_in_box : Array = []
	for item in result:
		var collider = item.collider
		if collider is Unit and collider.team == Entity.Team.PLAYER:
			units_in_box.append(collider)
	
	for unit in units_in_box:
		if not selected_units.has(unit):
			_add_to_selection(unit)
			
	var current_selection = selected_units.duplicate()
	for unit in current_selection:
		if not units_in_box.has(unit):
			_remove_from_selection(unit)

func _select_entity_at_point(point : Vector2):
	_deselect_all()
	
	var space = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = point
	query.collide_with_areas = true
	
	var result = space.intersect_point(query, 1)
	
	if not result.is_empty():
		var collider = result[0].collider
		if (collider is Entity and collider.team == Entity.Team.PLAYER) or collider.is_in_group("GoldMine"):
			_add_to_selection(collider)

func _add_to_selection(node):
	if not selected_units.has(node):
		selected_units.append(node)
		if is_instance_valid(node):
			if node.has_node("PlayerUnit"):
				node.get_node("PlayerUnit").toggle_selection_visual(true)
			if node is Building or node.is_in_group("GoldMine"):
				node.is_selected = true

func _remove_from_selection(node):
	if selected_units.has(node):
		selected_units.erase(node)
		if is_instance_valid(node):
			if node.has_node("PlayerUnit"):
				node.get_node("PlayerUnit").toggle_selection_visual(false)
			if node is Building or node.is_in_group("GoldMine"):
				node.is_selected = false

func _deselect_all():
	for node in selected_units:
		if is_instance_valid(node):
			if node.has_node("PlayerUnit"):
				node.get_node("PlayerUnit").toggle_selection_visual(false)
			if node is Building or node.is_in_group("GoldMine"):
				node.is_selected = false
	selected_units.clear()
	is_choosing_building = false
	build_mode = false
	if is_instance_valid(ghost_sprite): ghost_sprite.queue_free()
	if GameManager.game_ui != null: GameManager.game_ui.hide_build_indicator()
	_update_ui()

func _command_selected_units():
	if selected_units.is_empty():
		return
	
	var target_obj = _get_object_at_mouse()
	var mouse_pos = get_global_mouse_position()
	
	for entity in selected_units:
		if not is_instance_valid(entity):
			continue
		
		if entity is Unit:
			if target_obj != null and (target_obj.is_in_group("Tree") or target_obj.is_in_group("GoldMine")):
				if entity is Worker:
					entity.set_target(target_obj)
				else:
					entity.move_to_target(mouse_pos)
			
			elif target_obj != null and target_obj is Entity and target_obj.team != Entity.Team.PLAYER:
				entity.set_target(target_obj)
				
			else:
				entity.move_to_target(mouse_pos)

func _get_object_at_mouse() -> Node:
	var space = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = get_global_mouse_position()
	query.collide_with_areas = true
	var result = space.intersect_point(query, 1)
	
	if result.is_empty():
		return null
	
	var collider = result[0].collider
	
	if collider is Entity or collider.is_in_group("Tree") or collider.is_in_group("GoldMine"):
		return collider
	
	return null

func _update_ui():
	var ui = GameManager.game_ui 
	if ui == null:
		return

	if selected_units.size() == 1:
		ui.update_ui(selected_units[0])
	else:
		ui.update_ui(null)

func _on_build_mode_requested(type: String):
	build_mode = true
	current_build_type = type
	is_choosing_building = false
	
	if is_instance_valid(ghost_sprite):
		ghost_sprite.queue_free()
		
	ghost_sprite = Sprite2D.new()
	ghost_sprite.modulate = Color(1, 1, 1, 0.5) 
	
	ghost_sprite.top_level = true
	ghost_sprite.z_index = 99 
	
	var indicator_text = "Postav "
	
	match type:
		"barracks": 
			var tex = load("res://Assets/Buildings/Wood/Barracks.png")
			if tex == null: 
				print("KRITICKÁ CHYBA: Textura kasáren neexistuje na této cestě!")
			ghost_sprite.texture = tex
			ghost_sprite.hframes = 4
			ghost_sprite.vframes = 5
			ghost_sprite.frame = 2
			indicator_text += "Kasárna"
		"tower": 
			ghost_sprite.texture = load("res://Assets/Buildings/Wood/Tower.png")
			ghost_sprite.hframes = 3
			ghost_sprite.vframes = 2
			ghost_sprite.frame = 1
			ghost_sprite.offset.y = -20
			indicator_text += "Věž"
		"training_grounds": 
			ghost_sprite.texture = load("res://Assets/Buildings/Wood/Workshops.png")
			ghost_sprite.hframes = 3
			ghost_sprite.vframes = 3
			ghost_sprite.frame = 5
			indicator_text += "Cvičiště"
		
	add_child(ghost_sprite)
	
	if GameManager.game_ui != null:
		GameManager.game_ui.set_build_indicator(indicator_text + " (Zrušit: Pravé tlačítko)")

func _process(delta):
	if build_mode and is_instance_valid(ghost_sprite):
		var mouse_pos = get_global_mouse_position()
		ghost_sprite.global_position = mouse_pos
		
		if _can_place_building(mouse_pos):
			ghost_sprite.modulate = Color(0, 1, 0, 0.6) 
		else:
			ghost_sprite.modulate = Color(1, 0, 0, 0.6) 

func _can_place_building(pos: Vector2) -> bool:
	var cost = {}
	if current_build_type == "barracks": cost = GameManager.cost_barracks
	elif current_build_type == "tower": cost = GameManager.cost_tower
	elif current_build_type == "training_grounds": cost = GameManager.cost_training
	
	if not GameManager.can_afford(cost.wood, cost.gold, cost.food):
		return false
		
	var space = get_world_2d().direct_space_state
	var query = PhysicsShapeQueryParameters2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(40, 40) 
	query.shape = shape
	query.transform = Transform2D(0, pos)
	query.collide_with_areas = true
	var result = space.intersect_shape(query)
	
	for item in result:
		if item.collider is Entity or item.collider.is_in_group("Tree") or item.collider.is_in_group("GoldMine"):
			return false
			
	return true

func _confirm_build(pos: Vector2):
	var cost = {}
	var scene_to_pass : PackedScene
	
	match current_build_type:
		"barracks": 
			cost = GameManager.cost_barracks
			scene_to_pass = scene_barracks
		"tower": 
			cost = GameManager.cost_tower
			scene_to_pass = scene_tower
		"training_grounds": 
			cost = GameManager.cost_training
			scene_to_pass = scene_tg

	GameManager.try_spend_resources(cost.wood, cost.gold, cost.food)
	
	for unit in selected_units:
		if unit is Worker:
			unit.command_build(pos, scene_to_pass)
			break 
			
	build_mode = false
	if is_instance_valid(ghost_sprite): ghost_sprite.queue_free()
	if GameManager.game_ui != null: GameManager.game_ui.hide_build_indicator()
