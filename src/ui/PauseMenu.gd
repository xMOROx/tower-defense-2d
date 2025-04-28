extends Control

@onready var resume_button: Button = $Background/Buttons/ResumeButton
@onready var settings_button: Button = $Background/Buttons/SettingsButton
@onready var main_menu_button: Button = $Background/Buttons/MainMenuButton

func _ready():
	resume_button.pressed.connect(_on_resume_button_pressed)
	settings_button.pressed.connect(_on_settings_button_pressed)
	main_menu_button.pressed.connect(_on_main_menu_button_pressed)

func _on_resume_button_pressed():
	SceneManager.toggle_pause_menu()

func _on_main_menu_button_pressed():
	SceneManager.goto_main_menu()
	
func _on_settings_button_pressed():	
	pass
