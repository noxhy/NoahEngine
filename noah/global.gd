extends Node

@onready var performance_label: Label = $"Performance Label"

var loading_screen: PackedScene = load("uid://ld5hyjhtx8wg")

var fullscreen: bool = false
var transitioning: bool = false

func vanilla_4097779270__ready():
	# FPS Booster
	PhysicsServer2D.set_active(false)
	PhysicsServer3D.set_active(false)
	_correct_window_size()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func vanilla_4097779270__process(delta: float) -> void:
	$"Volume Node".position.x = get_window().content_scale_size.x / 2
	performance_label.visible = SettingsManager.get_value(SettingsManager.SEC_DEBUG, &"show_performance")
	if SettingsManager.get_value(SettingsManager.SEC_DEBUG, "show_performance"):
		var performance_string: String = str("FPS: ", int(Engine.get_frames_per_second()),
		" • VMem: ", String.humanize_size(int(Performance.get_monitor(Performance.RENDER_TEXTURE_MEM_USED))))
		
		performance_label.text = performance_string
	
	if SettingsManager.get_value(SettingsManager.SEC_DEBUG, &"cap_fps"):
		Engine.max_fps = SettingsManager.get_value(SettingsManager.SEC_DEBUG, &"fps_cap")
	else:
		Engine.max_fps = 0
	
	if Input.is_action_just_pressed(&"fullscreen"):
		fullscreen = !fullscreen
		if fullscreen:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
	if OS.is_debug_build():
		if Input.is_action_just_pressed(&"reload"): 
			get_tree().reload_current_scene()
			get_tree().paused = false



#region Auto Pause
var manual_pause: bool = false
func vanilla_4097779270__notification(what: int) -> void:
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
func vanilla_4097779270_change_scene_to(path: String, transition: Variant = &"down", show_loading_screen: bool = true): 
	transitioning = true
	
	if transition: 
		Transitions.transition(transition)
		await Transitions.waiting
	
	get_tree().paused = false
	LoadingScreen.scene = path
	
	if show_loading_screen: 
		get_tree().change_scene_to_packed(loading_screen)
	else: 
		get_tree().change_scene_to_file(path)
		if transition: 
			Transitions.resume()
#endregion

func vanilla_4097779270_bop_tween(object: Object, property: NodePath, original_val: Variant, final_val: Variant, duration: float, trans: Tween.TransitionType):
	var tween = create_tween()
	tween.set_trans(trans)
	
	tween.tween_property(object, property, final_val, duration * 0.0625).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(object, property, original_val, duration).set_ease(Tween.EASE_OUT).set_delay(duration * 0.0625)

func vanilla_4097779270_set_window_title(title: String = ''):
	var app_title: String = ProjectSettings.get_setting("application/config/name") + \
		' ' + ProjectSettings.get_setting("application/config/version")
	
	if not title.is_empty():
		app_title += ' | ' + title
	
	DisplayServer.window_set_title(app_title)

func vanilla_4097779270_format_number(num:float) -> String: 
	var isNegative = num < 0.0
	
	num = absf(num)
	
	var string:String = ''
	var comma:String = ''
	var amount:float = floorf(num)
	
	while amount > 0:
		if string.length() > 0 and comma.length() <= 0:
			comma = ','
		
		var zeroes = ''
		var helper = amount - floorf(amount / 1000) * 1000
		amount = floorf(amount / 1000)
		
		if amount > 0:
			if helper < 100:
				zeroes += '0'
			if helper < 10:
				zeroes += '0'
		string = zeroes + str(int(helper)) + comma + string
	
	if string == '':
		string = '0'
	
	if isNegative:
		string = "-" + string
	
	return string

## Converts a float of seconds into a time format of MM:SS.mmm
func vanilla_4097779270_format_time(time: float) -> String:
	var minutes: int = floor(fmod(time, 3600.0) / 60.0)
	var seconds: int = floor(fmod(time, 60.0))
	var milliseconds: int = floor(fmod(time, 1.0) * 100.0)
	
	return "%02d:%02d.%02d" % [minutes, seconds, milliseconds]

func vanilla_4097779270_get_keycode_string(keycodes: Array):
	var strings: PackedStringArray
	for keycode in keycodes:
		strings.append(OS.get_keycode_string(keycode))
	
	return "/".join(strings)

# referenced via https://youtu.be/LSNQuFEDOyQ
## A frame independent lerp. Primary purpose is for the camera
## your decay should be around 1 - 25
func vanilla_4097779270_frame_independent_lerp(a, b, decay: float, delta: float) -> Variant: 
	return b + (a - b) * exp(-decay * delta)

#region Volume Visual
func vanilla_4097779270_show_volume():
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property($"Volume Node", "position:y", 0, 0.5)
	SoundManager.scroll.play()
	
	var master_volume = SettingsManager.get_value(SettingsManager.SEC_AUDIO, "master_volume")
	
	if AudioServer.is_bus_mute(0):
		$"Volume Node/Label".text = "Muted"
	else:
		$"Volume Node/Label".text = "Master Volume: " + str(roundi(master_volume * 100)) + "%"
	
	$"Volume Node/Hide Timer".start()


