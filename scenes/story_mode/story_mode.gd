extends Node2D
class_name StoryMode

const WEEK_ICON_NODE = preload("res://scenes/story_mode/week_icon.tscn")
@export var can_click: bool = true

## Nested dictionary where each key has keys:
## animation - The animation name of the node that represents the week.
## node - The node that will be visible when hovering over the week.
## scene - The scene that you will be sent to when selecting the week.
## name - The week name that displays
@onready var options: Dictionary = {
	"tutorial": {
		"animation": "tutorial",
		"node": $"UI/Week Display/SubViewport/Tutorial",
		"scene": "res://test/test_scene.tscn",
		"name": "Teaching Time",
		"song_list": [],
		"display_song_list": "Tutorial"
	},
	"week1": {
		"animation": "week1",
		"node": $"UI/Week Display/SubViewport/Week 1",
		"scene": "res://scenes/game/songs/fresh/fresh.tscn",
		"name": "Daddy Dearest",
		"display_song_list": "Bopeeboo\nFresh\nDadbattle",
		"song_list": [load("res://playable_songs/fresh/Fresh Erect.res")]
	},
	"week2": {
		"animation": "week2",
		"node": $"UI/Week Display/SubViewport/Week 2",
		"scene": "res://test/test_scene.tscn",
		"name": "Spooky Month",
		"display_song_list": "Spokeez\nSouth\nMonster",
		"song_list": []
	},
	"week3": {
		"animation": "week3",
		"node": $"UI/Week Display/SubViewport/Week 3",
		"scene": "res://test/test_scene.tscn",
		"name": "Pico",
		"display_song_list": "Pico\nPhilly\nBlammed",
		"song_list": []
	},
	"week4": {
		"animation": "week4",
		"node": $"UI/Week Display/SubViewport/Week 4",
		"scene": "res://test/test_scene.tscn",
		"name": "Mommy Must Murder",
		"display_song_list": "Satin-Panties\nHigh\nMilf",
		"song_list": []
	},
	"week5": {
		"animation": "week5",
		"node": $"UI/Week Display/SubViewport/Week 5",
		"scene": "res://scenes/game/songs/eggnog/eggnog.tscn",
		"name": "Red Snow",
		"display_song_list": "Cocoa\nEggnog\nWinter Horroland",
		"song_list": [load("res://playable_songs/cocoa/Cocoa Erect.res")]
	},
	"week6": {
		"animation": "week6",
		"node": $"UI/Week Display/SubViewport/Week 6",
		"scene": "res://scenes/game/songs/senpai/senpai.tscn",
		"name": "Hating Simulator Ft. Moawling",
		"display_song_list": "Senpai\nRoses\nThorns",
		"song_list": [load("res://playable_songs/senpai/Senpai.res")]
	},
	"week7": {
		"animation": "week7",
		"node": $"UI/Week Display/SubViewport/Week 7",
		"scene": "res://test/test_scene.tscn",
		"name": "Tankman",
		"display_song_list": "Ugh\nGuns\nStress",
		"song_list": []
	},
	"weekend1": {
		"animation": "weekend1",
		"node": $"UI/Week Display/SubViewport/Weekend 1",
		"scene": "res://scenes/game/songs/darnell/darnell.tscn",
		"name": "Due Debts",
		"display_song_list": "Darnell\nLit Up\n2Hot\nBlazin\'",
		"character": "pico",
		"song_list": [load("res://playable_songs/darnell/Darnell.res")]
	},
}

var option_nodes = []
static var selected_week: int = 0
static var selected_difficulty: int = 0
var week_score: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.set_window_title("Story Mode Menu")
	
	# Initalization
	var object_amount: int = 0
	
	for i in options:
		
		var week_icon_instance = WEEK_ICON_NODE.instantiate()
		
		week_icon_instance.position = Vector2(1280 / 2, 1000)
		
		$"UI/Week UI/SubViewport".add_child(week_icon_instance)
		week_icon_instance.play_animation(options.get(options.keys()[object_amount]).animation)
		
		object_amount += 1
		option_nodes.append(week_icon_instance)
	
	update_week(selected_week)
	
	if not SoundManager.music.playing:
		SoundManager.music.play()
	
	$Conductor.stream_player = SoundManager.music
	
	await $Conductor.ready
	
	$Conductor.tempo = SoundManager.music.stream._get_bpm()


# Input Manager
func _input(event):
	if can_click:
		if event.is_action_pressed("ui_up"):
			update_week(selected_week - 1)
		elif event.is_action_pressed("ui_down"):
			update_week(selected_week + 1)
		elif event.is_action_pressed("ui_left"):
			update_difficulty(selected_difficulty - 1)
		elif event.is_action_pressed("ui_right"):
			update_difficulty(selected_difficulty + 1)
		elif event.is_action_pressed("ui_accept"):
			select_option(selected_week)
		elif event.is_action_pressed("ui_cancel"):
			can_click = false
			SoundManager.cancel.play()
			Global.change_scene_to("res://scenes/main menu/main_menu.tscn")


