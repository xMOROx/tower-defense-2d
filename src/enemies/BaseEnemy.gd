class_name BaseEnemy
extends CharacterBody2D

signal died(enemy_instance)
signal leaked(enemy_instance)

@export var speed: float = 100.0
@export var max_health: float = 10.0
@export var currency_reward: int = 5
@export var show_health_bar: bool = true
@export var show_only_when_damaged: bool = false

var current_health: float

var current_path_segment: PathSegment = null
var current_path_curve: Curve2D = null
var path_progress: float = 0.0

@onready var health_bar: ProgressBar = $HealthBar

func _ready():
	set_physics_process(false)
	visible = false
	if health_bar == null:
		printerr(name, ": HealthBar node not found!")

func start_on_path(initial_segment: PathSegment):
	if not is_instance_valid(initial_segment):
		printerr(name, ": Invalid initial_segment provided to start_on_path.")
		queue_free()
		return

	current_health = max_health
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = current_health
		if not show_health_bar:
			health_bar.visible = false
		elif show_only_when_damaged:
			health_bar.visible = false
		else:
			health_bar.visible = true

	_set_current_path_segment(initial_segment)

	if current_path_curve:
		visible = true
		set_process(true)
	else:
		printerr(name, ": Failed to initialize path from initial_segment.")
		queue_free()

func _set_current_path_segment(segment: PathSegment):
	current_path_segment = segment
	if not is_instance_valid(current_path_segment):
		current_path_curve = null
		return

	current_path_curve = current_path_segment.get_curve()
	if current_path_curve == null or current_path_curve.get_point_count() == 0:
		current_path_curve = null
		return
	
	path_progress = 0.0
	current_path_curve.bake_interval = 5
	global_position = current_path_curve.sample_baked(0.0)

func _process(delta):
	if not current_path_curve or not _is_active():
		return

	path_progress += speed * delta
	var path_length = current_path_curve.get_baked_length()

	if path_progress >= path_length:
		var next_segment = current_path_segment.get_next_path_segment()
		if is_instance_valid(next_segment):
			_set_current_path_segment(next_segment)
		else:
			GameManager.lose_life()
			emit_signal("leaked", self)
			queue_free()
			return
	else:
		var next_position = current_path_curve.sample_baked(path_progress, true)
		global_position = next_position
	
func take_damage(amount: float):
	current_health -= amount
	if health_bar:
		health_bar.value = current_health
		if show_only_when_damaged and current_health > 0:
			health_bar.visible = (current_health < max_health)
		elif show_health_bar:
			health_bar.visible = (current_health > 0)
	if current_health <= 0 and not is_queued_for_deletion():
		die()

func die():
	GameManager.add_currency(currency_reward)
	if health_bar: health_bar.visible = false
	emit_signal("died", self)
	call_deferred("queue_free")

func get_path_progress() -> float:
	return path_progress

func _is_active() -> bool:
	return visible and is_processing()
