@tool
extends EditorPlugin

func _enter_tree():
	print("Editor: Reset Progress Plugin Loaded")
	add_tool_menu_item("Reset Game Progress", _reset_progress_callback)

func _exit_tree():
	remove_tool_menu_item("Reset Game Progress")

func _reset_progress_callback():
	var state_manager_script = load("res://src/managers/StateManager.gd") # Adjust path if needed
	if state_manager_script:
		var temp_state_manager = state_manager_script.new()
		temp_state_manager.reset_progress()
		print("Editor: Game progress has been reset (save file deleted).")
		temp_state_manager.free()
	else:
		printerr("Editor: Could not load StateManager script.")
		
