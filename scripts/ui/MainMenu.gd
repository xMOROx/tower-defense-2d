extends Control

@onready var start_button: Button = $Background/Buttons/StartButton
@onready var exit_button: Button = $Exit

func _ready():
	start_button.pressed.connect(_on_start_button_pressed)
	exit_button.pressed.connect(_on_quit_button_pressed)
	start_button.grab_focus()

func _on_start_button_pressed():
	print("MainMenu: Start button pressed")
	SceneManager.goto_level_select()

func _on_quit_button_pressed():
	print("MainMenu: Quit button pressed")
	get_tree().quit()
