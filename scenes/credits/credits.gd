extends Node2D

const MENU_OPTION_NODE = preload("res://scenes/menu_option.tscn")
@export var can_click: bool = true

# To add a new credit, add an array with this format:
# [<credit name> , <credit icon (recommended size: 150x150)>]
@onready var options: Dictionary = {
	
	"Nexus Engine": [
		["Noah", load("res://assets/sprites/menus/credits/icons/noah.png")],
		["data5", load("res://assets/sprites/menus/credits/icons/data5.png")],
		["Koi", load("res://assets/sprites/menus/credits/icons/icon-koi.png")],
		["KostyaGame", load("res://assets/sprites/menus/credits/icons/empty.png")]
	],
	
	"Friday Night Funkin\'": [
		["The Funkin\' Crew", load("res://assets/sprites/menus/credits/icons/funkin crew.png")],
	]
	
}

# To set the statistics of a credit node follow this format:
# <credit name>: [<description>, <action name>, <action paramater>]

# Actions:
# link - Parameters: String = <link>
@onready var option_stats: Dictionary = {
	"Noah": ["Made the engine.", "link", "https://www.youtube.com/channel/UCH5BbTqMfiO-Cxhtx3drsqA"],
	"Koi": ["Miss sprite", "link", "https://twitter.com/toasted_milk_"],
	"The Funkin\' Crew": ["Friday Night Funkin\' Game", "link", "https://www.newgrounds.com/portal/view/770371"],
	"KostyaGame": ["Dad losing icon", null],
	"data5": ["Helped with stuff.", "link", "https://x.com/_data5?s=20"]
}

var option_nodes = []
var credit_indexes: Array[int] = []
var selected: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.set_window_title("Credits Menu")
	var object_amount: int = 0
	
	for i in options:
		var menu_option_instance = MENU_OPTION_NODE.instantiate()
		
		menu_option_instance.option_name = i
		menu_option_instance.position = Vector2(-1000, object_amount * 175)
		menu_option_instance.modulate = Color(1, 1, 1, 1)
		menu_option_instance.get_node("Label").label_settings.font = preload("res://assets/fonts/bold_italic_font.ttf")
		menu_option_instance.get_node("Label").label_settings.font_size = 56
		
		$UI.add_child(menu_option_instance)
		
		option_nodes.append(menu_option_instance)
		object_amount += 1
		
		for j in options.get(i):
			menu_option_instance = MENU_OPTION_NODE.instantiate()
			
			menu_option_instance.option_name = j[0]
			if j[1] != null: menu_option_instance.icon = j[1]
			menu_option_instance.position = Vector2(-1000, object_amount * 175)
			menu_option_instance.get_node("Label").label_settings.font_size = 36
			menu_option_instance.get_node("Label").uppercase = false
			menu_option_instance.modulate = Color(0.5, 0.5, 0.5, 0.5)
			
			$UI.add_child(menu_option_instance)
			
			option_nodes.append(menu_option_instance)
			credit_indexes.append(object_amount)
			object_amount += 1
	
	update(0)
	
	if not SoundManager.music.playing:
		SoundManager.music.play()
	
	$Conductor.stream_player = SoundManager.music
	
	await $Conductor.ready
	
	$Conductor.tempo = SoundManager.music.stream._get_bpm()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


# Input Manager
func _input(event):
	
	if can_click:
		
		if event.is_action_pressed("ui_up"):
			update(selected - 1)
		
		if event.is_action_pressed("ui_down"):
			update(selected + 1)
		
		if event.is_action_pressed("ui_accept"):
			select(selected)
		
		if event.is_action_pressed("ui_cancel"):
			can_click = false
			SoundManager.cancel.play()
			Global.change_scene_to("res://scenes/main menu/main_menu.tscn")


# Updates visually what happens when a new index is set for a selection
func update(i: int):
	selected = wrapi(i, 0, option_nodes.size())
	i = selected
	var index = -selected
	SoundManager.scroll.play()
	
	var tween = create_tween()
	tween.set_parallel(true)
	for j in option_nodes:
		tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		var node_position = Vector2(-565 + (25 * index), index * 175)
		tween.tween_property(j, "position", node_position, 0.5)
		if credit_indexes.has(option_nodes.find(j)):
			j.modulate = Color(0.5, 0.5, 0.5)
		
		index += 1
	
	if option_stats.has(option_nodes[i].option_name):
		var stats = option_stats.get(option_nodes[i].option_name)
		$Background/ColorRect/Label.text = stats[0]
	else:
		$Background/ColorRect/Label.text = option_nodes[i].option_name
	
	option_nodes[i].modulate = Color(1, 1, 1)


# Called when an option was selected
func select(i: int):
	if option_stats.has(option_nodes[i].option_name):
		var stats = option_stats.get(option_nodes[i].option_name)
		if stats[1] != null:
			if stats[1] == "link":
				OS.shell_open(stats[2])


func _on_conductor_new_beat(current_beat, measure_relative):
	if SettingsManager.get_value("preferences", "ui_bops"):
		Global.bop_tween($Camera2D, "zoom", Vector2(1, 1), Vector2(1.005, 1.005), 0.2, Tween.TRANS_CUBIC)
		Global.bop_tween($Background/Background, "scale", Vector2(1, 1), Vector2(1.005, 1.005), 0.2, Tween.TRANS_CUBIC)
