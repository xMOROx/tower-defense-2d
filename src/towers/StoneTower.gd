class_name StoneTower
extends ProjectileTower

@export var body_level1_texture: Texture2D
@export var body_level2_texture: Texture2D
@export var body_level4_texture: Texture2D

@export var shooter1_level1_texture: Texture2D
@export var shooter1_level3_texture: Texture2D

@export var shooter2_level1_texture: Texture2D
@export var shooter2_level3_texture: Texture2D

@onready var body_sprite: Sprite2D = $Body
@onready var shooter1_sprite: Sprite2D = $shooter_1
@onready var shooter2_sprite: Sprite2D = $Body/shooter_2

func _ready() -> void:
	super._ready()

	_validate_sprite_nodes()

	_update_graphics()

func _validate_sprite_nodes():
	if not is_instance_valid(body_sprite):
		push_warning("StoneTowerGraphics: Missing 'Body' node or it's not a TextureRect!")
	if not is_instance_valid(shooter1_sprite):
		push_warning("StoneTowerGraphics: Missing 'shooter_1' node or it's not a TextureRect!")
	if not is_instance_valid(shooter2_sprite):
		push_warning("StoneTowerGraphics: Missing 'shooter_2' node or it's not a TextureRect!")


func _apply_level_up_stats() -> void:
	super._apply_level_up_stats()
	_update_graphics()

func _update_graphics() -> void:
	if is_instance_valid(body_sprite):
		if current_level >= 4 and body_level4_texture:
			body_sprite.texture = body_level4_texture
		elif current_level >= 2 and body_level2_texture:
			body_sprite.texture = body_level2_texture
		elif body_level1_texture:
			body_sprite.texture = body_level1_texture
		else:
			push_warning("StoneTowerGraphics: No texture assigned for Body at current level.")


	if is_instance_valid(shooter1_sprite):
		if current_level >= 3 and shooter1_level3_texture:
			shooter1_sprite.texture = shooter1_level3_texture
		elif shooter1_level1_texture:
			shooter1_sprite.texture = shooter1_level1_texture
		else:
			push_warning("StoneTowerGraphics: No texture assigned for Shooter_1 at current level.")


	if is_instance_valid(shooter2_sprite):
		if current_level >= 3 and shooter2_level3_texture:
			shooter2_sprite.texture = shooter2_level3_texture
		elif shooter2_level1_texture:
			shooter2_sprite.texture = shooter2_level1_texture
		else:
			push_warning("StoneTowerGraphics: No texture assigned for Shooter_2 at current level.")
