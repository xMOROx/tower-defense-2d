extends Node

@export var enemy_scene: PackedScene = null 
@export var enemy_path_nodepath: NodePath = NodePath()
@export var spawn_interval: float = 0.3

var path_node: Path2D = null
@onready var timer: Timer = $Timer 


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
		
	if timer == null:
		printerr("Spawner Error: Timer node not found as a child!")
		set_process(false)
		return
		
	timer.wait_time = spawn_interval
	timer.timeout.connect(_on_timer_timeout)
	
	
	print("Spawner ready. Enemy scene: ", enemy_scene.resource_path)
	print("Spawner path: ", path_node.name)
	print("Spawner interval: ", timer.wait_time)


func _on_timer_timeout():
	if enemy_scene == null or path_node == null:
		printerr("Spawner Error: Cannot spawn enemy, scene or path is missing.")
		timer.stop() 
		return

	print("Timer timeout! Spawning enemy.")
	var new_enemy = enemy_scene.instantiate()

	if not new_enemy is Node2D:
		printerr("Spawner Error: Instantiated scene root is not a Node2D/CharacterBody2D!")
		if new_enemy: new_enemy.queue_free()
		return

	if not new_enemy.has_method("set_path"):
		printerr("Spawner Error: The enemy scene's script is missing the 'set_path' function!")
		new_enemy.queue_free()
		return

	add_child(new_enemy) 

	new_enemy.set_path(path_node)
	
	print("Enemy spawned and path set.")
