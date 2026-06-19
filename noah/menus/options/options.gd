extends Node2D
class_name OptionsMenu

var OPTIONS_SUBMENU_PRELOAD = load("uid://c7jk6j1osvapw")
var MENU_OPTION_PRELOAD = load("uid://dp453vkw4s2xg")

var can_click = true
var pages: Dictionary = {
	SettingsManager.SEC_KEY_BINDS: {
		"name": "Keybinds",
		"options": [
			[&"label", "Gameplay"],
			[&"option", {"id": "note_left"}],
			[&"option", {"id": "note_down"}],
			[&"option", {"id": "note_up"}],
			[&"option", {"id": "note_right"}],
			[&"option", {"id": "kill"}],
			[&"label", "Volume"],
			[&"option", {"id": "volume_up"}],
			[&"option", {"id": "volume_down"}],
			[&"option", {"id": "mute"}],
			[&"label", "UI"],
			[&"option", {"id": "menu_left"}],
			[&"option", {"id": "menu_down"}],
			[&"option", {"id": "menu_up"}],
			[&"option", {"id": "menu_right"}],
			[&"option", {"id": "menu_accept"}],
			[&"option", {"id": "menu_cancel"}],
			[&"label", "Miscellaneous"],
			[&"option", {"id": "character_select"}]
		]
	},
	SettingsManager.SEC_GAMEPLAY: {
		"name": "Gameplay",
		"options": [
			[&"option", {"id": "offset",
			"description": "Visual note offset.",
			"min": -500,
			"max": 500,
			"snap": 1,
			"unit": "ms",
			"scale": 0.001
			}],
			[&"button", {"text": "Offset Calibrator", "id": &"offset"}],
			[&"option", {"id": "ghost_tapping", "description": "Disables the health and score penalty when pressing a key when there's no active notes."}],
			[&"option", {"id": "downscroll", "description": "Makes the notes go downwards rather than upwards."}],
			[&"option", {"id": "botplay", "description": "Automatically hits perfect notes."}],
			[&"option", {"id": "song_speed",
			"description": "Adjusts the speed of the song.\nWARNING: Some events do not work properly with different song speeds.",
			"min": 0.5,
			"max": 2,
			"snap": 0.05,
			"unit": "x"
			}],
			[&"option", {"id": "scroll_speed_scale",
			"description": "Adjusts the scroll speed of the notes.",
			"min": 0.5,
			"max": 2,
			"snap": 0.05,
			"unit": "x"
			}]
		]
	},
	SettingsManager.SEC_PREFERENCES: {
		"name": "Preferences",
		"options": [
			[&"option", {"id": "combo_ui", "description": "Displays the rating and combo on the UI layer rather than the world layer."}],
			[&"option", {"id": "glow_notes", "description": "Makes the notes brighter when active."}],
			[&"option", {"id": "note_splashes", "description": "Makes the notes brighter when active."}],
			[&"option", {"id": "ui_bops", "description": "Makes the UI layer bop in menus and gameplay."}],
			[&"option", {"id": "hit_sounds", "description": "Plays a sound upon hitting a note."}],
			[&"option", {"id": "underlay_opacity",
			"description": "Adds a black underlay to the UI with the given opacity.",
			"min": 0,
			"max": 100,
			"snap": 10,
			"unit": "%",
			"scale": 0.01
			}]
		]
	},
	SettingsManager.SEC_AUDIO: {
		"name": "Audio",
		"options": [
			[&"option", {"id": "master_volume",
			"min": 0,
			"max": 100,
			"snap": 5,
			"unit": "%",
			"scale": 0.01}],
			[&"option", {"id": "sfx_volume",
			"min": 0,
			"max": 100,
			"snap": 5,
			"unit": "%",
			"scale": 0.01}],
			[&"option", {"id": "music_volume",
			"min": 0,
			"max": 100,
			"snap": 5,
			"unit": "%",
			"scale": 0.01}],
		]
	},
	SettingsManager.SEC_DEBUG: {
		"name": "Debug",
		"options": [
			[&"option", {"id": "show_performance"}],
			[&"option", {"id": "cap_fps"}],
			[&"option", {"id": "fps_cap",
			"min": 30,
			"max": 3000,
			"snap": 1,
			"unit": "FPS"}],
			[&"button", {"text": "Clear Save", "id": &"clear_save"}]
		]
	}
}
var selected: int = 0

