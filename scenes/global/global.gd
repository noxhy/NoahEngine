extends Node2D

@export var debug_visible = true

var loading_screen = preload("res://scenes/global/loading_screen.tscn")
var fullscreen: bool = false

var freeplay_difficulty: int = 0
var freeplay_song_option: int = 0

var death_stats: Dictionary = {}

var song_scene = "res://test/test_scene.tscn"

var transitioning: bool = false


func _ready():
	# FPS Booster
	PhysicsServer2D.set_active(false)
	PhysicsServer3D.set_active(false)
	# Input responsiveness
	Input.set_use_accumulated_input(false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Peformance Test
	$"UI/Performance Label".visible = SaveManager.get_value("debug", "show_performance")
	if SaveManager.get_value("debug", "show_performance"):
		var performance_string: String = "FPS: " + str(Engine.get_frames_per_second())
		performance_string += "\nMEM: " + String.humanize_size(int(Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED)))
		performance_string += "\nDelta: " + str(snappedf(delta, 0.001))
		
		$"UI/Performance Label".text = performance_string
	
	if Input.is_action_just_pressed("fullscreen"):
		fullscreen = !fullscreen
		if fullscreen:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
	if OS.is_debug_build():
		if Input.is_action_just_pressed("reload"): 
			get_tree().reload_current_scene()
			get_tree().paused = false

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
func change_scene_to(path: String, transition: Variant = "down", screen: bool = true): 
	transitioning = true
	
	if transition != null: 
		
		Transitions.transition(transition)
		await Transitions.waiting
	
	get_tree().paused = false
	LoadingScreen.scene = path
	
	if screen: 
		get_tree().change_scene_to_packed(loading_screen)
	else: 
		get_tree().change_scene_to_file(path)
		if transition != null: 
			Transitions.resume()
#endregion

func bop_tween(object: Object, property: NodePath, original_val: Variant, final_val: Variant, duration: float, trans: Tween.TransitionType):
	var tween = create_tween()
	tween.set_trans(trans)
	
	tween.tween_property(object, property, final_val, duration * 0.0625).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(object, property, original_val, duration).set_ease(Tween.EASE_OUT).set_delay(duration * 0.0625)

func set_window_title(title: String):
	DisplayServer.window_set_title("Friday Night Funkin' Noah Engine 2.3 | " + title)

func format_number(num:float) -> String: 
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

func get_keycode_string(keycodes: Array):
	var strings: PackedStringArray
	for keycode in keycodes:
		strings.append(OS.get_keycode_string(keycode))
	
	return "/".join(strings)

# referenced via https://youtu.be/LSNQuFEDOyQ
## A frame independent lerp. Primary purpose is for the camera
## your decay should be around 1 - 25
func frame_independent_lerp(a, b, decay: float, delta: float): 
	return b + (a - b) * exp(-decay * delta)

#region Volume Visual
func show_volume():
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property($"UI/Voume Node", "position", Vector2(0, -360), 0.5)
	$"UI/Voume Node/Volume Sound".play()
	
	var master_volume = SaveManager.get_value(SaveManager.SEC_AUDIO, "master_volume")
	
	if AudioServer.is_bus_mute(0):
		$"UI/Voume Node/ColorRect/Label".text = "Muted"
	else:
		$"UI/Voume Node/ColorRect/Label".text = "Master Volume: " + str(int(master_volume * 100)) + "%"


func hide_volume():
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property($"UI/Voume Node", "position", Vector2(0, -392), 0.5)


func _on_hide_timer_timeout(): hide_volume()
#endregion

#region String to Tween
## Returns an array with index 0 containing transition type and
## index 1 containing easing type
func string_to_ease(tween: String) -> Array:
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
			return [Tween.TRANS_CUBIC, Tween.EASE_OUT]
		
		_:
			return [Tween.TRANS_LINEAR, Tween.EASE_IN]
#endregion
