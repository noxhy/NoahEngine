extends Node

# based off funkin cherry smile
# no it's not data shut up
const LOAD_PATH: String = 'user://settings.cfg'

## categories (this is our way of doing text enums
const SEC_PREFERENCES: String = 'preferences'
const SEC_GAMEPLAY: String = 'gameplay'
const SEC_AUDIO: String = 'audio'
const SEC_CHART: String = 'chart'
const SEC_DEBUG: String = 'debug'
const SEC_KEY_BINDS: String = 'keybinds'
const SEC_SONGS: String = 'songs'
const SEC_WEEKS: String = 'weeks'

var instance: ConfigFile
#these are the only functions u need to worry about

## Grabs a save value from instance
func get_value(section: String, key: String, fallback: Variant = null) -> Variant:
	return instance.get_value(section, key, fallback)

## Sets a save value in instance
func set_value(section: String, key: String, value: Variant) -> void:
	instance.set_value(section, key, value)

## Saves to disk
func flush() -> void:
	instance.save(LOAD_PATH)
	print('(SettingsManager): Saved preferences')

static var _defaults: Dictionary = {
	SEC_GAMEPLAY: {
		"offset": 0.0, ## Puts a delay on the notes
		"ghost_tapping": true, ## Allows tapping when no notes are active
		"downscroll": false, ## Notes go down instead of up, downscroll ui function is called
		"botplay": false, ## By default it only works for one strumline, more support for botplay on strumlines will be need to be per song script.
		"song_speed": 1.0,
		"scroll_speed_scale": 1.0
	},
	
	SEC_PREFERENCES: {
		"combo_ui": false, ## Spawns the combo shit on the ui instead of world
		"glow_notes": false, ## Glows notes when that are able to be pressed
		"note_splashes": true,
		"ui_bops": true, ## The UI w"ill bop when called, this affetcs the main menus too
		"hit_sounds": false,
		"fullscreen": false ##i dont like this here but where else
	},
	
	SEC_AUDIO: {
		"master_volume": 1, ## the global sound volume. Affects everything
		"sfx_volume": 1, ## The sfx volume. Only Affects sfx
		"music_volume": 1, ## The music volume. Only applied to music tracks
		"is_muted": false
	},
	
	SEC_DEBUG: {
		"show_performance": true, ## Shows FPS, Memory, delta and shit,
		"cap_fps": true, ## caps fps
		"fps_cap": int(DisplayServer.screen_get_refresh_rate())
	},
	
	SEC_CHART: {
		"auto_save": true,
		"start_at_current_position": false,
	},
	
	SEC_KEY_BINDS: {
		"note_left": [KEY_LEFT, KEY_A],
		"note_down": [KEY_DOWN, KEY_S],
		"note_up": [KEY_UP, KEY_W],
		"note_right": [KEY_RIGHT, KEY_D],
		
		"kill": [KEY_R],
		
		# Ui Keybinds
		
		"ui_plus": [KEY_EQUAL],
		"ui_minus": [KEY_MINUS],
		
		"fullscreen": [KEY_F11],
		
		"ui_cancel": [KEY_ESCAPE],
		"ui_accept": [KEY_ENTER, KEY_KP_ENTER],
		"character_select": [KEY_TAB],
		
		"ui_left": [KEY_LEFT, KEY_A],
		"ui_down": [KEY_DOWN, KEY_S],
		"ui_up": [KEY_UP, KEY_W],
		"ui_right": [KEY_RIGHT, KEY_D],
		"mute": [KEY_0]
	},
	
}


func _ready() -> void:
	instance = get_default()
	load_values()
	load_keybinds()

func load_values() -> void:
	if not FileAccess.file_exists(LOAD_PATH):
		print('(SettingsManager): Preferences not detected. Using defaults')
		return
	
	var temp_config = ConfigFile.new()
	var loadError: Error = temp_config.load(LOAD_PATH)
	
	if loadError == Error.OK:
		for section:String in temp_config.get_sections():
			for key in temp_config.get_section_keys(section):
				if instance.has_section_key(section, key):
					
					var instance_value = instance.get_value(section, key)
					
					if instance_value is Array: # this is kinda weird but sure
						var saved_value = temp_config.get_value(section, key)
						
						if saved_value and instance_value.size() != saved_value.size():
							for idx in range(instance_value.size() - 1):
								instance_value[idx] = saved_value[idx]
							
							instance.set_value(section, key, instance_value)
							continue
					
					instance.set_value(section, key, temp_config.get_value(section, key))
	
	# sets fullscreen
	var fullscreen = SettingsManager.get_value(SettingsManager.SEC_PREFERENCES, 'fullscreen')
	
	var mode = DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED
	DisplayServer.window_set_mode(mode)
	
	print("(SettingsManager): Preferences loaded")

func get_default() -> ConfigFile:
	var temp_config = ConfigFile.new()
	
	for section:String in _defaults.keys():
		var section_val:Dictionary = _defaults.get(section, {})
		for key:String in section_val.keys():
			temp_config.set_value(section, key, section_val.get(key))
	
	return temp_config

func get_keybind(keybind_name: String) -> Array : 
	return instance.get_value(SEC_KEY_BINDS, keybind_name)

func set_keybind(keybind_name: String, keycode: int, index: int):
	var new_keycodes = instance.get_value(SEC_KEY_BINDS, keybind_name)
	new_keycodes[index] = keycode
	
	instance.set_value(SEC_KEY_BINDS,keybind_name,new_keycodes)

func load_keybinds():
	for key in instance.get_section_keys(SEC_KEY_BINDS):
		InputMap.action_erase_events(key)
		
		for bind in get_keybind(key):
			var new_key = InputEventKey.new()
			new_key.keycode = bind
			InputMap.action_add_event(key, new_key)
		
	print("(SettingsManager): Keybinds loaded")
