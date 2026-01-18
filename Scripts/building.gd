extends Unit
class_name Building

var is_selected : bool = false
var unit_scene = preload("res://Scenes/unit_player.tscn")

func _ready():
	move_speed = 0.0
	health_max = 200
	health_current = 200
	attack_damage = 0.0
	attack_range = 0.0
	attack_rate = 0.0
	
	
func _process(delta):
	pass

func _input(event):
	if is_selected and event is InputEventKey and event.pressed and event.keycode == KEY_Q:
		spawn_unit()

func spawn_unit():
	var new_unit = unit_scene.instantiate()
	
	var angle = randf() * PI * 2
	var distance = randf_range(25.0, 50.0)
	var offset = Vector2(cos(angle), sin(angle)) * distance
	
	new_unit.global_position = global_position + offset
	get_parent().add_child(new_unit)

func move_to_target (target : Vector2):
	pass
