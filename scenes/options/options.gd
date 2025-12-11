extends Node2D

const OPTION_MENU_PRELOAD = preload("res://scenes/instances/options/options_menu.tscn")
const MENU_OPTION_PRELOAD = preload("res://scenes/instances/menu_option.tscn")

@export var can_click = true

@onready var pages: Dictionary = {
	SettingsManager.SEC_KEY_BINDS: {
		"name": "Keybinds",
		"options": [
			[&"label", "Gameplay".to_upper()],
			[&"option", "note_left"],
			[&"option", "note_down"],
			[&"option", "note_up"],
			[&"option", "note_right"],
			[&"option", "kill"],
			[&"label", "Volume".to_upper()],
			[&"option", "ui_plus"],
			[&"option", "ui_minus"],
			[&"option", "mute"],
			[&"label", "UI".to_upper()],
			[&"option", "ui_left"],
			[&"option", "ui_down"],
			[&"option", "ui_up"],
			[&"option", "ui_right"],
			[&"option", "ui_accept"],
			[&"option", "ui_cancel"],
			[&"label", "Miscellaneous".to_upper()],
			[&"option", "character_select"]
		]
	},
	SettingsManager.SEC_GAMEPLAY: {
		"name": "Gameplay",
		"options": [
			[&"option", "offset"],
			[&"option", "ghost_tapping"],
			[&"option", "downscroll"],
			[&"option", "botplay"],
			[&"option", "song_speed"],
			[&"option", "scroll_speed_scale"]
		]
	},
	SettingsManager.SEC_PREFERENCES: {
		"name": "Preferences",
		"options": [
			[&"option", "combo_ui"],
			[&"option", "glow_notes"],
			[&"option", "note_splashes"],
			[&"option", "ui_bops"],
			[&"option", "hit_sounds"]
		]
	},
	SettingsManager.SEC_AUDIO: {
		"name": "Audio",
		"options": [
			[&"option", "master_volume"],
			[&"option", "sfx_volume"],
			[&"option", "music_volume"]
		]
	},
	SettingsManager.SEC_DEBUG: {
		"name": "Debug",
		"options": [
			[&"option", "show_performance"],
			[&"option", "cap_fps"],
			[&"option", "fps_cap"]
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
			
			if Global.song_scene != null:
				SoundManager.music.stop()
				Global.change_scene_to(Global.song_scene)
			else:
				Global.change_scene_to("res://scenes/main menu/main_menu.tscn")
		
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
