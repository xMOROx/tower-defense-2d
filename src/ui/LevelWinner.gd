extends Control

@onready var retry_button: Button = $Buttons/Retry
@onready var level_button: Button = $Buttons/Levels

func _ready():
	retry_button.pressed.connect(_on_retry_button_pressed)
	level_button.pressed.connect(_on_level_button_pressed)

	retry_button.grab_focus()

func _on_retry_button_pressed():
	print("GameOver: Retry button pressed")
	SceneManager.retry_level()

func _on_level_button_pressed():
	print("GameOver: Level button pressed")
	GameManager.reset_game()
	SceneManager.goto_level_select()
