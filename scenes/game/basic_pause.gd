extends Node2D

const MENU_OPTION_PRELOAD = preload("res://scenes/menu_option.tscn")

@onready var music = $Audio/Music

@export var song_title: String = ""
@export var credits: String = ""
@export var deaths: int = 0
## Nested dictionary where each key has keys: [code]name[/code] and [code]icon[/code].[br]
## [br][code]name[/code] - The display name of the option.
## [br][code]icon[/code] - The texture that will display next to the display name.
@export var pages: Dictionary = {
	"default": {
		"resume": {
			"name": "Resume"
		},
		
		"options": {
			"name": "Options"
		},
		
		"restart": {
			"name": "Restart"
		},
		
		"change_difficulty": {
			"name": "Change Difficulty"
		},
		
		"exit": {
			"name": "Exit"
		},
	},
	
	"charting": {
		"resume": {
			"name": "Resume"
		},
		
		"options": {
			"name": "Options"
		},
		
		"restart": {
			"name": "Restart"
		},
		
		"chart_editor": {
			"name": "Go to Chart Editor"
		}
	},
	
	"difficulties": {
		"back": {
			"name": "Back"
		}
	}
}

var options: Dictionary = {}

var option_nodes = []
var selected: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	var tween = create_tween()
	music.volume_linear = 0
	tween.tween_property(music, "volume_linear", 1, 4)
	$AnimationPlayer.play("intro")
	
	%"Song Name".text = song_title
	%"Other Info".text = "Artist: " + credits
	%"Other Info".text += "\n" + str(deaths) + " Blue Balls"
	
	var mode_display: String = ""
	match GameManager.play_mode:
		GameManager.PLAY_MODE.STORY_MODE: mode_display = "Story Mode"
		GameManager.PLAY_MODE.FREEPLAY: mode_display = "Freeplay"
		GameManager.PLAY_MODE.PRACTICE: mode_display = "Practicing"
		GameManager.PLAY_MODE.CHARTING: mode_display = "Charting"
	
	%"Other Info".text += "\n" + mode_display
	
	match GameManager.play_mode:
		GameManager.PLAY_MODE.CHARTING:
			load_page("charting")
		_:
			load_page("default")
	
	update(selected)
	for difficulty in GameManager.current_song.difficulties:
		pages.difficulties[difficulty] = {"name": difficulty}


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_up"):
		update(selected - 1)
	if Input.is_action_just_pressed("ui_down"):
		update(selected + 1)
	if Input.is_action_just_pressed("ui_cancel") or Input.is_action_just_pressed("ui_accept"):
		select_option(selected)


func load_page(page: String):
	option_nodes = []
	get_tree().call_group(&"options", &"queue_free")
	options = pages.get(page)
	
	var index: int = 0
	for i in options.keys():
		var menu_option_instance = MENU_OPTION_PRELOAD.instantiate()
		
		menu_option_instance.position.x = -640 + 45 + (25 * index) - 1000
		menu_option_instance.position.y = index * 175
		menu_option_instance.option_name = options.get(i).get("name")
		menu_option_instance.icon = options.get(i).get("icon")
		
		$UI.add_child(menu_option_instance)
		option_nodes.append(menu_option_instance)
		menu_option_instance.add_to_group(&"options")
		
		index += 1


func update(i: int):
	selected = wrapi(i, 0, options.keys().size())
	i = selected
	var index = -selected
	SoundManager.scroll.play()
	
	var tween = create_tween()
	tween.set_parallel(true)
	for j in option_nodes:
		tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		var node_position = Vector2(-640 + 45 + (25 * index), index * 175) 
		tween.tween_property(j, "position", node_position, 0.5)
		j.modulate = Color(0.5, 0.5, 0.5)
		index += 1
	
	option_nodes[i].modulate = Color(1, 1, 1)


func select_option(i: int):
	var option = options.keys()[i]
	match option:
		"resume":
			get_tree().paused = false
			queue_free()
		
		"options":
			Global.change_scene_to("res://scenes/options/options.tscn", "down")
		
		"restart":
			get_tree().paused = false
			get_tree().reload_current_scene()
		
		"exit":
			GameManager.reset_stats()
			
			if GameManager.freeplay:
				Global.change_scene_to("res://scenes/freeplay/freeplay.tscn", "down")
			else:
				Global.change_scene_to("res://scenes/story mode/story_mode.tscn", "down")
		
		"chart_editor":
			GameManager.reset_stats()
			Global.change_scene_to("res://scenes/chart editor/chart_editor.tscn", "down")
		
		"change_difficulty":
			load_page("difficulties")
			update(0)
		
		"back":
			load_page("default")
			update(0)
		
		# Difficulties
		
		"easy":
			change_difficulty("easy")
		
		"normal":
			change_difficulty("normal")
		
		"hard":
			change_difficulty("hard")
		
		"erect":
			change_difficulty("erect")
		
		"nightmare":
			change_difficulty("nightmare")


func change_difficulty(difficulty: String):
	GameManager.difficulty = difficulty
	GameManager.deaths = 0
	get_tree().paused = false
	get_tree().reload_current_scene()
