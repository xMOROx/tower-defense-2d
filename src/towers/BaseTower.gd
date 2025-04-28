class_name BaseTower
extends Node2D

signal show_upgrade_menu(tower)
signal placed

enum TargetingPriority { FIRST, LAST, CLOSEST, STRONGEST, WEAKEST }

@export var tower_display_name: String = "Tower"
@export_enum("TargetingPriority") var targeting_priority: int = TargetingPriority.FIRST
@export var base_range_radius: float = 100.0
@export var base_range_increase_factor: float = 1.15
@export var base_range_upgrade_cost: int = 30
@export var cost_increase_per_level_range: int = 20
@export var base_attack_interval: float = 1.0

@onready var detection_range: Area2D = $DetectionRange
@onready var range_shape: CollisionShape2D = $DetectionRange/CollisionShape2D
@onready var click_area: Area2D = $ClickArea
@onready var attack_timer: Timer = $AttackTimer

var current_level: int = 1
var current_range_radius: float
var current_attack_interval: float

var _is_placed: bool = false
var _is_showing_range: bool = false
var current_target: Node2D = null

func _ready():
	current_range_radius = base_range_radius
	current_attack_interval = base_attack_interval
	
	if detection_range == null: printerr(name, ": Missing DetectionRange node!")
	if range_shape == null: printerr(name, ": Missing RangeShape node!")
	if click_area == null: printerr(name, ": Missing ClickArea node!")
	if attack_timer == null: printerr(name, ": Missing AttackTimer node!")

	if range_shape and range_shape.shape is CircleShape2D:
		range_shape.shape.radius = current_range_radius
	elif range_shape:
		printerr(name, ": RangeShape is not a CircleShape2D!")
		
	if attack_timer:
		attack_timer.wait_time = current_attack_interval
		attack_timer.one_shot = true
		attack_timer.timeout.connect(_on_attack_timer_timeout)
		attack_timer.stop()
	
	if detection_range:
		detection_range.body_entered.connect(_on_detection_range_body_entered)
		detection_range.body_exited.connect(_on_detection_range_body_exited)
	if click_area:
		click_area.input_event.connect(_on_click_area_input_event)

func set_placed():
	if _is_placed: return
	_is_placed = true
	emit_signal("placed")
	_evaluate_and_set_target()
	_attempt_immediate_attack()

func _on_detection_range_body_entered(body: Node2D):
	if not _is_placed: return
	if body.is_in_group("enemies"):
		if not is_instance_valid(current_target):
			_evaluate_and_set_target()
			_attempt_immediate_attack()
		if body.has_signal("died") and not body.is_connected("died", _on_target_died):
			var flags = CONNECT_REFERENCE_COUNTED | CONNECT_ONE_SHOT
			body.died.connect(_on_target_died.bind(body), flags)

func _on_detection_range_body_exited(body: Node2D):
	if not _is_placed: return
	if body.is_in_group("enemies"):
		if current_target == body:
			_evaluate_and_set_target()

func _get_valid_targets_in_range() -> Array[Node2D]:
	if not is_instance_valid(detection_range):
		return []

	var overlapping_bodies = detection_range.get_overlapping_bodies()
	var valid_targets: Array[Node2D] = []
	for body in overlapping_bodies:
		if is_instance_valid(body) and body.is_in_group("enemies"):
			valid_targets.append(body)
	return valid_targets

func _select_best_target(valid_targets: Array[Node2D]) -> Node2D:
	if valid_targets.is_empty():
		return null
	var best_target_so_far: Node2D = null
	match targeting_priority:
		TargetingPriority.FIRST:
			var lowest_progress = INF
			for enemy in valid_targets:
				if enemy.has_method("get_path_progress"):
					var progress = enemy.get_path_progress()
					if progress < lowest_progress:
						lowest_progress = progress
						best_target_so_far = enemy
				else: printerr(name, ": Target missing get_path_progress()")
		TargetingPriority.LAST:
			var highest_progress = -INF
			for enemy in valid_targets:
				if enemy.has_method("get_path_progress"):
					var progress = enemy.get_path_progress()
					if progress > highest_progress:
						highest_progress = progress
						best_target_so_far = enemy
				else: printerr(name, ": Target missing get_path_progress()")
		TargetingPriority.CLOSEST:
			var closest_dist_sq = INF
			for enemy in valid_targets:
				var dist_sq = global_position.distance_squared_to(enemy.global_position)
				if dist_sq < closest_dist_sq:
					closest_dist_sq = dist_sq
					best_target_so_far = enemy
		TargetingPriority.STRONGEST:
			var highest_hp = -INF
			for enemy in valid_targets:
				if enemy.has_method("get_current_health"):
					var hp = enemy.get_current_health()
					if hp > highest_hp:
						highest_hp = hp
						best_target_so_far = enemy
				else: printerr(name, ": Target missing get_current_health()")
		TargetingPriority.WEAKEST:
			var lowest_hp = INF
			for enemy in valid_targets:
				if enemy.has_method("get_current_health"):
					var hp = enemy.get_current_health()
					if hp < lowest_hp:
						lowest_hp = hp
						best_target_so_far = enemy
				else: printerr(name, ": Target missing get_current_health()")
		_:
			best_target_so_far = valid_targets[0]
	if best_target_so_far == null and not valid_targets.is_empty():
		best_target_so_far = valid_targets[0]
	return best_target_so_far

func _evaluate_and_set_target():
	if not _is_placed: return
	var old_target = current_target
	var valid_targets_now = _get_valid_targets_in_range()
	var best_possible_target = _select_best_target(valid_targets_now)
	current_target = best_possible_target

func _on_target_died(enemy_that_died: Node2D):
	if current_target == enemy_that_died:
		_evaluate_and_set_target()
		_attempt_immediate_attack()

func _on_attack_timer_timeout():
	if not _is_placed: return
	_evaluate_and_set_target()
	_attempt_immediate_attack()

func _attempt_immediate_attack():
	if is_instance_valid(current_target) and _can_attack() and attack_timer.is_stopped():
		_perform_attack(current_target)
		attack_timer.start()

func _can_attack() -> bool:
	return is_instance_valid(current_target)

func _perform_attack(target: Node2D):
	pass

func get_range_upgrade_cost() -> int:
	return base_range_upgrade_cost + (current_level - 1) * cost_increase_per_level_range

func upgrade_range():
	if not (range_shape and range_shape.shape is CircleShape2D):
		return
	var new_radius = current_range_radius * base_range_increase_factor
	range_shape.shape.radius = new_radius
	current_range_radius = new_radius
	if _is_showing_range:
		queue_redraw()
	_apply_level_up_stats()

func _apply_level_up_stats():
	current_level += 1

func _on_click_area_input_event(viewport, event, shape_idx):
	if _is_placed and event is InputEventMouseButton and \
	   event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
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

func _draw():
	if _is_showing_range:
		if range_shape and range_shape.shape is CircleShape2D:
			var radius = range_shape.shape.radius
			draw_arc(Vector2.ZERO, radius, 0, TAU, 32, Color(1.0, 1.0, 1.0, 0.5), 2.0, true)

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		pass
