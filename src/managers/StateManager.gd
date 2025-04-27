extends Control

signal game_progress_loaded

const SAVE_FILE = "user://game_progress.ini"
var level_stars_data: Dictionary = {}

func _ready():
	load_game_progress()

func save_level_stars(level_path: String, stars: int):
	level_stars_data[level_path] = max(level_stars_data.get(level_path, 0), stars)
	save_game_progress()

func get_level_stars(level_path: String) -> int:
	return level_stars_data.get(level_path, 0)

func save_game_progress():
	var config = ConfigFile.new()
	config.set_value("levels", "stars", level_stars_data)
	var err = config.save(SAVE_FILE)
	if err != OK:
		printerr("StateManager Error: Error saving game progress to:", SAVE_FILE)

func load_game_progress():
	print("StateManager: Loading game progress from:", SAVE_FILE)
	var config = ConfigFile.new()
	var err = config.load(SAVE_FILE)
	if err == OK:
		if config.has_section("levels") and config.has_section_key("levels", "stars"):
			level_stars_data = config.get_value("levels", "stars")
		else:
			level_stars_data = {}
	else:
		printerr("StateManager Error: Error loading game progress from:", SAVE_FILE)
	game_progress_loaded.emit(self)

func reset_progress():
	level_stars_data.clear()
	save_game_progress()
	print("StateManager: Game progress reset.")
