# GameManager.gd
extends Node

signal lives_changed(current_lives)
signal currency_changed(current_currency)
signal wave_changed(current_wave)
signal stars_changed(current_stars)

# --- Player Stats ---
const MAX_LIVES: int = 20
var current_lives: int = MAX_LIVES
var current_currency: int = 100

# --- Game State ---
var current_wave_number: int = 0 # Start at 0, wave 1 is the first playable
var current_stars: int = 3

func _ready():
	current_lives = MAX_LIVES
	current_currency = 100
	current_wave_number = 0
	

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		SceneManager.toggle_pause_menu()

# --- Lives ---
func lose_life():
	if current_lives <= 0:
		return
	current_lives -= 1
	current_stars = _compute_stars()
	if current_lives <= 0:
		game_over()
		return
	emit_signal("lives_changed", current_lives)	
	emit_signal("stars_changed", current_stars)

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
	current_stars = 3
	
	emit_signal("lives_changed", current_lives)
	emit_signal("currency_changed", current_currency)
	emit_signal("wave_changed", current_wave_number)
	emit_signal("stars_changed", current_stars)
	
	

# --- Game Over ---
func game_over():
	
	SceneManager.goto_game_over()
	
# --- Level Completion ---
func level_completed():
	
	var stars = _compute_stars()
	StateManager.save_level_stars(SceneManager.get_last_played_level_path(), stars)
	SceneManager.goto_level_winner(stars)

func _compute_stars() -> int:
	var percentage_lives_remaining = float(current_lives) / MAX_LIVES

	if percentage_lives_remaining == 1.0:
		return 3
	elif percentage_lives_remaining >= 0.75:
		return 2
	elif percentage_lives_remaining > 0.3:
		return 1
	else:
		return 0
