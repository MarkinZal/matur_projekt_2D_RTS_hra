extends Sprite2D

@onready var unit : Unit = get_parent()

@export var can_tilt: bool = true
@export var auto_flip: bool = true

var unit_pos_last_frame : Vector2

func _ready ():
	unit.health_changed.connect(_damage_flash)

func _process(delta):
	var time = Time.get_unix_time_from_system()
	
	if can_tilt:
		var r = sin(time * 10) * 5
		if unit.global_position.distance_to(unit_pos_last_frame) == 0:
			r = 0
		rotation = deg_to_rad(r)
	
	var dir = unit.global_position.x - unit_pos_last_frame.x
	
	if auto_flip:
		if dir > 0.1:
			flip_h = false
		elif dir < -0.1:
			flip_h = true
	
	unit_pos_last_frame = unit.global_position

func _damage_flash (health : int):
	modulate = Color.RED
	await get_tree().create_timer(0.05).timeout
	modulate = Color.WHITE
