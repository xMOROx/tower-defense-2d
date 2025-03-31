extends CharacterBody2D

@export var speed: float = 100.0  # Pixels per second
@export var max_health: float = 10.0
@export var currency_reward: int = 5 
@export var show_health_bar: bool = true 
@export var show_only_when_damaged: bool = false # Override above if true

var current_health: float

# Variables to hold path information
var path_node: Path2D = null
var path_curve: Curve2D = null
var path_progress: float = 0.0

@onready var health_bar: ProgressBar = $HealthBar


signal died 


func _ready():
	set_physics_process(false) 
	
	visible = false 
	if health_bar == null:
		printerr(name + ": HealthBar node not found!")

func set_path(new_path: Path2D):
	if new_path == null:
		printerr("Enemy received a null path!")
		queue_free() 
		return
		
	path_node = new_path
	if path_node.curve == null:
		printerr("Path node doesn't have a valid Curve2D resource!")
		queue_free() 
		return
		
	path_curve = path_node.curve
	
	path_progress = 0.0
	
	path_curve.bake_interval = 5 
	
	if path_curve.get_point_count() > 0:
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
		
		global_position = path_curve.sample_baked(0.0) 
		visible = true
		set_process(true)
		set_physics_process(false)
	else:
		printerr("Path curve has no points!")
		queue_free()


func _process(delta):
	if path_curve == null:
		return

	path_progress += speed * delta

	var path_length = path_curve.get_baked_length()

	if path_progress >= path_length:
		print("Enemy reached the end! (Leaked)") 
		
		GameManager.lose_life() 

		
		queue_free() 
		return 

	var next_position = path_curve.sample_baked(path_progress, true) 

	global_position = next_position
	
func take_damage(amount: float):
	current_health -= amount
	print(name + " took " + str(amount) + " damage. HP left: " + str(current_health)) 

	# Optional: Add visual feedback like flashing red here later

	if health_bar:
		health_bar.value = current_health
		if show_only_when_damaged and current_health > 0:
			health_bar.visible = (current_health < max_health) 
		elif show_health_bar: 
			health_bar.visible = (current_health > 0)

	if current_health <= 0:
		die()

func die():
	print(name + " died!")
	# Future: Add explosion effect, etc.
	
	GameManager.add_currency(currency_reward)
	
	if health_bar:
		health_bar.visible = false
	
	emit_signal("died") 
	queue_free() 
	
