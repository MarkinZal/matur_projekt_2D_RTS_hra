extends Area2D
class_name GoldMine

var max_workers: int = 5
var current_workers: Array = []
var gold_timer: float = 0.0
var gold_interval: float = 1.0
var is_selected: bool = false

func _ready():
	add_to_group("GoldMine")

func add_worker(worker: Node) -> bool:
	if current_workers.size() < max_workers:
		current_workers.append(worker)
		worker.hide()
		worker.set_process(false)
		worker.set_physics_process(false)
		worker.global_position = self.global_position
		return true
	return false

func remove_worker():
	if current_workers.size() > 0:
		var worker = current_workers.pop_back()
		worker.show()
		worker.set_process(true)
		worker.set_physics_process(true)
		worker.global_position = self.global_position + Vector2(0, 40)
		worker.target_unit = null

func _process(delta):
	if current_workers.size() > 0:
		gold_timer += delta
		if gold_timer >= gold_interval:
			gold_timer = 0.0
			GameManager.add_resource("gold", current_workers.size() * 5)

func _input(event):
	if not is_selected: return
	if event is InputEventKey and event.pressed and event.keycode == KEY_E:
		remove_worker()
