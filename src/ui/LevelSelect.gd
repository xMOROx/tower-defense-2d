extends Control

@onready var level_1_button: Button = $Levels/Row1/Level1
@onready var menu_button: Button = $MenuButton
@onready var score_label: Label = $Score/ScoreLabel

var level_1_scene_path = "res://scenes/maps/Level_1.tscn"
var stars0 = load("res://assets/ui/Level/Star/Group/0-3.png")
var stars1 = load("res://assets/ui/Level/Star/Group/1-3.png")
var stars2 = load("res://assets/ui/Level/Star/Group/2-3.png")
var stars3 = load("res://assets/ui/Level/Star/Group/3-3.png")
var levels = [level_1_scene_path]

func _ready():
	level_1_button.pressed.connect(_on_level_1_button_pressed)
	menu_button.pressed.connect(_on_back_button_pressed)
	_on_game_progress_loaded()

func _on_level_1_button_pressed():
	
	SceneManager.goto_level(level_1_scene_path) 

func _on_back_button_pressed():
	
	SceneManager.goto_main_menu()

func _on_game_progress_loaded():
	
	var all_obtained_stars: int = 0
	for level in levels:
		all_obtained_stars += StateManager.get_level_stars(level)
	score_label.text = str(all_obtained_stars) + "/" + str(levels.size()*3)
	_update_level_stars(level_1_button, level_1_scene_path)
	
	
func _update_level_stars(button: Button, level_path: String):	
	
	var stars = StateManager.get_level_stars(level_path)
	
	match stars:
		0:
			button.get_node("Stars").texture = stars0
		1:
			button.get_node("Stars").texture = stars1
		2:
			button.get_node("Stars").texture = stars2
		3:
			button.get_node("Stars").texture = stars3
