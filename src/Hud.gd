extends CanvasLayer

@onready var lives_label: Label = $HeartContainer/LivesLabel 
@onready var currency_label: Label = $MoneyContainer/CurrencyLabel 
@onready var wave_label: Label = $WaveLabel 
@onready var wave_progress_bar: TextureProgressBar = $WaveProgressBar
@onready var upgrade_menu: Control = $TowerUpgradeMenu

@onready var star1: Sprite2D = $StarsContainer/Star1
@onready var star2: Sprite2D = $StarsContainer/Star2
@onready var star3: Sprite2D = $StarsContainer/Star3

var currently_selected_tower: Node = null 

func _ready():
	if lives_label == null: printerr("HUD Error: LivesLabel node not found!")
	if currency_label == null: printerr("HUD Error: CurrencyLabel node not found!")
	if wave_label == null: printerr("HUD Error: WaveLabel node not found!")
	if wave_progress_bar == null: printerr("HUD Error: WaveProgressBar node not found!")
	if upgrade_menu == null: printerr("Main Scene Error: TowerUpgradeMenu node not found!")
	
	if upgrade_menu:
		upgrade_menu.visibility_changed.connect(_on_upgrade_menu_visibility_changed)
	
	GameManager.lives_changed.connect(_on_lives_changed)
	GameManager.stars_changed.connect(_on_stars_changed)
	GameManager.currency_changed.connect(_on_currency_changed) 
	GameManager.wave_changed.connect(_on_wave_changed)

	
	_update_lives_display(GameManager.get_lives())
	_update_currency_display(GameManager.get_currency()) 
	_update_wave_display(GameManager.get_current_wave())

func _on_tower_show_upgrade_menu(tower: Node) -> void: 
	if not is_instance_valid(tower):
		printerr("Main Scene Warning: Received show_upgrade_menu signal for an invalid tower instance.")
		return 

	if is_instance_valid(currently_selected_tower) and currently_selected_tower != tower:
		if currently_selected_tower.has_method("hide_range_indicator"):
			currently_selected_tower.hide_range_indicator()
		else:
			printerr("Warning: Previous tower missing hide_range_indicator method.")

	currently_selected_tower = tower

	if currently_selected_tower.has_method("show_range_indicator"):
		currently_selected_tower.show_range_indicator()
	else:
		printerr("Warning: Selected tower missing show_range_indicator method.")

	if upgrade_menu == null:
		printerr("Main Scene Error: TowerUpgradeMenu node reference is null! Cannot show menu.")
		return 
	if not upgrade_menu.has_method("show_for_tower"):
		printerr("Main Scene Error: TowerUpgradeMenu instance is missing the 'show_for_tower' method!")
		return 

	
	upgrade_menu.show_for_tower(tower) 

func _on_upgrade_menu_visibility_changed():
	if not upgrade_menu.visible and is_instance_valid(currently_selected_tower):
		
		if currently_selected_tower.has_method("hide_range_indicator"):
			currently_selected_tower.hide_range_indicator()
		currently_selected_tower = null

func _on_lives_changed(current_lives: int):
	_update_lives_display(current_lives)
	
func _on_stars_changed(current_stars: int):	
	print("HUD: Stars changed to %d" % current_stars)
	_update_stars_display(current_stars)

func _on_currency_changed(current_currency: int):
	_update_currency_display(current_currency)
	
func _on_wave_changed(current_wave: int): 
	_update_wave_display(current_wave) 

func _update_lives_display(current_lives: int):
	if lives_label:
		lives_label.text = "%d / %d" % [current_lives, GameManager.get_max_lives()]
		
		if current_lives <= 5: 
			lives_label.modulate = Color.RED
		else:
			lives_label.modulate = Color.WHITE 

func _update_stars_display(current_stars: int):			
	var filled_star_texture = load("res://assets/ui/Star/Active.png")
	var empty_star_texture = load("res://assets/ui/Star/Unactive.png")
	
	star1.texture = filled_star_texture if current_stars >= 1 else empty_star_texture
	star2.texture = filled_star_texture if current_stars >= 2 else empty_star_texture
	star3.texture = filled_star_texture if current_stars >= 3 else empty_star_texture
			
func _update_currency_display(current_currency: int): 
	if currency_label:
		currency_label.text = "%d" % current_currency

func _update_wave_display(current_wave: int):
	if wave_label:
		if current_wave > 0: 
			wave_label.text = "%d / %d" % [current_wave, 7]
			wave_progress_bar.value = (current_wave - 1) / 7.0 * 100.0
		else: 
			wave_label.text = "Not started"
