extends Node

signal lives_changed(current_lives)
signal currency_changed(current_currency)


# --- Player Stats ---
const MAX_LIVES: int = 20
var current_lives: int = MAX_LIVES

var current_currency: int = 100 # Starting currency

func _ready():
	current_lives = MAX_LIVES
	current_currency = 100 
	print("GameManager Ready. Lives:", current_lives, "Currency:", current_currency)

func lose_life():
	if current_lives > 0:
		current_lives -= 1
		print("Life lost! Remaining lives:", current_lives)
		emit_signal("lives_changed", current_lives) 
		
		if current_lives <= 0:
			game_over()

func add_currency(amount: int):
	current_currency += amount
	emit_signal("currency_changed", current_currency)
	print("Added currency:", amount, " Total:", current_currency)

func can_afford(cost: int) -> bool:
	return current_currency >= cost

func spend_currency(cost: int) -> bool:
	if can_afford(cost):
		current_currency -= cost
		emit_signal("currency_changed", current_currency)
		print("Spent currency:", cost, " Remaining:", current_currency)
		return true
	else:
		print("Not enough currency! Need:", cost, " Have:", current_currency)
		return false

# --- Getters ---
func get_lives() -> int:
	return current_lives
	
func get_max_lives() -> int:
	return MAX_LIVES

func get_currency() -> int:
	return current_currency

func game_over():
	print("GAME OVER!")
	get_tree().paused = true 
