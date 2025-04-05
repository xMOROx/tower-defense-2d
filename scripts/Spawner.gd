extends Node

@export var enemy_scene: PackedScene = null 
@export var enemy_path_nodepath: NodePath = NodePath()

var path_node: Path2D = null


func _ready():
	if enemy_scene == null:
		printerr("Spawner Error: Enemy Scene not set in the inspector!")
		set_process(false) 
		return

	if enemy_path_nodepath.is_empty():
		printerr("Spawner Error: Enemy Path NodePath not set in the inspector!")
		set_process(false)
		return
		
	path_node = get_node_or_null(enemy_path_nodepath)
	
	if path_node == null:
		printerr("Spawner Error: Could not find the Path2D node at path: ", enemy_path_nodepath)
		set_process(false)
		return
	if not path_node is Path2D:
		printerr("Spawner Error: The assigned node is not a Path2D! Path: ", enemy_path_nodepath)
		set_process(false)
		return

	
	print("Spawner ready. Enemy scene: ", enemy_scene.resource_path)
	print("Spawner path: ", path_node.name)


func spawn_specific_enemy(enemy_scene_to_spawn: PackedScene) -> Node2D:
	if path_node == null:
		printerr("Spawner Error: Cannot spawn, path_node is null.")
		return null
	if enemy_scene_to_spawn == null:
		printerr("Spawner Error: Cannot spawn, provided enemy_scene is null.")
		return null

	var new_enemy = enemy_scene_to_spawn.instantiate()

	if not new_enemy is Node2D:
		printerr("Spawner Error: Instantiated scene root is not Node2D!")
		if new_enemy: new_enemy.queue_free() 
		return null

	if not new_enemy.has_method("set_path"):
		printerr("Spawner Error: Enemy scene missing 'set_path' function!")
		new_enemy.queue_free() 
		return null

	var enemies_container = get_node_or_null("EnemyContainer") 
	if enemies_container:
		enemies_container.add_child(new_enemy)
	else:
		printerr("Spawner Warning: EnemiesContainer node not found, adding enemy as child of spawner.")
		add_child(new_enemy) # Fallback

	new_enemy.set_path(path_node)
	return new_enemy 