# Updates visually what happens when a new index is set for a selection
func update_week(i: int):
	selected_week = wrapi(i, 0, option_nodes.size())
	i = selected_week
	var week: String = options.keys()[i]
	var index = -selected_week
	SoundManager.scroll.play()
	
	var tween = create_tween()
	tween.set_parallel(true)
	for j in option_nodes:
		tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		var node_position = Vector2(1280 / 2, index * 135 + 64)
		tween.tween_property(j, "position", node_position, 0.5)
		j.modulate = Color(0.5, 0.5, 0.5)
		index += 1
	
	get_tree().call_group(&"weeks", "set_visible", false)
	var node = options.get(week).get("node")
	update_difficulty(selected_difficulty)
	node.visible = true
	Global.bop_tween(node, "scale", node.scale, node.scale * Vector2(1.05, 1.05), 0.2, Tween.TRANS_SINE)
	
	$"UI/Week UI/SubViewport/Song List Label".text = options.get(week).display_song_list
	$"UI/Week Name".text = options.get(week).name
	option_nodes[i].modulate = Color(1, 1, 1)


func update_difficulty(i: int, week: String = options.keys()[selected_week]):
	if !validate_week(week):
		return
	var difficulties = options.get(week).song_list[0].difficulties.keys()
	
	selected_difficulty = wrapi(i, 0, difficulties.size())
	i = selected_difficulty
	GameManager.difficulty = difficulties[selected_difficulty]
	
	%"Difficulty Display".play_animation(difficulties[i])
	
	var tween = create_tween()
	%"Difficulty Display".scale = Vector2(1.1, 1.1)
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT).set_parallel()
	tween.tween_property(%"Difficulty Display", "scale", Vector2(1, 1), 0.2)
	
	var display_name = options.get(options.keys()[selected_week]).get("name", "")
	var _week_score = SaveManager.get_week_highscore(display_name, difficulties[i])
	if _week_score == -1:
		update_week_score(-1)
	else:
		tween.tween_method(self.update_week_score, week_score, _week_score, 0.3).set_trans(Tween.TRANS_QUART)
	
	SoundManager.scroll.play()


# Called when an option was selected_week
func select_option(i: int):
	if can_click:
		var week = options.keys()[i]
		if !validate_week(week):
			SoundManager.cancel.play()
			return
		
		can_click = false
		SoundManager.accept.play()
		GameManager.current_week = options.get(week).name
		GameManager.week_songs = options.get(week).song_list
		GameManager.current_week_song = 0
		GameManager.current_character = options.get(options.keys()[i]).get("character", "boyfriend")
		var scene = options.get(options.keys()[i]).scene
		GameManager.play_mode = GameManager.PLAY_MODE.STORY_MODE
		GameManager.freeplay = false
		SoundManager.music.stop()
		get_tree().call_group("player", "play_animation", "cheer")
		
		await get_tree().create_timer(0.5).timeout
		
		Global.change_scene_to(scene)


func _on_conductor_new_beat(current_beat, measure_relative):
	if can_click:
		if SettingsManager.get_value(SettingsManager.SEC_PREFERENCES, "ui_bops"):
			Global.bop_tween($Camera2D, "zoom", Vector2(1, 1), Vector2(1.005, 1.005), 0.2, Tween.TRANS_CUBIC)
		if (current_beat % 2):
			get_tree().call_group("bop", "play_animation", "idle")
			for node in get_tree().get_nodes_in_group("smooth_bop"):
				if node.current_animation == "idle":
					node.can_idle = true
			get_tree().call_group("smooth_bop", "play_animation", "idle", $Conductor.seconds_per_beat * 2)

func update_week_score(score: int):
	if score > -1:
		$"UI/Week Score".text = str("Level Score: ", score)
	else:
		$"UI/Week Score".text = str("Play the level to earn a score")
	week_score = score


## Checks if every song in a week has all the same difficulties
func validate_week(id: StringName) -> bool:
	var song_list = options.get(id).song_list
	if song_list.size() == 0:
		printerr("(Week Validation) Empty song list")
		return false
	elif song_list.size() == 1:
		return true
	else:
		var difficulties = song_list[0].difficulties.keys()
		for i in range(1, song_list.size()):
			if song_list[i].get("difficulties").keys() != difficulties:
				printerr("(Week Validation) Unequal difficulties between songs")
				return false
			continue
	return true
