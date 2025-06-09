extends Node

## Logic for changing the container sizing of the CollapsibleContainer to
## demonstrate the different directions it can fold/unfold in.

# The same as Control.LayoutPreset enum but can reference its keys unlike built-in 
# enums. Just used to print the keys as strings. 
# Can also make into strings like how the size_flag_to_string() function
# makes Control.SizeFlags into strings, but this is just another way.
enum LayoutPreset {
   PRESET_TOP_LEFT, 
   PRESET_TOP_RIGHT,
   PRESET_BOTTOM_LEFT,
   
   PRESET_BOTTOM_RIGHT,
   PRESET_CENTER_LEFT,
   PRESET_CENTER_TOP,
   
   PRESET_CENTER_RIGHT,
   PRESET_CENTER_BOTTOM,
   PRESET_CENTER,
   
   PRESET_LEFT_WIDE,
   PRESET_TOP_WIDE,
   PRESET_RIGHT_WIDE,
   PRESET_BOTTOM_WIDE,
   
   PRESET_VCENTER_WIDE,
   PRESET_HCENTER_WIDE,
}

@export var collapsible : CollapsibleContainer
@export var texture_button : TextureButton
@export var menu_node : Node

@onready var wave_manager: Node

# Example: {"res://scenes/enemies/Scorpion.tscn": {"left_label": Node, "beaten_label": Node}}
var _enemy_stat_labels: Dictionary = {}

func _ready() -> void:
	# --- Standard UI setup ---
	if texture_button:
		texture_button.pressed.connect(toggle_collapsible)
	else:
		push_warning("texture_button is not assigned in the editor!")

	# --- WaveManager connection ---
	# It's highly recommended to use an AutoLoad (Singleton) for WaveManager
	# for easier global access, e.g., wave_manager = WaveManagerGlobal
	wave_manager = get_node("/root/Level/World/WaveManager")
	if wave_manager:
		if wave_manager.has_signal("wave_stats_changed"):
			wave_manager.wave_stats_changed.connect(_on_wave_stats_changed)
		else:
			push_warning("WaveManager does not have 'wave_stats_changed' signal defined.")
	else:
		push_warning("WaveManager not found at /root/Level/World/WaveManager!")

	# --- Initialize enemy stat labels ---
	if menu_node:
		_enemy_stat_labels = {
			"res://scenes/enemies/Scorpion.tscn": {
				"left_label": menu_node.get_node_or_null("ScorpionLeft"),
				"beaten_label": menu_node.get_node_or_null("ScorpionBeaten")
			},
			# Add other enemy types here:
			# "res://scenes/enemies/Goblin.tscn": {
			#     "left_label": menu_node.get_node_or_null("GoblinLeft"),
			#     "beaten_label": menu_node.get_node_or_null("GoblinBeaten")
			# },
			# "res://scenes/enemies/Orc.tscn": {
			#     "left_label": menu_node.get_node_or_null("OrcLeft"),
			#     "beaten_label": menu_node.get_node_or_null("OrcBeaten")
			# }
		}

		# Basic validation for initialized labels
		for enemy_path in _enemy_stat_labels.keys():
			var labels = _enemy_stat_labels[enemy_path]
			if not is_instance_valid(labels.get("left_label")):
				push_warning("Label for '%s' (left) not found or invalid!" % enemy_path)
			if not is_instance_valid(labels.get("beaten_label")):
				push_warning("Label for '%s' (beaten) not found or invalid!" % enemy_path)
	else:
		push_warning("menu_node is not assigned in the editor!")


func toggle_collapsible() -> void:
	if collapsible:
		collapsible.open_tween_toggle.call_deferred()
	else:
		push_warning("collapsible is not assigned in the editor!")


func _on_wave_stats_changed(wave_stats: Dictionary) -> void:
	# 'wave_stats' dictionary format:
	# {
	#   "res://scenes/enemies/Scorpion.tscn": {"left": 10, "beaten": 15},
	#   "res://scenes/enemies/Goblin.tscn": {"left": 5, "beaten": 8},
	#   ...
	# }

	# Iterate through all enemy types for which we have UI labels
	for enemy_path in _enemy_stat_labels.keys():
		var labels = _enemy_stat_labels[enemy_path]
		var left_label = labels.get("left_label")
		var beaten_label = labels.get("beaten_label")

		if wave_stats.has(enemy_path):
			var enemy_stats = wave_stats[enemy_path]
			var left_count = enemy_stats.get("left", 0)
			var beaten_count = enemy_stats.get("beaten", 0)

			# Update 'left' label
			if is_instance_valid(left_label) and left_label is Label:
				left_label.text = str(left_count)
			elif is_instance_valid(left_label):
				push_warning("Label for '%s' (left) is not a Label. Cannot set text directly." % enemy_path)

			# Update 'beaten' label
			if is_instance_valid(beaten_label) and beaten_label is Label:
				beaten_label.text = str(beaten_count)
			elif is_instance_valid(beaten_label):
				push_warning("Label for '%s' (beaten) is not a Label. Cannot set text directly." % enemy_path)
		else:
			# If no stats for this enemy type are present in the wave_stats dictionary,
			# reset its displayed counts to 0.
			if is_instance_valid(left_label) and left_label is Label:
				left_label.text = "0"
			if is_instance_valid(beaten_label) and beaten_label is Label:
				beaten_label.text = "0"
