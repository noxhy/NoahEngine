extends OptionNode
class_name NumberOptionNode

@export var minimum: float = 0.0
@export var maximum: float = 100.0
@export var step: float = 1.0
@export var value_name: String = ""
@export var value_scale = 1.0 # Multiplies this value (Used for shit like milliseconds)

@onready var spin_box:SpinBox = %Value

# Called when the node enters the scene tree for the first time.
func _ready():
	var savedValue = clampf(SaveManager.get_pref(setting_category, setting_name, 1.0) / value_scale, minimum, maximum);
	
	#print('obj ' ,setting_name, ' min ', minimum, ' max ', maximum, ' savedVal ', savedValue)
	spin_box.get_line_edit().context_menu_enabled = false
	spin_box.step = step
	spin_box.set_value_no_signal(savedValue)
	spin_box.min_value = minimum
	spin_box.max_value = maximum
	%Label.text = display_name
	%Value.suffix = value_name

func _on_spin_box_value_changed(value):
	if value == 1.0:
		value = int(value)
	if value_scale == 1.0:
		int(value_scale)
	
	SaveManager.set_pref(setting_category, setting_name, value * value_scale)
	SoundManager.scroll.play()
