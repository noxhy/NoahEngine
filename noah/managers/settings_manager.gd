extends Node

const LOAD_PATH: String = 'user://settings.cfg'


## The actual save instance. Access save values through this
var data: NoahSettings


## categories (this is our way of doing text enums
const SEC_PREFERENCES: String = 'preferences'
const SEC_GAMEPLAY: String = 'gameplay'
const SEC_AUDIO: String = 'audio'
const SEC_CHART: String = 'chart'
const SEC_DEBUG: String = 'debug'
const SEC_KEY_BINDS: String = 'keybinds'
const SEC_CONTROLLER_BINDS: String = 'controller_binds'

## @deprecated: Access directly from [member data] instead.
## Grabs a save value from instance
func get_value(section: String, key: String, fallback: Variant = null) -> Variant:
	return data.get(key)

## @deprecated: Access directly from [member data] instead.
## Sets a save value in instance
func set_value(section: String, key: String, value: Variant) -> void:
	data.set(key, value)

func _ready() -> void:
	data = NoahSettings.new()
	
	load_values()
	load_keybinds()

## Saves [member data] to disk.
func flush() -> void:
	var conf: ConfigFile = ConfigFile.new()
	
	var save_vars: Array = data.get_script().get_script_property_list()
	
	for v in save_vars:
		if not v['usage'] == PropertyUsageFlags.PROPERTY_USAGE_SCRIPT_VARIABLE:
			continue
		conf.set_value("", v["name"], data.get(v["name"]))
	
	conf.save(LOAD_PATH)
	print('(SettingsManager): Saved preferences')

## Loads player settings and applies it to [member data]
func load_values() -> void:
	
	if not FileAccess.file_exists(LOAD_PATH):
		print('(SettingsManager): Preferences not detected. Using defaults')
		return
	
	var dummy = NoahSettings.new()
	
	var conf: ConfigFile = ConfigFile.new()
	conf.load(LOAD_PATH)
	
	var save_vars: Array = data.get_script().get_script_property_list()
	
	for v in save_vars:
		if not v['usage'] == PropertyUsageFlags.PROPERTY_USAGE_SCRIPT_VARIABLE:
			continue
		var val = conf.get_value("", v['name'], dummy.get(v['name']))
		data.set(v["name"], val)
	
	# sets fullscreen
	var mode = DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN if data.fullscreen else DisplayServer.WINDOW_MODE_WINDOWED
	DisplayServer.window_set_mode(mode)
	
	var vsync_mode = DisplayServer.VSYNC_ENABLED if data.vsync else DisplayServer.VSYNC_DISABLED
	DisplayServer.window_set_vsync_mode(vsync_mode)
	
	print("(SettingsManager): Preferences loaded")
	
## Returns an array of key binds from a key
func get_keybind(keybind_name: String) -> Array:
	return data.key_binds.get(keybind_name, [])

## Returns an array of controller binds from a key
func get_controller_bind(bind_name: String) -> Array:
	return data.joy_binds.get(bind_name, [])

func set_keybind(keybind_name: String, keycode: int, index: int) -> void:
	var new_keycodes = data.key_binds.get(keybind_name)
	new_keycodes[index] = keycode
	
	data.key_binds.set(keybind_name, new_keycodes)

func set_controller_bind(bind_name: String, button_index: int, index: int) -> void:
	var new_keycodes = data.joy_binds.get(bind_name)
	new_keycodes[index] = button_index
	
	data.joy_binds.set(bind_name, new_keycodes)

## Updates [InputMap] to use the player defined keybinds
func load_keybinds() -> void:
	for key in data.key_binds.keys():
		InputMap.action_erase_events(key)
		
		for bind in get_keybind(key):
			var new_key = InputEventKey.new()
			new_key.keycode = bind
			InputMap.action_add_event(key, new_key)
	
	for bind_id in data.joy_binds.keys():
		var new_key: InputEvent
		for bind in get_controller_bind(bind_id):
			if bind >= 100:
				new_key = InputEventJoypadMotion.new()
				new_key.axis = bind - 100
			else:
				new_key = InputEventJoypadButton.new()
				new_key.button_index = bind
			
			InputMap.action_add_event(bind_id, new_key)

#region Joystick Controls
	var event: InputEventJoypadMotion
	for axis in [JOY_AXIS_LEFT_X, JOY_AXIS_RIGHT_X]:
		event = InputEventJoypadMotion.new()
		event.axis = axis
		event.axis_value = -1
		InputMap.action_add_event("note_left", event)
		InputMap.action_add_event("menu_left", event)
		
		event = InputEventJoypadMotion.new()
		event.axis = axis
		event.axis_value = 1
		InputMap.action_add_event("note_right", event)
		InputMap.action_add_event("menu_right", event)
	
	for axis in [JOY_AXIS_LEFT_Y, JOY_AXIS_RIGHT_Y]:
		event = InputEventJoypadMotion.new()
		event.axis = axis
		event.axis_value = -1
		InputMap.action_add_event("note_up", event)
		InputMap.action_add_event("menu_up", event)
		
		event = InputEventJoypadMotion.new()
		event.axis = axis
		event.axis_value = 1
		InputMap.action_add_event("note_down", event)
		InputMap.action_add_event("menu_down", event)