# Called when the node enters the scene tree for the first time.
func vanilla_686257459__ready():
	Global.set_window_title("Options Menu")
	
	for i in pages.size():
		var page = pages.keys()[i]
		var menu_option_instance = MENU_OPTION_PRELOAD.instantiate()
		
		menu_option_instance.text = page.capitalize()
		menu_option_instance.icon = null
		
		$UI.add_child(menu_option_instance)
		menu_option_instance.add_to_group(&"pages")
	
	update(selected)
	
	if not SoundManager.music.playing:
		SoundManager.music.play()
	
	$Conductor.stream_player = SoundManager.music
	
	await $Conductor.ready
	
	$Conductor.tempo = SoundManager.music.stream.get_bpm()
	print(SoundManager.music.stream.get_bpm())


func vanilla_686257459__process(delta: float) -> void:
	if can_click:
		if Input.is_action_just_pressed(&"menu_cancel"):
			can_click = false
			SoundManager.cancel.play()
			
			if GameManager.song_scene != null:
				SoundManager.music.stop()
				Global.change_scene_to(GameManager.song_scene)
			else:
				Global.change_scene_to(Constants.MAIN_MENU_SCENE)
		
		if Input.is_action_just_pressed(&"menu_up"):
			update(selected - 1)
		
		if Input.is_action_just_pressed(&"menu_down"):
			update(selected + 1)
		
		if Input.is_action_just_pressed(&"menu_accept"):
			select(selected)


func vanilla_686257459__exit_tree() -> void:
	SettingsManager.load_keybinds()


func vanilla_686257459_update(i: int):
	selected = wrapi(i, 0, pages.size())
	var nodes = get_tree().get_nodes_in_group(&"pages")
	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	for j in pages.size():
		var node = nodes[j]
		tween.tween_property(node, "position", Vector2(45 + 25 * (j - selected), 360 + 175 * (j - selected)), 0.5)
		node.modulate = Color(0.5, 0.5, 0.5)
	
	nodes[selected].modulate = Color.WHITE
	SoundManager.scroll.play()


func vanilla_686257459_select(i: int):
	SoundManager.accept.play()
	var page = pages.keys()[i]
	var option_menu_instance = OPTIONS_SUBMENU_PRELOAD.instantiate()
	add_child(option_menu_instance)
	Global.manual_pause = true
	get_tree().paused = true
	option_menu_instance.load_category(page, pages.get(page).get("options", [[&"label", "This page is empty."]]))


func vanilla_686257459__on_conductor_new_beat(current_beat, measure_relative):
	if SettingsManager.get_value(SettingsManager.SEC_PREFERENCES, "ui_bops"):
		Global.bop_tween($Background/Background, "scale", Vector2(1, 1), Vector2(1.005, 1.005), 0.2, Tween.TRANS_CUBIC)


# ModLoader Hooks - The following code has been automatically added by the Godot Mod Loader.


func _ready():
	if _ModLoaderHooks.any_mod_hooked:
		return await _ModLoaderHooks.call_hooks_async(vanilla_686257459__ready, [], 2477218023)
	else:
		return await vanilla_686257459__ready()


func _process(delta: float):
	if _ModLoaderHooks.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_686257459__process, [delta], 2688305713)
	else:
		vanilla_686257459__process(delta)


func _exit_tree():
	if _ModLoaderHooks.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_686257459__exit_tree, [], 2181563739)
	else:
		vanilla_686257459__exit_tree()


func update(i: int):
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_686257459_update, [i], 3335789398)
	else:
		return vanilla_686257459_update(i)


func select(i: int):
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_686257459_select, [i], 3244764787)
	else:
		return vanilla_686257459_select(i)


func _on_conductor_new_beat(current_beat, measure_relative):
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_686257459__on_conductor_new_beat, [current_beat, measure_relative], 1822013987)
	else:
		return vanilla_686257459__on_conductor_new_beat(current_beat, measure_relative)
