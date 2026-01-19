extends Node2D

var selected_units : Array[Unit] = []
var dragging : bool = false
var drag_start : Vector2 = Vector2.ZERO
var is_drag_active : bool = false

@export var game_ui : Node

func _ready():
	z_index = 100

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			dragging = true
			drag_start = get_global_mouse_position()
			is_drag_active = false
		else:
			dragging = false
			queue_redraw()
			
			if not is_drag_active:
				_select_unit_at_point(get_global_mouse_position())
			
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

	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
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
	
	var units_in_box : Array[Unit] = []
	for item in result:
		var collider = item.collider
		if collider is Unit and collider.team == Unit.Team.PLAYER:
			units_in_box.append(collider)
	
	for unit in units_in_box:
		if not selected_units.has(unit):
			_add_to_selection(unit)
			
	var current_selection = selected_units.duplicate()
	for unit in current_selection:
		if not units_in_box.has(unit):
			_remove_from_selection(unit)

func _select_unit_at_point(point : Vector2):
	_deselect_all()
	
	var space = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = point
	query.collide_with_areas = true
	
	var result = space.intersect_point(query, 1)
	
	if not result.is_empty():
		var collider = result[0].collider
		if collider is Unit and collider.team == Unit.Team.PLAYER:
			_add_to_selection(collider)

func _add_to_selection(unit : Unit):
	if not selected_units.has(unit):
		selected_units.append(unit)
		if is_instance_valid(unit):
			if unit.has_node("PlayerUnit"):
				unit.get_node("PlayerUnit").toggle_selection_visual(true)
			if unit is Building:
				unit.is_selected = true

func _remove_from_selection(unit : Unit):
	if selected_units.has(unit):
		selected_units.erase(unit)
		if is_instance_valid(unit):
			if unit.has_node("PlayerUnit"):
				unit.get_node("PlayerUnit").toggle_selection_visual(false)
			if unit is Building:
				unit.is_selected = false

func _deselect_all():
	for unit in selected_units:
		if is_instance_valid(unit):
			if unit.has_node("PlayerUnit"):
				unit.get_node("PlayerUnit").toggle_selection_visual(false)
			if unit is Building:
				unit.is_selected = false
	selected_units.clear()
	_update_ui()


func _command_selected_units():
	if selected_units.is_empty():
		return
	
	var target_obj = _get_object_at_mouse()
	var mouse_pos = get_global_mouse_position()
	
	for unit in selected_units:
		if not is_instance_valid(unit):
			continue
		
		if target_obj != null and target_obj.is_in_group("Tree"):
			if unit is Worker:
				unit.set_target(target_obj)
			else:
				unit.move_to_target(mouse_pos)
		
		elif target_obj != null and target_obj is Unit and target_obj.team != Unit.Team.PLAYER:
			unit.set_target(target_obj)
			
		else:
			unit.move_to_target(mouse_pos)

func _get_object_at_mouse() -> Node:
	var space = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = get_global_mouse_position()
	query.collide_with_areas = true
	var result = space.intersect_point(query, 1)
	
	if result.is_empty():
		return null
	
	var collider = result[0].collider
	
	if collider is Unit or collider.is_in_group("Tree"):
		return collider
	
	return null

func _update_ui():
	if game_ui == null: return
	
	var has_building = false
	for unit in selected_units:
		if unit is Building:
			has_building = true
			break
	
	game_ui.show_action(has_building)
