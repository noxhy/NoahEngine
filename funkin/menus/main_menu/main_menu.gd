extends Node2D
class_name MainMenu

@export var can_press: bool = true

## Nested dictionaries where each key is an option.
## Each key requires two keys: "node" and "scene".
## Adding a key, "stop_music", will mute the SoundManager's music player.
@onready var options: Dictionary = {
	"story_mode": {
		"node": $"Button Manager/Story Mode",
		"scene": Constants.STORY_MODE_MENU_SCENE
	},
	"freeplay": {
		"node": $"Button Manager/Freeplay",
		"scene": Constants.FREEPLAY_MENU_SCENE,
		"stop_music": true,
	},
	"credits": {
		"node": $"Button Manager/Credits",
		"scene": Constants.CREDITS_MENU_SCENE
	},
	"options": {
		"node": $"Button Manager/Options",
		"scene": Constants.OPTIONS_MENU_SCENE
	}
	
}
static var selected: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.set_window_title("Main Menu")
	GameManager.song_scene = null
	
	# Button Positions
	
	var i = 0
	var button_count = options.size()
	for button in get_tree().get_nodes_in_group("buttons"):
		button.position.y = (720.0 / button_count) * (i - (button_count / 2.0) + 0.5)
		button.play(button.animation)
		i += 1
	
	# Initalization
	update(selected)
	
	if not SoundManager.music.playing:
		SoundManager.music.play()
	
	$Conductor.stream_player = SoundManager.music
	
	await $Conductor.ready
	
	$Conductor.tempo = SoundManager.music.stream._get_bpm()


# Input Manager
func _input(event):
	if can_press:
		if event.is_action_pressed("menu_up"):
			update(selected - 1)
		elif event.is_action_pressed("menu_down"):
			update(selected + 1)
		elif event.is_action_pressed("menu_accept"):
			select(selected)
		elif event.is_action_pressed("menu_cancel"):
			can_press = false
			SoundManager.cancel.play()
			Global.change_scene_to("uid://b1kmgjxpce1de")
			
		elif event.is_action_pressed(&"chart_editor"):
			can_press = false
			SoundManager.music.stop()
			Global.change_scene_to(Constants.CHART_EDITOR_SCENE)


# Updates visually what happens when a new index is set for a selection
func update(i: int):
	var old_node = (options.get(options.keys()[selected])).node
	old_node.play_animation("idle")
	
	var old_node_tween = create_tween()
	old_node_tween.tween_property(old_node, "scale", old_node.scale - Vector2(0.05, 0.05), 0.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	selected = wrapi(i, 0, options.keys().size())
	SoundManager.scroll.play()
	
	var new_node = (options.get(options.keys()[selected])).node
	new_node.play_animation("selected")
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property($Camera2D, "position", new_node.position, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(new_node, "scale", new_node.scale + Vector2(0.05, 0.05), 0.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


# Called when an option was selected
func select(i: int):
	var node = (options.get(options.keys()[i])).node
	SoundManager.accept.play()
	%Background.play("selected")
	
	can_press = false
	
	var camera_tween = create_tween()
	camera_tween.tween_property($Camera2D, "zoom", Vector2(1.1, 1.1), 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	for n in options.keys():
		var temp_node = options.get(n).node
		if n != options.keys()[i]:
			
			var node_tween = create_tween()
			node_tween.tween_property(temp_node, "scale", Vector2(0, 0), 0.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	
	var stop_music = (options.get(options.keys()[i])).get("stop_music", false)
	
	if stop_music:
		SoundManager.music.stop()
	
	var scene = (options.get(options.keys()[i])).scene
	Global.change_scene_to(scene, "fade")


func _on_conductor_new_beat(current_beat, measure_relative):
	if can_press:
		if SettingsManager.get_value(SettingsManager.SEC_PREFERENCES, "ui_bops"):
			Global.bop_tween($Camera2D, "zoom", Vector2(1, 1), Vector2(1.005, 1.005), 0.2, Tween.TRANS_CUBIC)
			Global.bop_tween(%Background, "scale", Vector2(1.1, 1.1), Vector2(1.105, 1.105), 0.2, Tween.TRANS_CUBIC)
