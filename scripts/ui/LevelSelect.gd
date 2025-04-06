extends Control

@onready var level_1_button: Button = $Levels/Row1/Level1
@onready var menu_button: Button = $MenuButton

var level_1_scene_path = "res://maps/Level_1.tscn"

func _ready():
	level_1_button.pressed.connect(_on_level_1_button_pressed)
	menu_button.pressed.connect(_on_back_button_pressed)

func _on_level_1_button_pressed():
	print("LevelSelect: Level 1 selected")
	SceneManager.goto_level(level_1_scene_path) 


func _on_back_button_pressed():
	print("LevelSelect: Back button pressed")
	SceneManager.goto_main_menu()
