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

func _ready() -> void:
	texture_button.pressed.connect(toggle_collapsible)


func toggle_collapsible() -> void:
	collapsible.open_tween_toggle.call_deferred()
