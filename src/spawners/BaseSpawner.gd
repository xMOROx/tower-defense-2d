class_name BaseSpawner
extends Node

@export var enemy_path_nodepath: NodePath = NodePath()
@export var enemy_container_nodepath: NodePath = NodePath("EnemyContainer")

var path_node: Path2D = null
var enemies_container: Node = null


func _ready():
	if enemy_path_nodepath.is_empty():
		printerr("BaseSpawner Error: Enemy Path NodePath not set in the inspector!")
		set_process(false)
		return
		
	path_node = get_node_or_null(enemy_path_nodepath)
	
	if path_node == null:
		printerr("BaseSpawner Error: Could not find the Path2D node at path: ", enemy_path_nodepath)
		set_process(false)
		return
	if not path_node is Path2D:
		printerr("BaseSpawner Error: The assigned node is not a Path2D! Path: ", enemy_path_nodepath)
		set_process(false)
		return
		
	if not enemy_container_nodepath.is_empty():
		enemies_container = get_node_or_null(enemy_container_nodepath)
		if enemies_container == null:
			printerr("BaseSpawner Warning: Could not find the Enemy Container node at path: ", enemy_container_nodepath, ". Enemies will be added as children of the spawner.")
	else:
		printerr("BaseSpawner Info: Enemy Container NodePath not set. Enemies will be added as children of the spawner.")

	
	print("BaseSpawner initialized. Path: ", path_node.name)


func spawn_specific_enemy(enemy_scene_to_spawn: PackedScene) -> Node2D:
	if path_node == null:
		printerr("BaseSpawner Error: Cannot spawn, path_node is null. Was _ready() called and successful?")
		return null
	if enemy_scene_to_spawn == null:
		printerr("BaseSpawner Error: Cannot spawn, provided enemy_scene is null.")
		return null

	var new_enemy = enemy_scene_to_spawn.instantiate()

	if not new_enemy is Node2D:
		printerr("BaseSpawner Error: Instantiated scene root is not Node2D!")
		if new_enemy: new_enemy.queue_free()
		return null

	if not new_enemy.has_method("set_path"):
		printerr("BaseSpawner Error: Enemy scene '", enemy_scene_to_spawn.resource_path, "' is missing the 'set_path(path: Path2D)' function!")
		new_enemy.queue_free()
		return null

	if enemies_container:
		enemies_container.add_child(new_enemy)
	else:
		add_child(new_enemy) # Fallback

	new_enemy.set_path(path_node)
	
	if path_node.curve and path_node.curve.point_count > 0:
		var start_position = path_node.curve.get_point_position(0)
		if enemies_container and enemies_container != self:
			new_enemy.global_position = path_node.global_position + start_position
		else:
			new_enemy.global_position = path_node.global_position + start_position

	return new_enemy
