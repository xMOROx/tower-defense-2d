extends Control

var main_menu_path = "res://scenes/ui/MainMenu.tscn"
var level_select_path = "res://scenes/ui/LevelSelect.tscn"
var game_over_path = "res://scenes/ui/GameOver.tscn"
var level_winner_path = "res://scenes/ui/LevelWinner.tscn"


var current_scene_node: Node = null
var last_played_level_path: String = ""

func _ready():
	var root = get_tree().root
	current_scene_node = root.get_child(root.get_child_count() - 1)

func goto_main_menu():
	_change_scene(main_menu_path)

func goto_level_select():
	_change_scene(level_select_path)
	
func goto_game_over():
	_change_scene(game_over_path)

func goto_level_winner():
	_change_scene(level_winner_path)

func goto_level(level_scene_path: String):
	if level_scene_path.is_empty() or not ResourceLoader.exists(level_scene_path):
		printerr("SceneManager Error: Invalid or non-existent level path provided:", level_scene_path)
		goto_main_menu()
		return
		
	last_played_level_path = level_scene_path
	_change_scene(level_scene_path)

func retry_level():
	if last_played_level_path.is_empty():
		printerr("SceneManager Error: No level path stored to retry!")
		goto_main_menu()
		return
	
	GameManager.reset_game()
	
	print("SceneManager: Retrying level:", last_played_level_path)
	_change_scene(last_played_level_path)

func _change_scene(scene_path: String):
	print("SceneManager: Changing scene to:", scene_path)

	if scene_path == main_menu_path or scene_path == level_select_path:
		pass

	call_deferred("_deferred_change_scene", scene_path)

func _deferred_change_scene(scene_path: String):
	if is_instance_valid(current_scene_node):
		current_scene_node.queue_free()
		current_scene_node = null

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
