extends Building # Dědí od tvé základní třídy budovy

@export var food_generation_rate : float = 5.0 # Každých 5 sekund
@export var food_amount : int = 10

var timer : Timer

func _ready():
	super._ready() # Zavolá _ready z Building.gd
	
	# Vytvoříme časovač pro generování jídla
	timer = Timer.new()
	add_child(timer)
	timer.wait_time = food_generation_rate
	timer.loop = true
	timer.timeout.connect(_on_food_timer_tick)
	timer.start()

func _on_food_timer_tick():
	GameManager.add_resource("food", food_amount)
	# Můžeš zde přidat efekt plovoucího textu "+10 Jídlo"