func vanilla_4097779270_hide_volume():
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property($"Volume Node", "position:y", -32, 0.5)


func vanilla_4097779270__on_hide_timer_timeout():
	hide_volume()
#endregion

#region String to Tween
## Returns an array with index 0 containing transition type and
## index 1 containing easing type
func vanilla_4097779270_string_to_ease(tween: String) -> Array:
	match tween:
		"backIn":
			return [Tween.TRANS_BACK, Tween.EASE_IN]
		
		"backInOut":
			return [Tween.TRANS_BACK, Tween.EASE_IN_OUT]
		
		"backOut":
			return [Tween.TRANS_BACK, Tween.EASE_OUT]
		
		"backOutIn":
			return [Tween.TRANS_BACK, Tween.EASE_OUT_IN]
		
		"bounceIn":
			return [Tween.TRANS_BOUNCE, Tween.EASE_IN]
		
		"bounceOut":
			return [Tween.TRANS_BOUNCE, Tween.EASE_IN_OUT]
		
		"bounceOut":
			return [Tween.TRANS_BOUNCE, Tween.EASE_OUT]
		
		"bounceOutIn":
			return [Tween.TRANS_BOUNCE, Tween.EASE_OUT_IN]
		
		"circkIn":
			return [Tween.TRANS_CIRC, Tween.EASE_IN]
		
		"circInOut":
			return [Tween.TRANS_CIRC, Tween.EASE_IN_OUT]
		
		"circOut":
			return [Tween.TRANS_CIRC, Tween.EASE_OUT]
		
		"circOutIn":
			return [Tween.TRANS_CIRC, Tween.EASE_OUT_IN]
		
		"cubeIn":
			return [Tween.TRANS_CUBIC, Tween.EASE_IN]
		
		"cubeInOut":
			return [Tween.TRANS_CUBIC, Tween.EASE_IN_OUT]
		
		"cubeOut":
			return [Tween.TRANS_CUBIC, Tween.EASE_OUT]
		
		"cubeOutIn":
			return [Tween.TRANS_CUBIC, Tween.EASE_OUT_IN]
		
		"cubeIn":
			return [Tween.TRANS_CUBIC, Tween.EASE_IN]
		
		"cubeInOut":
			return [Tween.TRANS_CUBIC, Tween.EASE_IN_OUT]
		
		"cubeOut":
			return [Tween.TRANS_CUBIC, Tween.EASE_OUT]
		
		"cubeOutIn":
			return [Tween.TRANS_CUBIC, Tween.EASE_OUT_IN]
		
		"elasticIn":
			return [Tween.TRANS_ELASTIC, Tween.EASE_IN]
		
		"elasticInOut":
			return [Tween.TRANS_ELASTIC, Tween.EASE_IN_OUT]
		
		"elasticOut":
			return [Tween.TRANS_ELASTIC, Tween.EASE_OUT]
		
		"elasticOutIn":
			return [Tween.TRANS_ELASTIC, Tween.EASE_OUT_IN]
		
		"expoIn":
			return [Tween.TRANS_EXPO, Tween.EASE_IN]
		
		"expoInOut":
			return [Tween.TRANS_EXPO, Tween.EASE_IN_OUT]
		
		"expoOut":
			return [Tween.TRANS_EXPO, Tween.EASE_OUT]
		
		"expoOutIn":
			return [Tween.TRANS_EXPO, Tween.EASE_OUT_IN]
		
		"quadIn":
			return [Tween.TRANS_QUAD, Tween.EASE_IN]
		
		"quadInOut":
			return [Tween.TRANS_QUAD, Tween.EASE_IN_OUT]
		
		"quadOut":
			return [Tween.TRANS_QUAD, Tween.EASE_OUT]
		
		"quadOutIn":
			return [Tween.TRANS_QUAD, Tween.EASE_OUT_IN]
		
		"quartIn":
			return [Tween.TRANS_QUAD, Tween.EASE_IN]
		
		"quartInOut":
			return [Tween.TRANS_QUAD, Tween.EASE_IN_OUT]
		
		"quartOut":
			return [Tween.TRANS_QUAD, Tween.EASE_OUT]
		
		"quartOutIn":
			return [Tween.TRANS_QUAD, Tween.EASE_OUT_IN]
		
		"quintIn":
			return [Tween.TRANS_QUAD, Tween.EASE_IN]
		
		"quintInOut":
			return [Tween.TRANS_QUAD, Tween.EASE_IN_OUT]
		
		"quintOut":
			return [Tween.TRANS_QUAD, Tween.EASE_OUT]
		
		"quintOutIn":
			return [Tween.TRANS_QUAD, Tween.EASE_OUT_IN]
		
		"sineIn":
			return [Tween.TRANS_SINE, Tween.EASE_IN]
		
		"sinetInOut":
			return [Tween.TRANS_SINE, Tween.EASE_IN_OUT]
		
		"sineOut":
			return [Tween.TRANS_SINE, Tween.EASE_OUT]
		
		"sineOutIn":
			return [Tween.TRANS_SINE, Tween.EASE_OUT_IN]
		
		"CLASSIC":
			return [Tween.TRANS_CUBIC, Tween.EASE_IN_OUT]
		
		_:
			return [Tween.TRANS_LINEAR, Tween.EASE_IN]
