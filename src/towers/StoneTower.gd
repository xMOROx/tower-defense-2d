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
@onready var stone_projectile: Sprite2D = $shooter_1/stone

# --- Nowe zmienne dla animacji ---
@export var float_height: float = 40.0  # Jak wysoko/nisko mają poruszać się shootery w pikselach
@export var float_duration: float = 0.18 # Czas trwania jednej fazy ruchu (np. tylko w górę lub tylko w dół)
var _current_tween: Tween = null
var _current_tween2: Tween = null
var shooter1_initial_y: float # Początkowa pozycja Y dla shooter1_sprite
var shooter2_initial_y: float # Początkowa pozycja Y dla shooter2_sprite

func _start_floating_animation():
	# Zatrzymaj poprzednią animację, jeśli istnieje, aby uniknąć nakładania się
	if _current_tween:
		_current_tween.kill()

	if _current_tween2:
		_current_tween2.kill()

	# Sprawdź, czy węzły shooterów są prawidłowe, zanim spróbujesz je animować
	if not is_instance_valid(shooter1_sprite) or not is_instance_valid(shooter2_sprite):
		push_warning("StoneTowerGraphics: Shooter sprites not valid for animation.")
		return

	# Stwórz nowy obiekt Tween. Nie używamy .set_loops(), bo chcemy jeden cykl.
	_current_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_current_tween2 = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	# --- Faza 1: Ruch w górę dla obu shooterów (równolegle) ---
	_current_tween.tween_property(shooter1_sprite, "position:y", shooter1_initial_y - float_height, float_duration)
	_current_tween2.tween_property(shooter2_sprite, "position:y", shooter2_initial_y - float_height * 2, float_duration)

	# --- Faza 2: Ruch w dół dla obu shooterów (równolegle, po zakończeniu Fazy 1) ---
	# Użycie .chain() sprawia, że następne tweeny rozpoczną się dopiero po zakończeniu poprzedniego kroku.
	# W tym przypadku, ruchy w dół dla obu shooterów rozpoczną się, gdy oba zakończą ruch w górę.
	_current_tween.chain()
	_current_tween2.chain()
	_current_tween.tween_property(shooter1_sprite, "position:y", shooter1_initial_y, float_duration)
	_current_tween2.tween_property(shooter2_sprite, "position:y", shooter2_initial_y, float_duration)

func _ready() -> void:
	super._ready()

	_validate_sprite_nodes()

	_update_graphics()

	if is_instance_valid(shooter1_sprite):
		shooter1_initial_y = shooter1_sprite.position.y
	if is_instance_valid(shooter2_sprite):
		shooter2_initial_y = shooter2_sprite.position.y

func _spawn_projectile(target: Node2D):
	super._spawn_projectile(target)

	_start_floating_animation()


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
