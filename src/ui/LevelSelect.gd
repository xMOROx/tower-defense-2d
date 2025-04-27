extends Control

@onready var level_1_button: Button = $Levels/Row1/Level1
@onready var menu_button: Button = $MenuButton

var level_1_scene_path = "res://scenes/maps/Level_1.tscn"
var stars0 = load("res://assets/ui/Level/Star/Group/0-3.png")
var stars1 = load("res://assets/ui/Level/Star/Group/1-3.png")
var stars2 = load("res://assets/ui/Level/Star/Group/2-3.png")
var stars3 = load("res://assets/ui/Level/Star/Group/3-3.png")

func _ready():
	level_1_button.pressed.connect(_on_level_1_button_pressed)
	menu_button.pressed.connect(_on_back_button_pressed)
	_update_level_stars(level_1_button, level_1_scene_path)

func _on_level_1_button_pressed():
	print("LevelSelect: Level 1 selected")
	SceneManager.goto_level(level_1_scene_path) 

func _on_back_button_pressed():
	print("LevelSelect: Back button pressed")
	SceneManager.goto_main_menu()

func _on_game_progress_loaded():
	print("LevelSelect: Game progress loaded")
	_update_level_stars(level_1_button, level_1_scene_path)
	
func _update_level_stars(button: Button, level_path: String):	
	print("LevelSelect: Updating stars for level", level_path)
	var stars = StateManager.get_level_stars(level_path)
	print("LevelSelect: Stars for level", level_path, ":", stars)
	
	match stars:
		0:
			button.get_node("Stars").texture = stars0
		1:
			button.get_node("Stars").texture = stars1
		2:
			button.get_node("Stars").texture = stars2
		3:
			button.get_node("Stars").texture = stars3
		_:
			print("LevelSelect: Invalid star count for level", level_path, ":", stars)
