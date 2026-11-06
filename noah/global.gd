extends Node
## Singleton that contains utilities and other misc behavior

@onready var performance_label: Label = $"Performance Label"
@onready var volume_display: VolumeDisplay = $"Volume Display"

var loading_screen: PackedScene = load("uid://ld5hyjhtx8wg")

var transitioning: bool = false
var current_controller: int = -1

func _ready() -> void:
	rescale_window_by_dpi()
	Input.joy_connection_changed.connect(changed_contoller)
	
	if not OS.is_debug_build():
		RenderingServer.set_default_clear_color(Color.BLACK)
	
	SettingsManager.load_values()
	SettingsManager.load_keybinds()
	SaveManager.load()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	performance_label.visible = SettingsManager.data.show_performance
	if performance_label.visible:
		var performance_string: String = str("FPS: ", int(Engine.get_frames_per_second()),
		" • VMem: ", String.humanize_size(int(Performance.get_monitor(Performance.RENDER_TEXTURE_MEM_USED))))
		
		performance_label.text = performance_string
	
	if SettingsManager.data.cap_fps:
		Engine.max_fps = SettingsManager.data.fps_cap
	else:
		Engine.max_fps = 0

func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"fullscreen", false, true):
		SettingsManager.data.fullscreen = !SettingsManager.data.fullscreen
		SettingsManager.load_fullscreen_mode()
		SettingsManager.flush()
	elif event.is_action_pressed(&"reload", false, true) and OS.is_debug_build():
		get_tree().reload_current_scene()
		get_tree().paused = false
	
func changed_contoller(device: int, connected: bool) -> void:
	if connected or !Input.get_connected_joypads().front():
		current_controller = device
	else:
		current_controller = Input.get_connected_joypads().front()

#region Auto Pause
var manual_pause: bool = false
func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		if !get_tree().paused:
			if OS.is_debug_build():
				return
			manual_pause = false
			get_tree().paused = true
	elif what == NOTIFICATION_APPLICATION_FOCUS_IN:
		if !manual_pause:
			get_tree().paused = false
#endregion

#region Scene Changing
## Changes the main scene to another with a transition
func change_scene_to(path: String, transition: StringName = Constants.DEFAULT_TRANSITION, show_loading_screen: bool = false) -> void:
	
	if not ResourceLoader.exists(path):
		printerr("Cannot switch to '%s' as it does not exist" % path)
		return
	
	transitioning = true
	
	if transition: 
		TransitionManager.transition(transition)
		await TransitionManager.waiting
	
	get_tree().paused = false
	LoadingScreen.scene = path
	
	if show_loading_screen: 
		get_tree().change_scene_to_packed(loading_screen)
	else: 
		get_tree().change_scene_to_file(path)
		if transition: 
			TransitionManager.resume()
#endregion

## appends a suffix to the application name.
func set_window_title(suffix: String = '') -> void:
	var app_title: String = ProjectSettings.get_setting("application/config/name") + \
		' ' + ProjectSettings.get_setting("application/config/version")
	
	if not suffix.is_empty():
		app_title += ' | ' + suffix
	
	DisplayServer.window_set_title(app_title)

#region Volume Node
func set_volume_display(path: String) -> void:
	if not ResourceLoader.exists(path):
		printerr("(Global): Volume Node at \"%s\" does not exist." % path)
		return
	
	if volume_display:
		volume_display.queue_free()
	
	volume_display = load(path).instantiate()
	add_child(volume_display)
#endregion

## Updates the window size based on display dpi/scale
func rescale_window_by_dpi() -> void:
	if OS.get_name().to_lower().contains('windows'): 
		var dpi = DisplayServer.screen_get_dpi(DisplayServer.window_get_current_screen()) / 96.0
		var new_size = get_window().size * dpi
		DisplayServer.window_set_size(new_size)
	elif DisplayServer.screen_get_scale() != 1.0:
		get_window().size *= DisplayServer.screen_get_scale()
	get_window().move_to_center()
