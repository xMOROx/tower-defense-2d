extends BaseEnemy
class_name AnimatedEnemy

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite

func _ready():
	super._ready()
	if animated_sprite == null:
		printerr(name, ": AnimatedSprite node not found! Animations will not work.")
	else:
		animated_sprite.animation_finished.connect(_on_animation_finished)

func start_on_path(initial_segment: PathSegment):
	super.start_on_path(initial_segment)
	if visible and is_processing():
		_update_movement_animation()

func _process(delta):
	super._process(delta) 

	_update_movement_animation()

func take_damage(amount: float):
	super.take_damage(amount)
	if animated_sprite and current_health > 0:
		if animated_sprite.animation != "die":
			animated_sprite.play("hurt")

func die():
	print(name, "dying (animation starting)...")
	GameManager.add_currency(currency_reward)
	if health_bar: health_bar.visible = false
	set_process(false)
	var collision_shape = find_child("CollisionShape2D")
	if collision_shape:
		collision_shape.disabled = true
	else:
		printerr(name, ": Could not find CollisionShape2D to disable.")

	if animated_sprite:
		animated_sprite.play("die")
	else:
		emit_signal("died", self)
		queue_free()

func _update_movement_animation():
	if not animated_sprite or current_health <= 0:
		return
		
	var current_anim = animated_sprite.animation
	if current_anim == "hurt" or current_anim == "die":
		return 

	var target_anim = "walk" 
	if speed > 150:
		if animated_sprite.sprite_frames.has_animation("run"):
			target_anim = "run"

	if current_anim != target_anim:
		if animated_sprite.sprite_frames.has_animation(target_anim):
			animated_sprite.play(target_anim)
		elif animated_sprite.sprite_frames.has_animation("walk"): 
			animated_sprite.play("walk")


func _on_animation_finished():
	if animated_sprite == null: return
	var finished_anim_name = animated_sprite.animation

	if finished_anim_name == "die":
		emit_signal("died", self)
		queue_free()

	elif finished_anim_name == "hurt":
		if current_health > 0:
			var target_anim = "walk"
			if speed > 150:
				if animated_sprite.sprite_frames.has_animation("run"):
					target_anim = "run"
			
			if animated_sprite.sprite_frames.has_animation(target_anim):
				animated_sprite.play(target_anim)
			elif animated_sprite.sprite_frames.has_animation("walk"): 
				animated_sprite.play("walk")
