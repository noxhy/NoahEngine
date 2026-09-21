extends Resource
class_name NoahSettings
## The raw structure for the user settings. The actual instance used by the game is accessed by [member SettingsManager.data]

## Applies a visual offset to the notes
var offset: float = 0.0
## Allows tapping when no notes are active
var ghost_tapping: bool = true
## Notes go down instead of up
var downscroll: bool = false
## By default it only works for one strumline, more support for botplay on strumlines will be need to be per song script.
var botplay: bool = false
## The playback rate for a song
var song_speed: float = 1.0
## Multiplier applied onto the notes scroll speed.
var scroll_speed_scale: float = 1.0
## Spawns the combo sprites onto the UI layer rather than world space.
var combo_ui: bool = false
## Glows notes when that are able to be pressed
var glow_notes: bool = false

## Whether notesplashes should spawn when hitting a [code]Sick[/code]
var note_splashes: bool = true
## The UI will bop when called, this affects menus as well
var ui_bops: bool = true

## Explanatory.
var hit_sounds: bool = false
## Whether the game is in fullscreen mode or not
var fullscreen: bool = false
## Adds a black underlay below the ui.
var underlay_opacity: float = 0.0

## The master volume. Affects all music and sounds
var master_volume: float = 0.5
## The sfx volume. Affects only sound effects.
var sfx_volume: float = 1.0
## The music volume. Affects only the music.
var music_volume: float = 1.0
## Whether the game is currently muted.
var is_muted: bool = false

## Whether to show the current framerate and memory usage.
var show_performance: bool = true
## Whether the frame rate should be uncapped or not.
var cap_fps: bool = true
## The caapped fps to target. Only works when [member cap_fps] is [code]true[/code]
var fps_cap: int = int(DisplayServer.screen_get_refresh_rate())
## The games framerate will be locked to monitor refresh rate. May increase input delay but prevents screen tearing.
var vsync: bool = false

## Tells the chart editor to save chart after any change
var chart_auto_save: bool = true
## Editor playtesting will start at the current position within the editor
var chart_start_at_current_position: bool = false
## Plays a sound effect every step
var chart_hit_sound_on_step: bool = false
## Plays a sound effect every beat
var chart_hit_sound_on_beat: bool = false
var chart_hit_sounds: bool = true

## A dictionary of all keybinds used in game.
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
## A dictionary of all controller binds used in game.
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
