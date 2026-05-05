extends Node

@onready var camera_positions = []
@onready var playstate_host: PlayState = $"PlayState Host"

@onready var stage = %Stage
@onready var player = %Player
@onready var enemy = %Enemy

@onready var rating_marker = $"World/Rating Marker"
@onready var combo_marker = $"World/Combo Marker"

@onready var rating_node = load("res://scenes/game/rating.tscn")
@onready var combo_numbers_manager_node = load("res://scenes/game/combo_numbers_manager.tscn")

# How often the camera bops. Based off the step rate in the conductor.
var bop_rate: int = 16

# Called when the node enters the scene tree for the first time.
func _ready():
	assert(playstate_host, "Playstate host not found")
	camera_positions = get_tree().get_nodes_in_group(&"camera_positions")
	if player:
		playstate_host.ui.set_player_icons(player.icons)
		playstate_host.ui.set_player_color(player.color)
		DeathScreen.player_position = player.global_position
		DeathScreen.player_scale = Vector2(player.scale.x,player.scale.y)
	
	if enemy:
		playstate_host.ui.set_enemy_icons(enemy.icons)
		playstate_host.ui.set_enemy_color(enemy.color)
	
	await playstate_host.setup_finished
	
	if not SettingsManager.get_value(SettingsManager.SEC_GAMEPLAY, 'botplay'):
		get_tree().set_group(&"player", &"is_player", true)
	
	
	get_tree().set_group(&"player", &"in_playstate", true)
	get_tree().set_group(&"enemy", &"in_playstate", true)
	get_tree().set_group(&"metronome", &"in_playstate", true)
	
	
	
	if stage:
		playstate_host.conductor.connect(&"new_beat", stage._on_conductor_new_beat)
	
	playstate_host.conductor.connect(&"new_beat", self._on_conductor_new_beat)
	playstate_host.conductor.connect(&"new_step", self._on_conductor_new_step)
	
	playstate_host.connect(&"combo_break", self._on_combo_break)
	playstate_host.connect(&"create_note", self._on_create_note)
	playstate_host.connect(&"new_event", self._on_new_event)
	
	for char in get_tree().get_nodes_in_group(&"player"):
		playstate_host.conductor.connect(&"new_beat", char.on_beat_hit)
		
	for char in get_tree().get_nodes_in_group(&"enemy"):
		playstate_host.conductor.connect(&"new_beat", char.on_beat_hit)
		
	for char in get_tree().get_nodes_in_group(&"metronome"):
		playstate_host.conductor.connect(&"new_beat", char.on_beat_hit)

# Conductor Util
func _on_conductor_new_beat(current_beat, measure_relative):
	#if measure_relative % 2 == 0:
		#for player in get_tree().get_nodes_in_group(&"player"):
			#if not player.is_singing():
				#player.dance()
		#for player in get_tree().get_nodes_in_group(&"enemy"):
			#if not player.is_singing():
				#player.dance()
		#
#
	#get_tree().call_group(&"metronome", &"dance")
	
	playstate_host.ui.icon_bop(playstate_host.conductor.seconds_per_beat * 0.5 *
	(1 / playstate_host.instrumental.pitch_scale))


func _on_conductor_new_step(current_step, measure_relative):
	if current_step % bop_rate == 0:
		var strength = playstate_host.camera_bop_strength if playstate_host.camera.get_direct() is Camera2D else playstate_host.camera_bop_strength.x
		playstate_host.camera.zoom += strength * playstate_host.camera.zoom
		
		if SettingsManager.get_value(SettingsManager.SEC_PREFERENCES, "ui_bops"):
			playstate_host.ui.scale += playstate_host.ui_bop_strength


func _on_create_note(time, lane, note_length, note_type, tempo):
	if (lane > 3):
		playstate_host.strums[1].create_note(time, lane % 4, note_length, note_type, tempo)
	else:
		playstate_host.strums[0].create_note(time, lane % 4, note_length, note_type, tempo)


func note_hit(time, lane, note_type, hit_time, strum_manager):
	var group: StringName = get_group(strum_manager)
	get_tree().call_group(group, &"play_animation", get_direction(lane % 4))
	
	playstate_host.note_hit(time, lane, note_type, hit_time, strum_manager)
	
	if group == &"player":
		show_combo(PlayState.get_rating(hit_time), playstate_host.combo)


func note_holding(time, lane, length, note_type, strum_manager):
	var group: StringName = get_group(strum_manager)
	
	get_tree().set_group(group, &"holding", true)
	get_tree().set_group(group, &"sing_timer", 0)
	
	if length <= 0:
		get_tree().set_group(group, &"holding", false)
	
	playstate_host.note_holding(time, lane, length, note_type, strum_manager)


func note_miss(time, lane, length, note_type, hit_time, strum_manager):
	if !strum_manager.enemy_slot:
		if note_type == -1:
			SoundManager.anti_spam.play()
		else:
			SoundManager.miss.play()
			get_tree().call_group(
			&"enemy" if strum_manager.enemy_slot else &"player", &"metronome",
			&"cry")
			show_combo("miss", 0)
	
	get_tree().call_group(
		&"enemy" if strum_manager.enemy_slot else &"player", &"play_animation",
		&"miss_" + get_direction(lane % 4))
	
	playstate_host.note_miss(time, lane, length, note_type, hit_time, strum_manager)


func get_group(strum_manager) -> StringName:
	return &"enemy" if strum_manager.enemy_slot else &"player"


func get_direction(direction: int):
	var animations = ["left", "down", "up", "right"]
	return animations[direction]


func _on_new_event(time, event_name, event_parameters):
	match event_name:
		"play_animation":
			get_tree().call_group(event_parameters[0], &"play_animation",
			event_parameters[1], event_parameters[2])


func _on_combo_break():
	pass


func show_combo(rating: String, _combo: int):
	var rating_instance = rating_node.instantiate()
	
	rating_instance.ui_skin = playstate_host.ui_skin
	rating_instance.rating = rating
	
	var combo_numbers_manager_instance = combo_numbers_manager_node.instantiate()
	
	combo_numbers_manager_instance.ui_skin = playstate_host.ui_skin
	combo_numbers_manager_instance.combo = _combo
	if GameManager.tallies.max_combo == GameManager.tallies.total_notes:
		combo_numbers_manager_instance.fc = true
	
	if SettingsManager.get_value(SettingsManager.SEC_PREFERENCES, "combo_ui"):
		if playstate_host.ui.rating_marker:
			rating_instance.position = playstate_host.ui.rating_marker.position
		
		if playstate_host.ui.combo_marker:
			combo_numbers_manager_instance.position = playstate_host.ui.combo_marker.position
		
		playstate_host.ui.add_child(rating_instance)
		playstate_host.ui.add_child(combo_numbers_manager_instance)
	else:
		if rating_marker:
			rating_instance.position = rating_marker.global_position
			rating_instance.scale *= playstate_host.combo_scale_multiplier
			rating_instance.z_index = 1000
		
		if combo_marker:
			combo_numbers_manager_instance.position = combo_marker.global_position
			combo_numbers_manager_instance.scale *= playstate_host.combo_scale_multiplier
			combo_numbers_manager_instance.z_index = 1000
		
		self.add_child(rating_instance)
		self.add_child(combo_numbers_manager_instance)
