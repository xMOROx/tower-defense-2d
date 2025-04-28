extends Control

var main_menu_path = "res://scenes/ui/MainMenu.tscn"
var level_select_path = "res://scenes/ui/LevelSelect.tscn"
var game_over_path = "res://scenes/ui/GameOver.tscn"
var level_winner_path = "res://scenes/ui/LevelWinner.tscn"
var pause_menu_path = "res://scenes/ui/PauseMenu.tscn"

var current_scene_node: Node = null
var last_played_level_path: String = ""
var pause_menu_instance: Node = null
var is_game_paused: bool = false

func _ready():
	var root = get_tree().root
	current_scene_node = root.get_child(root.get_child_count() - 1)

func goto_main_menu():
	_change_scene(main_menu_path, false)

func goto_level_select():
	_change_scene(level_select_path, false)
	
func goto_game_over():
	_change_scene(game_over_path, false)

func goto_level_winner(stars):
	_change_scene(level_winner_path, false, {"stars": stars})

func goto_level(level_scene_path: String):
	if level_scene_path.is_empty() or not ResourceLoader.exists(level_scene_path):
		printerr("SceneManager Error: Invalid or non-existent level path provided:", level_scene_path)
		goto_main_menu()
		return
		
	last_played_level_path = level_scene_path
	_change_scene(level_scene_path, true)

func retry_level():
	if last_played_level_path.is_empty():
		printerr("SceneManager Error: No level path stored to retry!")
		goto_main_menu()
		return

	GameManager.reset_game()

	
	_change_scene(last_played_level_path, true)

func _change_scene(scene_path: String, is_level: bool = false, data: Dictionary = {}):
	

	call_deferred("_deferred_change_scene", scene_path, is_level, data)
	
func _deferred_change_scene(scene_path: String, is_level: bool = false, data: Dictionary = {}):
	if is_instance_valid(current_scene_node):
		current_scene_node.queue_free()
		current_scene_node = null

	_remove_pause_menu()

	var next_scene_res = ResourceLoader.load(scene_path)
	if next_scene_res == null:
		printerr("SceneManager Error: Failed to load scene resource:", scene_path)
		if scene_path != main_menu_path:
			_deferred_change_scene(main_menu_path)
		return

	current_scene_node = next_scene_res.instantiate()
	if current_scene_node == null:
		printerr("SceneManager Error: Failed to instantiate scene:", scene_path)
		if scene_path != main_menu_path:
			_deferred_change_scene(main_menu_path)
		return

	get_tree().root.add_child(current_scene_node)
	if is_level:
		_add_pause_menu()
		
	if !data.is_empty() and is_instance_valid(current_scene_node) and current_scene_node.has_method("set_data"):
		current_scene_node.call("set_data", data)	

		
func get_last_played_level_path() -> String:
	return last_played_level_path

func _add_pause_menu():
	if pause_menu_instance == null and ResourceLoader.exists(pause_menu_path):
		var pause_scene = ResourceLoader.load(pause_menu_path)
		if pause_scene:
			pause_menu_instance = pause_scene.instantiate()
			if current_scene_node.get_node("HUD"):
				current_scene_node.get_node("HUD").add_child(pause_menu_instance)
			else:
				printerr("SceneManager Error: Current scene does not have a HUD node.")
				return
			pause_menu_instance.visible = false # Initially hidden
		else:
			printerr("SceneManager Error: Failed to load PauseMenu scene.")

func _remove_pause_menu():
	if is_instance_valid(pause_menu_instance):
		pause_menu_instance.queue_free()
		pause_menu_instance = null
		get_tree().paused = false
		is_game_paused = false

func toggle_pause_menu():
	if pause_menu_instance == null:
		return # this is not pausable scene

	is_game_paused = !is_game_paused
	get_tree().paused = is_game_paused
	if is_instance_valid(pause_menu_instance):
		pause_menu_instance.visible = is_game_paused

func _on_resume_game():
	toggle_pause_menu()

func _on_quit_to_menu():
	goto_main_menu()