#endregion
	
	print("(SettingsManager): Key and Controller binds loaded")


#region Controller Button Names
func translate_joy_bind(device: int, bind: int) -> String:
	var device_name: String = Input.get_joy_name(device)
	var device_lower: String = device_name.to_lower()
	
	var joy_button_names: Dictionary = {
		JoyButton.JOY_BUTTON_A: "A",
		JoyButton.JOY_BUTTON_B: "B",
		JoyButton.JOY_BUTTON_X: "X",
		JoyButton.JOY_BUTTON_Y: "Y",
		JoyButton.JOY_BUTTON_LEFT_SHOULDER: "LB",
		JoyButton.JOY_BUTTON_RIGHT_SHOULDER: "RB",
		JoyButton.JOY_BUTTON_BACK: "Back",
		JoyButton.JOY_BUTTON_START: "Start",
		JoyButton.JOY_BUTTON_LEFT_STICK: "LS Click",
		JoyButton.JOY_BUTTON_RIGHT_STICK: "RS Click",
		JoyButton.JOY_BUTTON_DPAD_UP: "D-Pad Up",
		JoyButton.JOY_BUTTON_DPAD_DOWN: "D-Pad Down",
		JoyButton.JOY_BUTTON_DPAD_LEFT: "D-Pad Left",
		JoyButton.JOY_BUTTON_DPAD_RIGHT: "D-Pad Right",
		(JoyAxis.JOY_AXIS_TRIGGER_LEFT + 100): "LT",
		(JoyAxis.JOY_AXIS_TRIGGER_RIGHT + 100): "LR"
	}
	
	if device_lower.contains("dualsense") or device_lower.contains("dualshock"):
		joy_button_names = {
			JoyButton.JOY_BUTTON_A: "❌",
			JoyButton.JOY_BUTTON_B: "⭕",
			JoyButton.JOY_BUTTON_X: "□",
			JoyButton.JOY_BUTTON_Y: "🔺",
			JoyButton.JOY_BUTTON_LEFT_SHOULDER: "L1",
			JoyButton.JOY_BUTTON_RIGHT_SHOULDER: "R1",
			JoyButton.JOY_BUTTON_BACK: "Select",
			JoyButton.JOY_BUTTON_START: "Options",
			JoyButton.JOY_BUTTON_LEFT_STICK: "L3",
			JoyButton.JOY_BUTTON_RIGHT_STICK: "R3",
			JoyButton.JOY_BUTTON_DPAD_UP: "D-Pad Up",
			JoyButton.JOY_BUTTON_DPAD_DOWN: "D-Pad Down",
			JoyButton.JOY_BUTTON_DPAD_LEFT: "D-Pad Left",
			JoyButton.JOY_BUTTON_DPAD_RIGHT: "D-Pad Right",
			(JoyAxis.JOY_AXIS_TRIGGER_LEFT + 100): "L2",
			(JoyAxis.JOY_AXIS_TRIGGER_RIGHT + 100): "R2"
		}
	elif device_lower.contains("nintendo"):
		joy_button_names = {
			JoyButton.JOY_BUTTON_A: "B",
			JoyButton.JOY_BUTTON_B: "A",
			JoyButton.JOY_BUTTON_X: "Y",
			JoyButton.JOY_BUTTON_Y: "X",
			JoyButton.JOY_BUTTON_LEFT_SHOULDER: "L",
			JoyButton.JOY_BUTTON_RIGHT_SHOULDER: "R",
			JoyButton.JOY_BUTTON_BACK: "-",
			JoyButton.JOY_BUTTON_START: "+",
			JoyButton.JOY_BUTTON_LEFT_STICK: "LS Click",
			JoyButton.JOY_BUTTON_RIGHT_STICK: "RS Click",
			JoyButton.JOY_BUTTON_DPAD_UP: "D-Pad Up",
			JoyButton.JOY_BUTTON_DPAD_DOWN: "D-Pad Down",
			JoyButton.JOY_BUTTON_DPAD_LEFT: "D-Pad Left",
			JoyButton.JOY_BUTTON_DPAD_RIGHT: "D-Pad Right",
			(JoyAxis.JOY_AXIS_TRIGGER_LEFT + 100): "ZL",
			(JoyAxis.JOY_AXIS_TRIGGER_RIGHT + 100): "ZR"
		}
	
	return joy_button_names.get(bind, "?")
#endregion
