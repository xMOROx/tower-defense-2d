extends Area2D

@export var speed: float = 400.0 # Pixels per second


var target: Node2D = null       # The enemy node this projectile is chasing
var damage: float = 0.0         # Damage to deal upon hit

# Optional: Set a maximum lifetime to prevent stray projectiles
@onready var lifetime_timer: Timer = Timer.new()

func _ready():
	lifetime_timer.wait_time = 5.0 # Projectile exists for max 5 seconds
	lifetime_timer.one_shot = true
	lifetime_timer.timeout.connect(queue_free) # Destroy self when timer times out
	add_child(lifetime_timer)
	body_entered.connect(_on_body_entered)


func launch(target_enemy: Node2D, projectile_damage: float):
	target = target_enemy
	damage = projectile_damage
	
	lifetime_timer.start()
	
	if is_instance_valid(target):
		look_at(target.global_position)


func _physics_process(delta):
	if not is_instance_valid(target):
		print("Projectile: Target lost.")
		queue_free()
		return

	var direction = (target.global_position - global_position).normalized()
	global_position += direction * speed * delta


func _on_body_entered(body: Node2D):
	if body == target and is_instance_valid(body):
		if body.has_method("take_damage"):
			print("Projectile hit:", body.name)
			body.take_damage(damage)
		else:
			printerr("Projectile hit target, but target has no take_damage method!")
		queue_free()
