extends Node2D

@onready var camera_positions = [%"Position 1", %"Position 2", %"Position 3"]
@onready var playstate_host: PlayState = $"PlayState Host"

@onready var stage = %Stage
@onready var player = %Player
@onready var enemy = %Enemy

# Called when the node enters the scene tree for the first time.
func _ready():
	assert(playstate_host, "Playstate host not found")
	if player:
		playstate_host.ui.set_player_icons(player.icons)
		playstate_host.ui.set_player_color(player.color)
		DeathScreen.player_position = player.global_position
		DeathScreen.player_scale = player.scale
	
	if enemy:
		playstate_host.ui.set_enemy_icons(enemy.icons)
		playstate_host.ui.set_enemy_color(enemy.color)
	
	await playstate_host.setup_finished
	
	if stage:
		playstate_host.conductor.connect(&"new_beat", stage._on_conductor_new_beat)
	
	playstate_host.conductor.connect(&"new_beat", self._on_conductor_new_beat)
	playstate_host.conductor.connect(&"combo_break", self._on_combo_break)
	playstate_host.conductor.connect(&"create_note", self._on_create_note)
	playstate_host.conductor.connect(&"new_event", self._on_new_event)

# Conductor Util

func _on_conductor_new_beat(current_beat, measure_relative):
	if measure_relative % 2 == 0:
		get_tree().call_group(&"player", &"play_animation", &"idle")
		get_tree().call_group(&"enemy", &"play_animation", &"idle")
		for node in get_tree().get_nodes_in_group(&"metronome"):
			if (node.current_animation == node.idle_animation):
				node.can_idle = true
		
		get_tree().call_group(&"metronome", &"play_animation", &"idle", GameManager.seconds_per_beat * 2)

# Util

func _on_create_note(time, lane, note_length, note_type, tempo):
	if (lane > 3):
		playstate_host.strums[1].create_note(time, lane % 4, note_length, note_type, tempo)
	else:
		playstate_host.strums[0].create_note(time, lane % 4, note_length, note_type, tempo)


func note_hit(time, lane, note_type, hit_time, strum_manager):
	get_tree().call_group(
		&"enemy" if strum_manager.enemy_slot else &"player", &"play_animation",
		get_direction(lane % 4))
	playstate_host.note_hit(time, lane, note_type, hit_time, strum_manager)


func note_holding(time, lane, note_type, strum_manager):
	get_tree().call_group(
		&"enemy" if strum_manager.enemy_slot else &"player", &"play_animation",
		get_direction(lane % 4))
	playstate_host.note_holding(time, lane, note_type, strum_manager)


func note_miss(time, lane, length, note_type, hit_time, strum_manager):
	if !strum_manager.enemy_slot:
		if note_type == -1:
			SoundManager.anti_spam.play()
		else:
			SoundManager.miss.play()
			get_tree().call_group(
			&"enemy" if strum_manager.enemy_slot else &"player", &"metronome",
			&"cry")
	
	get_tree().call_group(
		&"enemy" if strum_manager.enemy_slot else &"player", &"play_animation",
		&"miss_" + get_direction(lane % 4))
	
	playstate_host.note_miss(time, lane, length, note_type, hit_time, strum_manager)

func get_direction(direction: int):
	var animations = ["left", "down", "up", "right"]
	return animations[direction]


func _on_new_event(time, event_name, event_parameters):
	match event_name:
		"play_animation":
			get_node(str("%", event_parameters[0])).play_animation(event_parameters[1], event_parameters[2])


func _on_combo_break():
	pass
