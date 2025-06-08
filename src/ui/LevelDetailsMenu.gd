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
@export var texture_button : TextureButton # Could use a TextureRect instead.
@export var menu_node : Node

@onready var wave_manager: Node
@onready var scorpion_left: Node
@onready var scorpion_beaten: Node

func _ready() -> void:
	if texture_button:
		texture_button.pressed.connect(toggle_collapsible)
	else:
		push_warning("texture_button is not assigned in the editor!")

	wave_manager = get_node("/root/Level/World/WaveManager")
	if wave_manager:
		if wave_manager.has_signal("wave_stats_changed"):
			wave_manager.wave_stats_changed.connect(_on_wave_stats_changed)
		else:
			push_warning("WaveManager does not have 'wave_stats_changed' signal defined.")
	else:
		push_warning("WaveManager not found at /root/Level/World/WaveManager!")

	if menu_node:
		scorpion_left = menu_node.get_node("ScorpionLeft")
		scorpion_beaten = menu_node.get_node("ScorpionBeaten")

	if not is_instance_valid(scorpion_left):
		push_warning("ScorpionLeft not found as a child of menu_node or is not valid!")
	if not is_instance_valid(scorpion_beaten):
		push_warning("ScorpionBeaten not found as a child of menu_node or is not valid!")
	else:
		push_warning("menu_node is not assigned in the editor!")


func toggle_collapsible() -> void:
	if collapsible:
		collapsible.open_tween_toggle.call_deferred()
	else:
		push_warning("collapsible is not assigned in the editor!")

func _on_wave_stats_changed(wave_stats: Dictionary) -> void:
	var scorpion_path = "res://scenes/enemies/Scorpion.tscn"

	if wave_stats.has(scorpion_path):
		var scorpion_stats = wave_stats[scorpion_path]
		var left_count = scorpion_stats.get("left", 0)
		var beaten_count = scorpion_stats.get("beaten", 0)

		if is_instance_valid(scorpion_left) and scorpion_left is Label:
			scorpion_left.text = str(left_count)
		elif is_instance_valid(scorpion_left):
			push_warning("ScorpionLeft is not a Label. Cannot set text directly.")

		if is_instance_valid(scorpion_beaten) and scorpion_beaten is Label:
			scorpion_beaten.text = str(beaten_count)
		elif is_instance_valid(scorpion_beaten): # If it's a different node type
			push_warning("ScorpionBeaten is not a Label. Cannot set text directly.")
	else:
		print("No Scorpion stats found in wave_stats.")
		if is_instance_valid(scorpion_left) and scorpion_left is Label:
			scorpion_left.text = "0"
		if is_instance_valid(scorpion_beaten) and scorpion_beaten is Label:
			scorpion_beaten.text = "0"
