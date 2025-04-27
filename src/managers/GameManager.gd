# GameManager.gd
extends Node

signal lives_changed(current_lives)
signal currency_changed(current_currency)
signal wave_changed(current_wave)

# --- Player Stats ---
const MAX_LIVES: int = 20
var current_lives: int = MAX_LIVES
var current_currency: int = 100

# --- Game State ---
var current_wave_number: int = 0 # Start at 0, wave 1 is the first playable

func _ready():
	current_lives = MAX_LIVES
	current_currency = 100
	current_wave_number = 0
	print("GameManager Ready. Lives:", current_lives, "Currency:", current_currency)

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		SceneManager.toggle_pause_menu()

# --- Lives ---
func lose_life():
	if current_lives > 0:
		current_lives -= 1
		emit_signal("lives_changed", current_lives)
		if current_lives <= 0:
			game_over()

# --- Currency ---
func add_currency(amount: int):
	current_currency += amount
	emit_signal("currency_changed", current_currency)

func can_afford(cost: int) -> bool:
	return current_currency >= cost

func spend_currency(cost: int) -> bool:
	if can_afford(cost):
		current_currency -= cost
		emit_signal("currency_changed", current_currency)
		return true
	else:
		return false

# --- Wave Management ---
func set_wave(wave_num: int):
	current_wave_number = wave_num
	emit_signal("wave_changed", current_wave_number)
	print("GameManager: Wave set to", current_wave_number)

func get_current_wave() -> int:
	return current_wave_number

# --- Getters ---
func get_lives() -> int: return current_lives
func get_max_lives() -> int: return MAX_LIVES
func get_currency() -> int: return current_currency

# --- Setters ---
func reset_game():
	current_lives = MAX_LIVES
	current_currency = 100
	current_wave_number = 0
	
	emit_signal("lives_changed", current_lives)
	emit_signal("currency_changed", current_currency)
	emit_signal("wave_changed", current_wave_number)
	
	print("GameManager: Game state reset to initial values")

# --- Game Over ---
func game_over():
	print("GAME OVER!")
	SceneManager.goto_game_over()
