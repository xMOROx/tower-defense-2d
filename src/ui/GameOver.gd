extends Control

@onready var retry_button: Button = $Buttons/Retry
@onready var level_button: Button = $Buttons/Levels
@onready var exit_button: Button = $Exit

func _ready():
	retry_button.pressed.connect(_on_retry_button_pressed)
	level_button.pressed.connect(_on_level_button_pressed)
	exit_button.pressed.connect(_on_exit_button_pressed)

	retry_button.grab_focus()

func _on_retry_button_pressed():
	
	SceneManager.retry_level()

func _on_level_button_pressed():
	
	GameManager.reset_game()
	SceneManager.goto_level_select()

func _on_exit_button_pressed():
	
	get_tree().quit()
