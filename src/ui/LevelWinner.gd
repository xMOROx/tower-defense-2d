extends Control

@onready var retry_button: Button = $Buttons/Retry
@onready var level_button: Button = $Buttons/Levels
@onready var star1: TextureRect = $Stars/Star1
@onready var star2: TextureRect = $Stars/Star2
@onready var star3: TextureRect = $Stars/Star3
@onready var level_name_label: Label = $VictoryLabel/LevelNameLabel

var obtained_stars: int = 0

func _ready():
	retry_button.pressed.connect(_on_retry_button_pressed)
	level_button.pressed.connect(_on_level_button_pressed)

	retry_button.grab_focus()

func _on_retry_button_pressed():
	
	SceneManager.retry_level()

func _on_level_button_pressed():
	
	GameManager.reset_game()
	SceneManager.goto_level_select()
	
func set_data(data: Dictionary):
	if data.has("stars"):
		obtained_stars = data["stars"]
		_update_star_display()
	if data.has("level_name"):
		level_name_label.text = data["level_name"]
		
func _update_star_display():
	var filled_star_texture = load("res://assets/ui/Star/Active.png")
	var empty_star_texture = load("res://assets/ui/Star/Unactive.png")
	star1.texture = filled_star_texture if obtained_stars >= 1 else empty_star_texture
	star2.texture = filled_star_texture if obtained_stars >= 2 else empty_star_texture
	star3.texture = filled_star_texture if obtained_stars >= 3 else empty_star_texture
