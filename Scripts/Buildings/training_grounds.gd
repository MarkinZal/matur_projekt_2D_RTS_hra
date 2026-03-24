extends Building
class_name TrainingGrounds

var upgrade_count : int = 0
var max_upgrades : int = 3

func _ready():
	can_train_units = false
	is_training_grounds = true
	health_max = 150
	health_current = 150

func _input(event):
	if not is_selected:
		return
	if event.is_action_pressed("buy_upgrade"):
		if upgrade_count < max_upgrades:
			if GameManager.purchase_upgrade(): 
				upgrade_count += 1
				print("Vylepšení zakoupeno! Úroveň: ", upgrade_count)
		else:
			print("Dosaženo maximální úrovně vylepšení.")
