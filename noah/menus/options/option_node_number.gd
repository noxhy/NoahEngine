extends OptionNode
class_name NumberOptionNode

@export var minimum: float = 0.0
@export var maximum: float = 100.0
@export var step: float = 1.0
@export var value_name: String = ""
@export var value_scale = 1.0 # Multiplies this value (Used for shit like milliseconds)

@onready var spin_box:SpinBox = %Value

# Called when the node enters the scene tree for the first time.
func vanilla_3317215981__ready():
	var savedValue = clampf(SettingsManager.get_value(setting_category, setting_name, 1.0) / value_scale, minimum, maximum);
	
	spin_box.get_line_edit().context_menu_enabled = false
	spin_box.step = step
	spin_box.set_value_no_signal(savedValue)
	spin_box.min_value = minimum
	spin_box.max_value = maximum
	%Label.text = display_name
	%Value.suffix = value_name

func vanilla_3317215981__on_spin_box_value_changed(value):
	if value == 1.0:
		value = int(value)
	if value_scale == 1.0:
		int(value_scale)
	
	SettingsManager.set_value(setting_category, setting_name, value * value_scale)
	SoundManager.scroll.play()


# ModLoader Hooks - The following code has been automatically added by the Godot Mod Loader.


func _ready():
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_3317215981__ready, [], 1468168737)
	else:
		return vanilla_3317215981__ready()


func _on_spin_box_value_changed(value):
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_3317215981__on_spin_box_value_changed, [value], 4186780879)
	else:
		return vanilla_3317215981__on_spin_box_value_changed(value)
