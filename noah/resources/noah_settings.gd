extends Resource
class_name NoahSettings

#TODO add docsto every var

## Applies a visual offset to the notes
var offset: float = 0.0
## Allows tapping when no notes are active
var ghost_tapping: bool = false
## Notes go down instead of up, downscroll ui function is called
var downscroll: bool = false
## By default it only works for one strumline, more support for botplay on strumlines will be need to be per song script.
var botplay: bool = false
## The playback rate for a song
var song_speed: float = 1.0

var scroll_speed_scale: float = 1.0
## Spawns the combo shit on the ui instead of world
var combo_ui: bool = false
## Glows notes when that are able to be pressed
var glow_notes: bool = false

var note_splashes: bool = false
## The UI w"ill bop when called, this affetcs the main menus too
var ui_bops: bool = true

var hit_sounds: bool = false
##i dont like this here but where else,
var fullscreen: bool = false
## Adds a black ColorRect on the UI node with the given opacity.
var underlay_opacity: float = 0.0

var master_volume: float = 0.5
var sfx_volume: float = 1.0
var music_volume: float = 1.0
var is_muted: bool = false

var show_performance: bool = true
var cap_fps: bool = true
var fps_cap: int = int(DisplayServer.screen_get_refresh_rate())

var chart_auto_save: bool = true
var chart_start_at_current_position: bool = false
var chart_hit_sound_on_step: bool = false
var chart_hit_sound_on_beat: bool = false
var chart_hit_sounds: bool = true

var key_binds: Dictionary[String, Array] = {
	"note_left": [KEY_LEFT, KEY_A],
	"note_down": [KEY_DOWN, KEY_S],
	"note_up": [KEY_UP, KEY_W],
	"note_right": [KEY_RIGHT, KEY_D],
	
	"pause": [KEY_ENTER, KEY_ESCAPE, KEY_BACKSPACE],
	"kill": [KEY_R],
	
	# Ui Keybinds
	"volume_up": [KEY_EQUAL],
	"volume_down": [KEY_MINUS],
	
	"fullscreen": [KEY_F11],
	
	"menu_accept": [KEY_ENTER, KEY_Z],
	"menu_cancel": [KEY_ESCAPE, KEY_X],
	
	"character_select": [KEY_TAB],
	
	"menu_left": [KEY_LEFT, KEY_A],
	"menu_down": [KEY_DOWN, KEY_S],
	"menu_up": [KEY_UP, KEY_W],
	"menu_right": [KEY_RIGHT, KEY_D],
	"mute": [KEY_0]
}

var joy_binds: Dictionary[String, Array] = {
	"note_left": [JOY_BUTTON_X, JOY_BUTTON_DPAD_LEFT],
	"note_down": [JOY_BUTTON_A, JOY_BUTTON_DPAD_DOWN],
	"note_up": [JOY_BUTTON_Y, JOY_BUTTON_DPAD_UP],
	"note_right": [JOY_BUTTON_B, JOY_BUTTON_DPAD_RIGHT],
	
	"pause": [JOY_BUTTON_START],
	"kill": [JOY_BUTTON_BACK],
	
	# Ui Keybinds
	"menu_accept": [JOY_BUTTON_A],
	"menu_cancel": [JOY_BUTTON_B],
	"character_select": [JOY_BUTTON_START],
	
	"menu_left": [JOY_BUTTON_DPAD_LEFT],
	"menu_down": [JOY_BUTTON_DPAD_DOWN],
	"menu_up": [JOY_BUTTON_DPAD_UP],
	"menu_right": [JOY_BUTTON_DPAD_RIGHT]
}
