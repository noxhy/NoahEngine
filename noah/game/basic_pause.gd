extends Node2D
class_name BasicPause

@onready var music = $Audio/Music

## Nested dictionary where each key has keys: [code]name[/code] and [code]icon[/code].[br]
## [br][code]name[/code] - The display name of the option.
## [br][code]icon[/code] - The texture that will display next to the display name.
var pages: Dictionary = {
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
var current_credit: int = 0

# Called when the node enters the scene tree for the first time.
func vanilla_2047904093__ready():
	var tween = create_tween()
	music.volume_linear = 0
	tween.tween_property(music, "volume_linear", 1, 4)
	$AnimationPlayer.play("intro")
	
	%"Song Name".text = GameManager.current_song.title
	display_credits()
	current_credit += 1
	%"Other Info".text = str(GameManager.deaths, " Deaths")
	
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
func vanilla_2047904093__process(delta):
	if Input.is_action_just_pressed("menu_up"):
		update(selected - 1)
	if Input.is_action_just_pressed("menu_down"):
		update(selected + 1)
	if Input.is_action_just_pressed("menu_cancel") or Input.is_action_just_pressed("menu_accept"):
		select_option(selected)


func vanilla_2047904093_load_page(page: String):
	option_nodes = []
	get_tree().call_group(&"options", &"queue_free")
	options = pages.get(page)
	
	for i in options.keys():
		var menu_option_instance = load("uid://dp453vkw4s2xg").instantiate()
		
		menu_option_instance.position.x = -640 + 45
		menu_option_instance.position.y = 0
		menu_option_instance.text = options.get(i).get("name").to_upper()
		menu_option_instance.icon = options.get(i).get("icon")
		
		$UI.add_child(menu_option_instance)
		option_nodes.append(menu_option_instance)
		menu_option_instance.add_to_group(&"options")


func vanilla_2047904093_update(i: int):
	selected = wrapi(i, 0, options.keys().size())
	i = selected
	var index = -selected
	SoundManager.scroll.play()
	
	var tween = create_tween()
	tween.set_parallel(true)
	for j in option_nodes:
		tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		var node_position = Vector2(-640 + 45 + (25 * index), index * 175) 
		tween.tween_property(j, "position", node_position, 0.25)
		j.modulate = Color(0.5, 0.5, 0.5)
		index += 1
	
	option_nodes[i].modulate = Color(1, 1, 1)


func vanilla_2047904093_select_option(i: int):
	var option = options.keys()[i]
	match option:
		"resume":
			get_tree().paused = false
			Signals.emit_signal(&"play_unpaused")
			queue_free()
		
		"options":
			self.process_mode = Node.PROCESS_MODE_DISABLED
			Global.change_scene_to(Constants.OPTIONS_MENU_SCENE)
		
		"restart":
			get_tree().paused = false
			get_tree().reload_current_scene()
		
		"exit":
			GameManager.reset_stats()
			self.process_mode = Node.PROCESS_MODE_DISABLED
			
			if GameManager.freeplay:
				Global.change_scene_to(Constants.FREEPLAY_MENU_SCENE)
			else:
				Global.change_scene_to(Constants.STORY_MODE_MENU_SCENE)
		
		"chart_editor":
			GameManager.reset_stats()
			self.process_mode = Node.PROCESS_MODE_DISABLED
			Global.change_scene_to(Constants.CHART_EDITOR_SCENE)
		
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


func vanilla_2047904093_change_difficulty(difficulty: String):
	GameManager.difficulty = difficulty
	GameManager.deaths = 0
	get_tree().paused = false
	get_tree().reload_current_scene()


func vanilla_2047904093__on_timer_timeout() -> void:
	var time: float = 0.5
	
	var tween = create_tween()
	tween.tween_property(%Credits, "modulate", Color.TRANSPARENT, time)
	tween.tween_property(%Credits, "modulate", Color.WHITE, 1).set_delay(time)
	
	await get_tree().create_timer(time).timeout
	
	display_credits()
	current_credit += 1


func vanilla_2047904093_display_credits():
	if current_credit % 2 == 0:
		%Credits.text = str("Artist: ", GameManager.current_song.artist)
	else:
		%Credits.text = str("Charter: ", GameManager.current_song.charter)


# ModLoader Hooks - The following code has been automatically added by the Godot Mod Loader.


func _ready():
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_2047904093__ready, [], 2371708049)
	else:
		return vanilla_2047904093__ready()


func _process(delta):
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_2047904093__process, [delta], 3752061019)
	else:
		return vanilla_2047904093__process(delta)


func load_page(page: String):
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_2047904093_load_page, [page], 2611440793)
	else:
		return vanilla_2047904093_load_page(page)


func update(i: int):
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_2047904093_update, [i], 3230279424)
	else:
		return vanilla_2047904093_update(i)


func select_option(i: int):
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_2047904093_select_option, [i], 3257033397)
	else:
		return vanilla_2047904093_select_option(i)


func change_difficulty(difficulty: String):
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_2047904093_change_difficulty, [difficulty], 668096341)
	else:
		return vanilla_2047904093_change_difficulty(difficulty)


func _on_timer_timeout():
	if _ModLoaderHooks.any_mod_hooked:
		await _ModLoaderHooks.call_hooks_async(vanilla_2047904093__on_timer_timeout, [], 4150799327)
	else:
		await vanilla_2047904093__on_timer_timeout()


func display_credits():
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_2047904093_display_credits, [], 4235694240)
	else:
		return vanilla_2047904093_display_credits()
