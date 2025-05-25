extends BaseTower
class_name ProjectileTower

@export var projectile_scene: PackedScene = null
@export var base_attack_damage: float = 5.0
@export var base_damage_increase_per_level: float = 3.0
@export var base_damage_upgrade_cost: int = 25
@export var cost_increase_per_level_damage: int = 15

var current_attack_damage: float

func _ready():
	super._ready()
	current_attack_damage = base_attack_damage
	if projectile_scene == null:
		printerr(name, ": Projectile Scene not assigned!")

func _perform_attack(target: Node2D):
	if projectile_scene == null: return
	
	call_deferred("_spawn_projectile", target)

func _spawn_projectile(target: Node2D):
	var new_projectile = projectile_scene.instantiate()
	if not new_projectile is Node or not new_projectile.has_method("launch"):
		printerr(name, ": Invalid projectile scene or missing launch() method.")
		if new_projectile: new_projectile.queue_free()
		return

	get_tree().root.add_child(new_projectile)
	new_projectile.global_position = global_position
	
	new_projectile.call_deferred("launch", target, current_attack_damage)

func _apply_level_up_stats():
	super._apply_level_up_stats()
	# Add specific stat updates for this tower type if needed after level increments

func get_damage_upgrade_cost() -> int:
	return base_damage_upgrade_cost + (current_level - 1) * cost_increase_per_level_damage

func upgrade_damage():
	current_attack_damage += base_damage_increase_per_level
	_apply_level_up_stats()
