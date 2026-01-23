extends Node2D

const OPTION_MENU_PRELOAD = preload("res://scenes/options/options_menu.tscn")
const MENU_OPTION_PRELOAD = preload("res://scenes/menu_option.tscn")

@export var can_click = true

var pages: Dictionary = {
	SettingsManager.SEC_KEY_BINDS: {
		"name": "Keybinds",
		"options": [
			[&"label", "Gameplay".to_upper()],
			[&"option", {"id": "note_left"}],
			[&"option", {"id": "note_down"}],
			[&"option", {"id": "note_up"}],
			[&"option", {"id": "note_right"}],
			[&"option", {"id": "kill"}],
			[&"label", "Volume".to_upper()],
			[&"option", {"id": "ui_plus"}],
			[&"option", {"id": "ui_minus"}],
			[&"option", {"id": "mute"}],
			[&"label", "UI".to_upper()],
			[&"option", {"id": "ui_left"}],
			[&"option", {"id": "ui_down"}],
			[&"option", {"id": "ui_up"}],
			[&"option", {"id": "ui_right"}],
			[&"option", {"id": "ui_accept"}],
			[&"option", {"id": "ui_cancel"}],
			[&"label", "Miscellaneous".to_upper()],
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
			[&"button", {"text": "Offset Calibrator".to_upper(), "id": &"offset"}],
			[&"option", {"id": "ghost_tapping", "description": "Disables the health and score penalty on hitting a key when there's no active notes."}],
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
			[&"option", {"id": "hit_sounds", "description": "Plays a sound upon hitting a note."}]
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
			"unit": "FPS"}]
		]
	}
}
var selected: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.set_window_title("Options Menu")
	$Foreground/Options.play("options white")
	
	for i in pages.size():
		var page = pages.keys()[i]
		var menu_option_instance = MENU_OPTION_PRELOAD.instantiate()
		
		menu_option_instance.option_name = page
		menu_option_instance.icon = null
		
		$UI/SubViewportContainer/SubViewport.add_child(menu_option_instance)
		menu_option_instance.add_to_group(&"pages")
	update(selected)
	
	if not SoundManager.music.playing:
		SoundManager.music.play()
	
	$Conductor.stream_player = SoundManager.music
	
	await $Conductor.ready
	
	$Conductor.tempo = SoundManager.music.stream._get_bpm()

func _process(delta: float) -> void:
	if can_click:
		if Input.is_action_just_pressed(&"ui_cancel"):
			can_click = false
			SoundManager.cancel.play()
			
			if GameManager.song_scene != null:
				SoundManager.music.stop()
				Global.change_scene_to(GameManager.song_scene)
			else:
				Global.change_scene_to("res://scenes/main_menu/main_menu.tscn")
		
		if Input.is_action_just_pressed(&"ui_up"):
			update(selected - 1)
		
		if Input.is_action_just_pressed(&"ui_down"):
			update(selected + 1)
		
		if Input.is_action_just_pressed(&"ui_accept"):
			select(selected)

func _exit_tree() -> void:
	SettingsManager.load_keybinds()

func update(i: int):
	selected = wrapi(i, 0, pages.size())
	var nodes = get_tree().get_nodes_in_group(&"pages")
	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	for j in pages.size():
		var node = nodes[j]
		tween.tween_property(node, "position", Vector2(45 + 25 * (j - selected), 232 + 175 * (j - selected)), 0.5)
		node.modulate = Color(0.5, 0.5, 0.5)
	
	nodes[selected].modulate = Color.WHITE
	SoundManager.scroll.play()

func select(i: int):
	SoundManager.accept.play()
	var page = pages.keys()[i]
	var option_menu_instance = OPTION_MENU_PRELOAD.instantiate()
	add_child(option_menu_instance)
	Global.manual_pause = true
	get_tree().paused = true
	option_menu_instance.load_category(page, pages.get(page).get("options", [[&"label", "This page is empty."]]))

func _on_conductor_new_beat(current_beat, measure_relative):
	if SettingsManager.get_value(SettingsManager.SEC_PREFERENCES, "ui_bops"):
		Global.bop_tween($Background/Background, "scale", Vector2(1, 1), Vector2(1.005, 1.005), 0.2, Tween.TRANS_CUBIC)
