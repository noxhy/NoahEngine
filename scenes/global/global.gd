extends Node2D

@export var debug_visible = true

var loading_screen = preload("res://scenes/global/loading_screen.tscn")
var fullscreen = false

var freeplay_difficulty: int = 0
var freeplay_song_option: int = 0

var death_stats: Dictionary = {}

var song_scene = "res://test/test_scene.tscn"

var transitioning: bool = false


func _ready():
	SettingsManager.load_settings()
	# FPS Booster
	PhysicsServer2D.set_active(false)
	PhysicsServer3D.set_active(false)
	# Input responsiveness
	Input.set_use_accumulated_input(false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Peformance Test
	$"UI/Performance Label".visible = SettingsManager.get_setting("show_performance")
	if SettingsManager.get_setting("show_performance"):
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
	
	elif Input.is_action_just_pressed("ui_plus"):
		AudioServer.set_bus_mute(0, false)
		var master_volume = SettingsManager.get_setting("master_volume")
		SettingsManager.set_setting("master_volume", clamp(master_volume + 0.1, 0, 1))
		SettingsManager.save_settings()
		show_volume()
		$"UI/Voume Node/Hide Timer".start(1.5)
	
	elif Input.is_action_just_pressed("ui_minus"):
		AudioServer.set_bus_mute(0, false)
		var master_volume = SettingsManager.get_setting("master_volume")
		SettingsManager.set_setting("master_volume", clamp(master_volume - 0.1, 0, 1))
		SettingsManager.save_settings()
		show_volume()
		$"UI/Voume Node/Hide Timer".start(1.5)
	
	elif Input.is_action_just_pressed("mute"):
		AudioServer.set_bus_mute(0, !AudioServer.is_bus_mute(0))
		show_volume()
		$"UI/Voume Node/Hide Timer".start(1)
	
	elif Input.is_action_just_pressed("reload"): 
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
	
	var master_volume = SettingsManager.get_setting("master_volume")
	
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