#endregion

func vanilla_4097779270_string_to_time(formatted_time: String) -> float:
	if formatted_time.ends_with("b"):
		return float(formatted_time.trim_suffix("b")) * GameManager.conductor.seconds_per_beat
	elif formatted_time.ends_with("s"):
		return float(formatted_time.trim_suffix("s")) * GameManager.conductor.seconds_per_step
	elif formatted_time.is_empty():
		return 0
	
	return float(formatted_time)

func vanilla_4097779270__correct_window_size() -> void:
	if not OS.get_name().to_lower().contains('windows'): 
		return
	
	var dpi = DisplayServer.screen_get_dpi(DisplayServer.window_get_current_screen()) / 96.0
	var new_size = get_window().size * dpi
	
	DisplayServer.window_set_size(new_size)
	
	var w_pos = DisplayServer.screen_get_position(DisplayServer.window_get_current_screen())
	var w_size = DisplayServer.screen_get_size(DisplayServer.window_get_current_screen())
	
	get_window().position.x = w_pos.x + (w_size.x - new_size.x) / 2
	get_window().position.y = w_pos.y + (w_size.y - new_size.y) / 2


# ModLoader Hooks - The following code has been automatically added by the Godot Mod Loader.


func _ready():
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_4097779270__ready, [], 4275194938)
	else:
		return vanilla_4097779270__ready()


func _process(delta: float):
	if _ModLoaderHooks.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_4097779270__process, [delta], 2180079172)
	else:
		vanilla_4097779270__process(delta)


func _notification(what: int):
	if _ModLoaderHooks.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_4097779270__notification, [what], 3984795500)
	else:
		vanilla_4097779270__notification(what)


func change_scene_to(path: String, transition: Variant=&"down", show_loading_screen: bool=true):
	if _ModLoaderHooks.any_mod_hooked:
		return await _ModLoaderHooks.call_hooks_async(vanilla_4097779270_change_scene_to, [path, transition, show_loading_screen], 2808686875)
	else:
		return await vanilla_4097779270_change_scene_to(path, transition, show_loading_screen)


func bop_tween(object: Object, property: NodePath, original_val: Variant, final_val: Variant, duration: float, trans: Tween.TransitionType):
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_4097779270_bop_tween, [object, property, original_val, final_val, duration, trans], 1934025673)
	else:
		return vanilla_4097779270_bop_tween(object, property, original_val, final_val, duration, trans)


func set_window_title(title: String=''):
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_4097779270_set_window_title, [title], 369062058)
	else:
		return vanilla_4097779270_set_window_title(title)


func format_number(num: float) -> String:
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_4097779270_format_number, [num], 517627703)
	else:
		return vanilla_4097779270_format_number(num)


func format_time(time: float) -> String:
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_4097779270_format_time, [time], 2359163133)
	else:
		return vanilla_4097779270_format_time(time)


func get_keycode_string(keycodes: Array):
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_4097779270_get_keycode_string, [keycodes], 2790046847)
	else:
		return vanilla_4097779270_get_keycode_string(keycodes)


func frame_independent_lerp(a, b, decay: float, delta: float):
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_4097779270_frame_independent_lerp, [a, b, decay, delta], 3689032464)
	else:
		return vanilla_4097779270_frame_independent_lerp(a, b, decay, delta)


func show_volume():
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_4097779270_show_volume, [], 2130273022)
	else:
		return vanilla_4097779270_show_volume()


func hide_volume():
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_4097779270_hide_volume, [], 705582967)
	else:
		return vanilla_4097779270_hide_volume()


func _on_hide_timer_timeout():
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_4097779270__on_hide_timer_timeout, [], 3169488929)
	else:
		return vanilla_4097779270__on_hide_timer_timeout()


func string_to_ease(tween: String) -> Array:
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_4097779270_string_to_ease, [tween], 2095834556)
	else:
		return vanilla_4097779270_string_to_ease(tween)


func string_to_time(formatted_time: String) -> float:
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_4097779270_string_to_time, [formatted_time], 2096382125)
	else:
		return vanilla_4097779270_string_to_time(formatted_time)


func _correct_window_size():
	if _ModLoaderHooks.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_4097779270__correct_window_size, [], 3637833736)
	else:
		vanilla_4097779270__correct_window_size()
