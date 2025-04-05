extends Node2D

# --- Signals ---
signal show_upgrade_menu(tower)

# --- BASE Exported Variables (Initial values for Level 1) ---
@export var base_attack_damage: float = 5.0
@export var base_damage_increase_per_level: float = 3.0
@export var base_damage_upgrade_cost: int = 25
@export var cost_increase_per_level_damage: int = 15

@export var base_range_radius: float = 100.0
@export var base_range_increase_factor: float = 1.15
@export var base_range_upgrade_cost: int = 30
@export var cost_increase_per_level_range: int = 20

@export var base_attack_rate: float = 1.0

@export var projectile_scene: PackedScene = null

# --- Nodes ---
@onready var detection_range: Area2D = $DetectionRange
@onready var attack_timer: Timer = $AttackTimer
@onready var click_area: Area2D = $ClickArea
@onready var range_shape: CollisionShape2D = $DetectionRange/CollisionShape2D

# --- Internal INSTANCE Variables (Specific to this tower) ---
var current_level: int = 1
var current_attack_damage: float
var current_range_radius: float # Store current radius if needed elsewhere

# --- Attack State ---
var targets: Array[Node2D] = []
var current_target: Node2D = null

# --- Range Indicator State ---
var _is_showing_range: bool = false 
var ready_to_shoot: bool = true  # New state variable for readiness
var is_placed: bool = false


func _ready():
	current_attack_damage = base_attack_damage
	current_range_radius = base_range_radius
	
	if range_shape and range_shape.shape is CircleShape2D:
		range_shape.shape.radius = current_range_radius
	else:
		printerr(name + ": Invalid range shape on ready!")

	var attack_rate = base_attack_rate
	if attack_timer:
		attack_timer.wait_time = attack_rate
		attack_timer.timeout.connect(_on_attack_timer_timeout)
	else:
		printerr(name + " could not find AttackTimer node!")

	if detection_range:
		detection_range.body_entered.connect(_on_detection_range_body_entered)
		detection_range.body_exited.connect(_on_detection_range_body_exited)
	else:
		printerr(name + " could not find DetectionRange node!")
		
	if click_area:
		click_area.input_event.connect(_on_click_area_input_event)
	else:
		printerr(name + " could not find ClickArea node!")

	print(name, " ready. Lvl:", current_level, " Dmg:", current_attack_damage, " Rng:", current_range_radius)

func _draw():
	if _is_showing_range:
		if range_shape and range_shape.shape is CircleShape2D:
			var radius = range_shape.shape.radius
			draw_circle(Vector2.ZERO, radius, Color(1.0, 1.0, 1.0, 0.7), 1.0, true)
		else:
			printerr(name + ": Cannot draw range, shape is not a CircleShape2D!")

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		#TODO: tell the main manager to clear the selection. Requires reference or signal.
		pass # Implement cleanup if needed

# --- Signal Callback Functions ---

func _on_detection_range_body_entered(body: Node2D):
	if not is_placed: 
		return
	if body.is_in_group("enemies"):
		if not targets.has(body):
			targets.append(body)
			
			if ready_to_shoot:
				attack_enemy(body)

			if body.has_signal("died"):
				if not body.is_connected("died", _on_target_died):
					var flags = CONNECT_REFERENCE_COUNTED | CONNECT_ONE_SHOT
					body.died.connect(_on_target_died, flags)

func _on_detection_range_body_exited(body: Node2D):
	if not is_placed: 
		return
	if body.is_in_group("enemies"):
		var index = targets.find(body)
		if index != -1:
			targets.remove_at(index)
			
			if body.has_signal("died") and body.is_connected("died", _on_target_died):
				body.died.disconnect(_on_target_died)

func _on_attack_timer_timeout():
	ready_to_shoot = true
	if not targets.is_empty():
		attack_enemy(targets[0])

func _on_target_died(enemy_that_died: Node2D):
	print("Tower: Detected target died signal - ", enemy_that_died.name)

	var index = targets.find(enemy_that_died)
	if index != -1:
		targets.remove_at(index)

	if current_target == enemy_that_died:
		print("Tower: Current target confirmed dead.")
		current_target = null
		attack_timer.stop()
		_update_target()

func _on_click_area_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		print(name + " clicked!")
		emit_signal("show_upgrade_menu", self)
		get_viewport().set_input_as_handled()

func show_range_indicator():
	if not _is_showing_range:
		_is_showing_range = true
		queue_redraw()

func hide_range_indicator():
	if _is_showing_range:
		_is_showing_range = false
		queue_redraw()

# --- Upgrade Functions (Placeholders for now) ---
func get_damage_upgrade_cost() -> int:
	return base_damage_upgrade_cost + (current_level - 1) * cost_increase_per_level_damage

func get_range_upgrade_cost() -> int:
	return base_range_upgrade_cost + (current_level - 1) * cost_increase_per_level_range

func upgrade_damage():
	current_attack_damage += base_damage_increase_per_level
	current_level += 1
	print(name + " damage upgraded! Lvl:", current_level, " New damage:", current_attack_damage, " Next cost:", get_damage_upgrade_cost())

func upgrade_range():
	if range_shape and range_shape.shape is CircleShape2D:
		var new_radius = current_range_radius * base_range_increase_factor
		
		range_shape.shape.radius = new_radius
		current_range_radius = new_radius
		
		current_level += 1
		
		if _is_showing_range:
			queue_redraw()
		print(name + " range upgraded! Lvl:", current_level, " New radius:", current_range_radius, " Next cost:", get_range_upgrade_cost())
	else:
		printerr(name + " cannot upgrade range: Invalid shape node.")

# --- Helper Functions ---
