extends Control

@onready var damage_button: Button = $Panel/VBox/DamageButton
@onready var range_button: Button = $Panel/VBox/RangeButton
@onready var close_button: Button = $Panel/VBox/Close

var current_tower: Node2D = null

func _ready():
	if damage_button == null: printerr("ERROR: DamageButton node not found at path $Panel/VBox/DamageButton")
	if range_button == null: printerr("ERROR: RangeButton node not found at path $Panel/VBox/RangeButton")
	if close_button == null: printerr("ERROR: Close button node not found at path $Panel/VBox/Close")

	hide()
	if damage_button: damage_button.pressed.connect(_on_damage_button_pressed)
	if range_button: range_button.pressed.connect(_on_range_button_pressed)
	if close_button: close_button.pressed.connect(_on_close_button_pressed)

	GameManager.currency_changed.connect(_on_currency_changed)
func show_for_tower(tower: Node2D):
	if not is_instance_valid(tower):
		printerr("Upgrade Menu: Attempted to show for invalid tower.")
		current_tower = null
		hide()
		return

	current_tower = tower
	print("Upgrade Menu: Targeting tower '", current_tower.name, "'")

	_update_button_states()

	show()

func _on_damage_button_pressed():
	if not is_instance_valid(current_tower): return
	if not current_tower.has_method("get_damage_upgrade_cost") or \
	   not current_tower.has_method("upgrade_damage"): return

	var cost = current_tower.get_damage_upgrade_cost()
	if GameManager.spend_currency(cost):
		current_tower.upgrade_damage()
	else:
		print("Damage upgrade failed - Insufficient funds?")

func _on_range_button_pressed():
	if not is_instance_valid(current_tower): return
	if not current_tower.has_method("get_range_upgrade_cost") or \
	   not current_tower.has_method("upgrade_range"): return

	var cost = current_tower.get_range_upgrade_cost()
	if GameManager.spend_currency(cost):
		current_tower.upgrade_range()
	else:
		print("Range upgrade failed - Insufficient funds?")

func _on_close_button_pressed():
	hide()
	current_tower = null

# --- Update UI Function ---
func _update_button_states():
	if not is_instance_valid(current_tower):
		print("Upgrade Menu: Update skipped - current_tower is invalid.")
		if damage_button: damage_button.disabled = true
		if range_button: range_button.disabled = true
		return

	if not damage_button or not range_button:
		printerr("Upgrade Menu: Update failed - Button nodes are null!")
		return

	print("Upgrade Menu: Updating for '", current_tower.name, "', Level:", current_tower.current_level)
	var current_gold = GameManager.get_currency()

	if current_tower.has_method("get_damage_upgrade_cost"):
		var damage_cost = current_tower.get_damage_upgrade_cost()
		print("Upgrade Menu: Fetched Damage Cost:", damage_cost)
		damage_button.text = "Upgrade Damage (Cost: %d)" % damage_cost
		var can_afford_damage = GameManager.can_afford(damage_cost)
		damage_button.disabled = not can_afford_damage 
		print("Upgrade Menu: Can Afford Damage?", can_afford_damage, "-> Button Disabled:", damage_button.disabled)
	else:
		damage_button.text = "Upgrade Damage (N/A)"
		damage_button.disabled = true

	if current_tower.has_method("get_range_upgrade_cost"):
		var range_cost = current_tower.get_range_upgrade_cost()
		print("Upgrade Menu: Fetched Range Cost:", range_cost)
		range_button.text = "Upgrade Range (Cost: %d)" % range_cost 
		var can_afford_range = GameManager.can_afford(range_cost)
		range_button.disabled = not can_afford_range 
		print("Upgrade Menu: Can Afford Range?", can_afford_range, "-> Button Disabled:", range_button.disabled)
	else:
		range_button.text = "Upgrade Range (N/A)"
		range_button.disabled = true

	print("Upgrade Menu: Finished _update_button_states()")


func _on_currency_changed(new_currency: int):
	if is_visible() and is_instance_valid(current_tower):
		print("Upgrade Menu: Currency changed, updating button states.")
		_update_button_states()

func _process(delta):
	if is_visible() and not is_instance_valid(current_tower):
		print("Upgrade Menu: Target tower disappeared, hiding menu.")
		hide()
		current_tower = null
