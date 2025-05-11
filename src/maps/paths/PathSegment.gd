class_name PathSegment
extends Node

@export var path_2d_node: Path2D

@export var next_segments: Array[NodePath]

var _cached_next_segment_nodes: Array[PathSegment] = []

func _ready():
	if path_2d_node == null:
		printerr("PathSegment '", name, "' is missing its Path2D node assignment!")
		return
	if path_2d_node.curve == null or path_2d_node.curve.get_point_count() == 0:
		printerr("PathSegment '", name, "' has an unassigned or empty curve in its Path2D node.")

	for segment_node_path in next_segments:
		var node = get_node_or_null(segment_node_path)
		if node is PathSegment:
			_cached_next_segment_nodes.append(node)
		elif node != null:
			printerr("PathSegment '", name, "': NodePath '", segment_node_path, "' in next_segments does not point to a PathSegment.")
		else:
			printerr("PathSegment '", name, "': NodePath '", segment_node_path, "' in next_segments is invalid or node not found.")

func get_curve() -> Curve2D:
	if path_2d_node:
		return path_2d_node.curve
	return null

func get_next_path_segment() -> PathSegment:
	if not _cached_next_segment_nodes.is_empty():
		return _cached_next_segment_nodes.pick_random()
	return null 
