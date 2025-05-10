class_name BaseSpawner
extends Node

@export var initial_path_segment_nodepath: NodePath = NodePath()
@export var enemy_container_nodepath: NodePath = NodePath("EnemiesContainer")

var initial_segment_node: PathSegment = null
var enemies_container: Node = null

func _ready():
	if initial_path_segment_nodepath.is_empty():
		printerr("BaseSpawner Error: Initial Path Segment NodePath not set!")
		set_process(false)
		return
	initial_segment_node = get_node_or_null(initial_path_segment_nodepath)
	if not initial_segment_node is PathSegment:
		printerr("BaseSpawner Error: Assigned Initial Path Segment is not a PathSegment node!")
		initial_segment_node = null
		set_process(false)
		return
		
	if not enemy_container_nodepath.is_empty():
		enemies_container = get_node_or_null(enemy_container_nodepath)
		if enemies_container == null:
			printerr("BaseSpawner Warning: Could not find Enemy Container at: ", enemy_container_nodepath, ". Enemies will be spawner children.")
	else:
		printerr("BaseSpawner Info: Enemy Container NodePath not set. Enemies will be spawner children.")
	
	print("BaseSpawner initialized. Initial Segment: ", initial_segment_node.name if initial_segment_node else "None")

func spawn_specific_enemy(enemy_scene_to_spawn: PackedScene) -> Node2D: # Return type Node2D for clarity
	if not is_instance_valid(initial_segment_node):
		printerr("BaseSpawner Error: Cannot spawn, initial_segment_node is invalid.")
		return null
	if enemy_scene_to_spawn == null:
		printerr("BaseSpawner Error: Cannot spawn, provided enemy_scene is null.")
		return null

	var new_enemy = enemy_scene_to_spawn.instantiate()

	if not new_enemy is BaseEnemy: 
		printerr("BaseSpawner Error: Instantiated scene root is not a BaseEnemy derivative or Node2D!")
		if new_enemy: new_enemy.queue_free()
		return null

	if not new_enemy.has_method("start_on_path"):
		printerr("BaseSpawner Error: Enemy scene '", enemy_scene_to_spawn.resource_path, "' is missing 'start_on_path(segment: PathSegment)' function!")
		new_enemy.queue_free()
		return null

	if enemies_container and is_instance_valid(enemies_container):
		enemies_container.add_child(new_enemy)
	else:
		add_child(new_enemy)

	new_enemy.start_on_path(initial_segment_node)
	
	return new_enemy
