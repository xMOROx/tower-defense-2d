extends Node

signal all_waves_completed
signal wave_cleared(wave_number)
signal intermission_started(duration)

@export var intermission_duration: float = 5.0
@export var spawner_node_path: NodePath = NodePath()
@export var wave_data_file: String = ""

const SPAWN_INTERVAL_SCALING: float = 0.95

enum State {INIT, INTERMISSION, SPAWNING, WAVE_ACTIVE, FINISHED}
var current_state: State = State.INIT

@onready var intermission_timer: Timer = $IntermissionTimer
@onready var spawn_timer: Timer = $SpawnTimer

var spawner: Node
var _processed_wave_definitions: Array = []
var current_wave_index: int = -1
var wave_spawn_data: Array = []
var current_spawn_group_index: int = 0
var enemies_alive_this_wave: int = 0
var total_enemies_this_wave: int = 0
var enemies_spawned_this_wave: int = 0

func _ready():
	if not _validate_dependencies():
		set_process(false)
		return
		
	if not _load_and_process_wave_data():
		set_process(false)
		return

	intermission_timer.timeout.connect(_on_intermission_timer_timeout)
	spawn_timer.timeout.connect(_spawn_next_enemy)
	
	
	_start_intermission()

func _validate_dependencies() -> bool:
	if spawner_node_path.is_empty():
		printerr("WaveManager Error: Spawner Node Path not set!")
		return false
	spawner = get_node_or_null(spawner_node_path)
	if spawner == null or not spawner.has_method("spawn_specific_enemy"):
		printerr("WaveManager Error: Invalid Spawner node or spawner missing required method!")
		return false
	if intermission_timer == null or spawn_timer == null:
		printerr("WaveManager Error: Timer nodes not found!")
		return false
	return true
	
func _load_and_process_wave_data() -> bool:
	if not FileAccess.file_exists(wave_data_file):
		printerr("WaveManager Error: Wave data file not found at: ", wave_data_file)
		return false

	var file = FileAccess.open(wave_data_file, FileAccess.READ)
	if file == null:
		printerr("WaveManager Error: Could not open wave data file. Error code: ", FileAccess.get_open_error())
		return false

	var json_string = file.get_as_text()
	file.close()

	var json_parser_result = JSON.parse_string(json_string)
	if json_parser_result == null:
		printerr("WaveManager Error: Failed to parse JSON from file: ", wave_data_file, ". Check JSON syntax.")
		return false
	
	if not json_parser_result is Array:
		printerr("WaveManager Error: Root of JSON file must be an Array of wave objects.")
		return false

	var loaded_data = json_parser_result
	_processed_wave_definitions = []

	for i in range(loaded_data.size()):
		var wave_def = loaded_data[i]
		if not wave_def is Dictionary or not wave_def.has("spawns") or not wave_def["spawns"] is Array:
			printerr("WaveManager Error: Invalid wave definition format at index ", i)
			continue

		var processed_wave = wave_def.duplicate(true)
		processed_wave["spawns"] = []
		var wave_valid = true

		for j in range(wave_def["spawns"].size()):
			var spawn_group_data = wave_def["spawns"][j]
			if not spawn_group_data is Dictionary or not spawn_group_data.has("enemy_scene_path"):
				printerr("WaveManager Error: Invalid spawn group format in wave ", i, " group ", j)
				wave_valid = false
				break

			var path = spawn_group_data["enemy_scene_path"]
			if not ResourceLoader.exists(path):
				printerr("WaveManager Error: Enemy scene file not found at path '", path, "' referenced in wave ", i)
				wave_valid = false
				break

			var scene_resource = load(path) as PackedScene
			if scene_resource == null:
				printerr("WaveManager Error: Failed to load enemy scene as PackedScene from path '", path, "' in wave ", i)
				wave_valid = false
				break
				
			var processed_group = spawn_group_data.duplicate()
			processed_group["scene_resource"] = scene_resource
			processed_wave["spawns"].append(processed_group)

		if wave_valid:
			_processed_wave_definitions.append(processed_wave)

	if _processed_wave_definitions.is_empty() and not loaded_data.is_empty():
		printerr("WaveManager Error: No valid waves were processed from the data file!")
		return false
	elif _processed_wave_definitions.is_empty():
		printerr("WaveManager Warning: Wave data file seems empty or contains no waves.")
		
	return true

