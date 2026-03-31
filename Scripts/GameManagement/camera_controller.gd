extends Camera2D

@export var move_speed : float = 70.0
@export var zoom_amount : float = 0.2

func _ready():
	var gm = get_tree().get_first_node_in_group("game_manager")
	if gm:
		limit_left = 0
		limit_top = 0
		
		limit_right = gm.map_width * 16
		limit_bottom = gm.map_height * 16
		
		limit_smoothed = true
		
		global_position = gm.player_start_world_pos
		
	zoom = Vector2(3.0, 3.0)

func _process(delta):
	_move(delta)
	_zoom(delta)

func _move(delta):
	var input = Input.get_vector("cam_left", "cam_right", "cam_up", "cam_down")
	var zoom_mod = 6.0 - zoom.x
	global_position += input * delta * move_speed * zoom_mod

func _zoom(delta):
	var z = zoom.x
	
	if Input.is_action_just_released("zoom_in"):
		z += zoom_amount
	elif Input.is_action_just_released("zoom_out"):
		z -= zoom_amount
		
	z = clamp(z, 1.0, 5.0)
	
	zoom.x = z
	zoom.y = z
