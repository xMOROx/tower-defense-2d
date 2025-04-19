extends Node2D

@onready var build_tower_button: Button = $HUD/BuildTowerButton
@onready var towers_container: Node2D = $World/TowersContainer
@onready var upgrade_menu: Control = $HUD/TowerUpgradeMenu


# --- Export Tower Data ---
@export var basic_tower_scene: PackedScene = null
@export var basic_tower_cost: int = 50

# --- Building State Variables ---
var is_building: bool = false
var building_tower_scene: PackedScene = null
var tower_preview_instance: Node2D = null
var placement_valid: bool = false

# --- Selection State ---
var currently_selected_tower: Node = null

# --- Constants for Preview ---
const PLACEMENT_VALID_COLOR = Color(0.0, 1.0, 0.0, 0.5) # Greenish transparent
const PLACEMENT_INVALID_COLOR = Color(1.0, 0.0, 0.0, 0.5) # Reddish transparent

func _ready():
	if upgrade_menu == null: printerr("Main Scene Error: TowerUpgradeMenu node not found!")
	if build_tower_button == null: printerr("Main Scene Error: BuildTowerButton node not found!")
	if towers_container == null: printerr("Main Scene Error: TowersContainer node not found!")
	if basic_tower_scene == null: printerr("Main Scene Error: Basic Tower Scene not assigned in Inspector!")

	if upgrade_menu:
		upgrade_menu.visibility_changed.connect(_on_upgrade_menu_visibility_changed)
	if build_tower_button:
		build_tower_button.pressed.connect(_on_build_tower_button_pressed)
		build_tower_button.text = "Build Tower (Cost: %d)" % basic_tower_cost
		build_tower_button.disabled = not GameManager.can_afford(basic_tower_cost)
		GameManager.currency_changed.connect(_on_currency_changed_update_build_buttons)
	

	reset_level_state()
		
	set_process_input(false)

# --- Level Reset Logic ---
func reset_level_state():
	if is_building:
		cancel_building()
	
	if upgrade_menu and upgrade_menu.visible:
		upgrade_menu.hide()
	
	currently_selected_tower = null
	
	clear_all_towers()
	
	if build_tower_button:
		build_tower_button.disabled = not GameManager.can_afford(basic_tower_cost)

func clear_all_towers():
	if not is_instance_valid(towers_container):
		return
	
	for tower in towers_container.get_children():
		if is_instance_valid(tower):
			if tower.has_signal("show_upgrade_menu") and tower.is_connected("show_upgrade_menu", _on_tower_show_upgrade_menu):
				tower.show_upgrade_menu.disconnect(_on_tower_show_upgrade_menu)
			tower.queue_free()
	
	print("Level1: All towers cleared")

# --- Input Handling ---
func _input(event):
	if not is_building:
		return

	if event is InputEventMouseMotion:
		if is_instance_valid(tower_preview_instance):
			tower_preview_instance.global_position = get_global_mouse_position()
			check_placement_validity()

	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			try_place_tower()
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed():
			cancel_building()


# --- Building Logic ---
func _on_build_tower_button_pressed():
	if is_building:
		cancel_building()
		return
		
	if not GameManager.can_afford(basic_tower_cost):
		print("Cannot afford tower!")
		# TODO: Play sound effect
		return

	print("Starting tower build process...")
	is_building = true
	building_tower_scene = basic_tower_scene
	
	tower_preview_instance = building_tower_scene.instantiate()
	
	add_child(tower_preview_instance)
	tower_preview_instance.global_position = get_global_mouse_position()
	
	tower_preview_instance.modulate = PLACEMENT_INVALID_COLOR # Start as invalid until checked
	var preview_area = tower_preview_instance.find_child("PlacementArea", true, false)
	if preview_area is Area2D:
		preview_area.collision_mask = 0 # Reset mask
		# Check against 'placed_towers' (bit 4 = 16) and 'unbuildable' (bit 5 = 32)
		preview_area.collision_mask = (1 << 4) | (1 << 5)
	else:
		printerr("Preview instance is missing PlacementArea!")
		cancel_building()
		return

	set_process_input(true)
	check_placement_validity()

func check_placement_validity():
	if not is_instance_valid(tower_preview_instance): return
	
	var preview_area = tower_preview_instance.find_child("PlacementArea", true, false)
	if not preview_area is Area2D: return


	var overlapping_areas = preview_area.get_overlapping_areas()
	
	placement_valid = overlapping_areas.is_empty()

	if placement_valid:
		tower_preview_instance.modulate = PLACEMENT_VALID_COLOR
	else:
		tower_preview_instance.modulate = PLACEMENT_INVALID_COLOR


func try_place_tower():
	if not is_building or not is_instance_valid(tower_preview_instance): return
	
	check_placement_validity() 

	if placement_valid:
		if GameManager.spend_currency(basic_tower_cost): 
			print("Placing tower!")
			var new_tower = building_tower_scene.instantiate() 
			
			towers_container.add_child(new_tower)
			new_tower.global_position = tower_preview_instance.global_position

			if new_tower is BaseTower:
				new_tower.set_placed()
				print("Level1: Called set_placed() on '", new_tower.name, "'")
			else:
				printerr("Level1 Error: Instantiated tower '", new_tower.name, "' is not derived from BaseTower!")
			# ---------------------------------------------

			if new_tower.has_signal("show_upgrade_menu"):
				new_tower.show_upgrade_menu.connect(_on_tower_show_upgrade_menu)
			else:
				printerr("Placed tower '", new_tower.name, "' is missing 'show_upgrade_menu' signal!")

			cancel_building()
		else:
			print("Placement failed: Could not spend currency.")
			# TODO: Play sound
			cancel_building() 
	else:
		print("Cannot place tower here (invalid location).")
		# TODO: Play sound


func cancel_building():
	print("Cancelling build process.")
	if is_instance_valid(tower_preview_instance):
		tower_preview_instance.queue_free()
	
	tower_preview_instance = null
	building_tower_scene = null
	is_building = false
	
	set_process_input(false)


# --- Signal Handlers ---

func _on_tower_show_upgrade_menu(tower: Node) -> void:
	if is_building:
		cancel_building()

	if is_instance_valid(currently_selected_tower) and currently_selected_tower != tower:
		if currently_selected_tower.has_method("hide_range_indicator"):
			currently_selected_tower.hide_range_indicator()
	currently_selected_tower = tower
	if currently_selected_tower.has_method("show_range_indicator"):
		currently_selected_tower.show_range_indicator()
	if upgrade_menu == null: return
	if not upgrade_menu.has_method("show_for_tower"): return
	upgrade_menu.show_for_tower(tower)

func _on_upgrade_menu_visibility_changed():
	if not upgrade_menu.visible and is_instance_valid(currently_selected_tower):
		if currently_selected_tower.has_method("hide_range_indicator"):
			currently_selected_tower.hide_range_indicator()
		currently_selected_tower = null

func _on_currency_changed_update_build_buttons(current_currency: int):
	if build_tower_button:
		build_tower_button.disabled = not GameManager.can_afford(basic_tower_cost)