func _start_intermission():
	current_state = State.INTERMISSION
	intermission_timer.wait_time = intermission_duration
	intermission_timer.start()
	emit_signal("intermission_started", intermission_duration)
	GameManager.set_wave(current_wave_index + 1)

func _on_intermission_timer_timeout():
	_start_next_wave()

func _start_next_wave():
	current_wave_index += 1

	current_state = State.SPAWNING
	GameManager.set_wave(current_wave_index + 1)
	
	wave_spawn_data = []
	total_enemies_this_wave = 0
	var current_wave_def = _processed_wave_definitions[current_wave_index]
	
	for spawn_group in current_wave_def["spawns"]:
		var count = spawn_group["count"]
		wave_spawn_data.append({
			"scene_resource": spawn_group["scene_resource"],
			"remaining": count,
			"interval": max(0.1, spawn_group["interval"] * pow(SPAWN_INTERVAL_SCALING, current_wave_index)),
			"start_delay": spawn_group.get("start_delay", 0.0)
		})
		total_enemies_this_wave += count
		
	enemies_alive_this_wave = 0
	enemies_spawned_this_wave = 0
	current_spawn_group_index = 0
	
	
	_trigger_next_spawn_group()

func _trigger_next_spawn_group():
	if current_spawn_group_index >= wave_spawn_data.size():
		if enemies_spawned_this_wave >= total_enemies_this_wave:
			current_state = State.WAVE_ACTIVE
			if enemies_alive_this_wave <= 0:
				_wave_cleared()
		return

	var group_data = wave_spawn_data[current_spawn_group_index]
	
	var group_info_from_def = _processed_wave_definitions[current_wave_index]["spawns"][current_spawn_group_index]
	var is_first_spawn_in_group = (group_data["remaining"] == group_info_from_def["count"])
	
	spawn_timer.wait_time = group_data["start_delay"] if is_first_spawn_in_group else group_data["interval"]
	spawn_timer.start()
	

func _spawn_next_enemy():
	if current_state != State.SPAWNING: return

	if current_spawn_group_index >= wave_spawn_data.size():
		printerr("WaveManager Error: Tried to spawn with invalid spawn group index.")
		current_state = State.WAVE_ACTIVE
		if enemies_alive_this_wave <= 0: _wave_cleared()
		return
		
	var group_data = wave_spawn_data[current_spawn_group_index]

	var new_enemy = spawner.spawn_specific_enemy(group_data["scene_resource"])
	if new_enemy:
		enemies_spawned_this_wave += 1
		enemies_alive_this_wave += 1
		new_enemy.died.connect(_on_enemy_removed, CONNECT_ONE_SHOT | CONNECT_REFERENCE_COUNTED)
		new_enemy.leaked.connect(_on_enemy_removed, CONNECT_ONE_SHOT | CONNECT_REFERENCE_COUNTED)
	
	group_data["remaining"] -= 1

	var current_group_finished = (group_data["remaining"] <= 0)
	if current_group_finished:
		current_spawn_group_index += 1

	var more_enemies_in_wave = (enemies_spawned_this_wave < total_enemies_this_wave)

	if more_enemies_in_wave:
		_trigger_next_spawn_group()
	else:
		current_state = State.WAVE_ACTIVE
		if enemies_alive_this_wave <= 0:
			_wave_cleared()

func _on_enemy_removed(_enemy):
	if current_state == State.SPAWNING or current_state == State.WAVE_ACTIVE:
		enemies_alive_this_wave -= 1
		
		if enemies_alive_this_wave <= 0 and current_state == State.WAVE_ACTIVE:
			_wave_cleared()
		elif enemies_alive_this_wave < 0:
			printerr("WaveManager Warning: enemies_alive_this_wave count went below zero!")
			enemies_alive_this_wave = 0

func _wave_cleared():
	
	emit_signal("wave_cleared", GameManager.get_current_wave())
	if current_wave_index >= _processed_wave_definitions.size() - 1:
		_all_waves_completed()
		return
	else:
		_start_intermission()

func _all_waves_completed():
	
	current_state = State.FINISHED
	emit_signal("all_waves_completed")
	GameManager.level_completed()
