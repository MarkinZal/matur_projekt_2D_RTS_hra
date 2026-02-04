extends Area2D
class_name GoldMine

var health : int = 1000
var gold_per_hit : int = 5

signal mine_depleted


func _ready():
	add_to_group("GoldMine")

func take_damage(amount):
	health -= amount
	GameManager.add_resource("gold", gold_per_hit)
	if health <= 0:
		die()
