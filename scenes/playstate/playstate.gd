@icon("res://assets/sprites/nodes/playstate.png")
extends Node
class_name PlayState

const COMPENSATION: float = 1.0 / 30.0
const SCORING_SLOPE: float = 0.08
const SCORING_OFFSET: float = 0.05499
const MIN_SCORE: int = 9
const MAX_SCORE: int = 500
const HOLD_SCORE: float = 250
const HOLD_HEALTH: float = 6

signal create_note(time: float, lane: int, note_length: float, note_type: Variant, tempo: float)
signal new_event(time: float, event_name: String, event_parameters: Array)
signal combo_break()
signal setup_finished()

@onready var rating_node = load("res://scenes/instances/playstate/rating.tscn")
@onready var combo_numbers_manager_node = load("res://scenes/instances/playstate/combo_numbers_manager.tscn")
@onready var countdown_node = load("res://scenes/playstate/countdown.tscn")
@onready var song_data: Song
@onready var vocals: AudioStreamPlayer
@onready var instrumental: AudioStreamPlayer
@onready var conductor: Conductor
@onready var strums: Array = []
@onready var characters: Array = []

@export_group("Nodes")
## The host song script. Usually the parent of this node.
@export var host: Node2D
## The UI node that requires a list: [code]strums[/code].
@export var ui: CanvasLayer
## Camera with built-in functions.
@export var camera: PlayStateCamera

@export_group("Positions")
## Where the "Sick!" or "Good!" sprites will spawn
@export var rating_position: Marker2D
## Where the combo number will spawn, origin is to the left.
@export var combo_position: Marker2D

@export_group("Resources")
@export var note_skin: NoteSkin
@export var ui_skin: UISkin

@export_group("Values")
## Scales the Rating and Combo sprites.
@export_custom(PROPERTY_HINT_LINK, "x") var combo_scale_multiplier = Vector2(1, 1)

@export_group("Scenes")
## What scene the player will be sent to upon death.
@export_file('*.tscn') var death_scene = "res://scenes/playstate/death_screen.tscn"
## What scene will instantiate when pausing,
@export_file('*.tscn') var pause_scene = "res://scenes/playstate/pause_menu.tscn"
## The scene that will be switched to when the song ends.
@export_file('*.tscn') var next_scene = "res://scenes/results/results.tscn"

# How often the damera bops. Based off the step rate in the conductor.
var bop_rate: int = 16

var song_started: bool = false
var song_start_offset: float = -4.0
var song_start_time: float = 0.0
# So it turns out that the track ID's are not sequential and can be whatever number they want, I did this so it'd be easier
var vocal_tracks: Array = []
var vocal_streams: Array = []

var position_delta: float = 0.0
var position_lerp: float = 0.0
var sync_timer: float = 0.0
var song_speed: float = 1.0

# The index of the latest loaded note
var current_note: int = -1
# The index of the latest loaded event
var current_event: int = -1

var chart: Chart

var accuracy: float
var timings_sum: float
var entries: float = 0
var misses: int = 0
var score: int = 0
var health: float = 50.0
var combo: int = 0

var camera_bop_strength = Vector2(0.05, 0.05)
var ui_bop_strength = Vector2(0.025, 0.025)

var pause_preload: Variant
var self_delta: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	if GameManager.freeplay:
		self.song_data = GameManager.current_song
	else:
		self.song_data = GameManager.week_songs[GameManager.current_week_song]
	assert(host, 'A Host was not assigned.')
	assert(ui, 'A UI was not assigned.')
	assert(camera, 'A PlayState Camera was not assigned.')
	# This delay is so variables initialize
	await host.ready
	
	# Creating the Audio Tracks
	vocals = AudioStreamPlayer.new()
	vocals.stream = AudioStreamPolyphonic.new()
	vocals.stream.polyphony = song_data.vocals.size()
	vocals.set_bus(&"Music")
	for v in song_data.vocals:
		vocal_streams.append(load(v))
	instrumental = AudioStreamPlayer.new()
	instrumental.stream = load(song_data.instrumental)
	instrumental.connect("finished", song_finished)
	instrumental.pitch_scale = song_speed
	instrumental.set_bus(&"Music")
	self.add_child(vocals)
	vocals.play()
	self.add_child(instrumental)
	
	conductor = Conductor.new()
	self.add_child(conductor)
	conductor.connect("new_beat", self.new_beat)
	conductor.connect("new_step", self.new_step)
	
	pause_preload = load(pause_scene)
	Global.song_scene = LoadingScreen.scene
	
	chart = load(song_data.difficulties[GameManager.difficulty].chart)
	assert(chart, 'Failed to load chart. is (%s) correct?' % (song_data.difficulties[GameManager.difficulty].chart))
	
	song_speed = SettingsManager.get_value(SettingsManager.SEC_GAMEPLAY, "song_speed")
	
	ui.set_credits(song_data.title, song_data.artist)
	play_song(0)
	Global.set_window_title("Playing: " + song_data.title)
	
	pause_scene = ui_skin.pause_scene
	
	strums = ui.strums
	
	if SettingsManager.get_value(SettingsManager.SEC_GAMEPLAY, "botplay"):
		if OS.is_debug_build():
			get_tree().call_group(&"strums", "set_auto_play", true)
			get_tree().call_group(&"strums", "set_press", false)
	
	if SettingsManager.get_value(SettingsManager.SEC_GAMEPLAY, "downscroll"):
		ui.downscroll_ui()
	
	get_tree().call_group(&"strums", "set_scroll_speed", chart.scroll_speed
	* SettingsManager.get_value(SettingsManager.SEC_GAMEPLAY, "scroll_speed_scale"))
	get_tree().call_group(&"strums", "connect", "note_hit", host.note_hit)
	get_tree().call_group(&"strums", "connect", "note_holding", host.note_holding)
	get_tree().call_group(&"strums", "connect", "note_miss", host.note_miss)
	get_tree().call_group(&"strums", "set_skin", note_skin)
	if SettingsManager.get_value(SettingsManager.SEC_GAMEPLAY, "downscroll"):
		get_tree().call_group(&"strums", "set_scroll", -1)
	
	emit_signal("setup_finished")


func _process(delta):
	accuracy = (timings_sum / entries) if entries != 0.0 else 0.0
	self_delta = delta
	
	health = clamp(health, 0.0, 100.0)
	ui.target_health = health
	
	if health <= 0:
		GameManager.deaths += 1
		DeathScreen.camera_zoom = camera.zoom
		Global.song_scene = get_tree().current_scene.scene_file_path
		get_tree().change_scene_to_file(death_scene)
	
	GameManager.seconds_per_beat = conductor.seconds_per_beat
	
	# Why is this a thing I have to do
	if get_tree() != null:
		get_tree().call_group("note", "update_y")
	
	if Input.is_action_just_pressed("ui_cancel") or Input.is_action_just_pressed("ui_accept"):
		Global.manual_pause = true
		pause()
	
	elif Input.is_action_just_pressed("kill"):
		health = 0
	
	elif Input.is_action_just_pressed("chart_editor") and OS.is_debug_build():
		ChartManager.song = song_data
		ChartManager.difficulty = GameManager.difficulty
		Global.change_scene_to("res://scenes/chart editor/chart_editor.tscn")
	
	if !song_started:
		song_start_offset += delta
		GameManager.song_position = song_start_offset
		
		if song_start_offset >= max(chart.offset, song_start_time):
			play_audios(song_start_time)
			ui.show_credits()
	else:
		GameManager.song_position = instrumental.get_playback_position() + \
				AudioServer.get_time_since_last_mix() - \
				AudioServer.get_output_latency()
		
		conductor.offset = chart.offset + SettingsManager.get_value(SettingsManager.SEC_GAMEPLAY, "offset")
		conductor.offset += chart.get_tempo_time_at(GameManager.song_position)
		
		# Idk how exactly this works I stole this code from sqirradotdev
		position_delta = abs(position_lerp - GameManager.song_position)
		position_lerp += delta * instrumental.pitch_scale
		
		if delta > COMPENSATION or sync_timer <= 0.0 or position_delta >= 0.01 * instrumental.pitch_scale:
			if position_delta >= 0.025 * instrumental.pitch_scale:
				position_lerp = GameManager.song_position
			sync_timer = 0.5
		
		GameManager.song_position = position_lerp
		sync_timer -= delta
	
	conductor.tempo = get_tempo_at(clamp(GameManager.song_position, 0, instrumental.stream.get_length()))
	
	# Instead of before where I would do a linear search per section, a faster method
	# would just be to iterate through as the song is playing, making it faster
	var notes_list = chart.get_notes_data()
	
	if notes_list.size() > 0:
		if current_note < notes_list.size():
			var note = notes_list[current_note]
			
			if note[0] <= (GameManager.song_position + conductor.seconds_per_beat * 4):
				var time: float = note[0]
				var lane: int = note[1]
				var length: float = note[2]
				var type: int = note[3]
				
				emit_signal("create_note", time, lane, length, type, get_tempo_at(time))
				current_note += 1
	
	if instrumental.playing:
		var events_list = chart.get_events_data()
		if events_list.size() > 0:
			if current_event < events_list.size():
				var event = events_list[current_event]
				if event[0] <= GameManager.song_position:
					var time: float = event[0]
					var event_name: String = event[1]
					var event_parameters: Array = event[2]
					
					print("(PlayState) Song Event: \"", event_name, "\" ", str(event_parameters))
					basic_event(time, event_name, event_parameters)
					current_event += 1

##  Gets the tempo at a certain time in seconds
func get_tempo_at(time: float) -> float:
	
	var tempo_dict = chart.get_tempos_data()
	var keys = tempo_dict.keys()
	
	var tempo_output = 0.0
	
	for i in keys.size():
		var dict_time = keys[i]
		if time >= dict_time:
			tempo_output = tempo_dict.get(keys[i])
		else:
			continue
	
	return tempo_output


func play_song(time: float):
	GameManager.started_song(song_data)
	conductor.stream_player = instrumental
	conductor.tempo = get_tempo_at(-chart.offset + time)
	conductor.seconds_per_beat = 60.0 / conductor.tempo
	conductor.offset = chart.offset + SettingsManager.get_value(SettingsManager.SEC_GAMEPLAY, "offset")
	var seconds_per_beat = (60.0 / conductor.tempo)
	
	GameManager.seconds_per_beat = seconds_per_beat
	GameManager.offset = conductor.offset
	
	song_started = false
	song_start_time = time - chart.offset
	song_start_offset = song_start_time - (seconds_per_beat * 4)
	GameManager.song_position = song_start_offset
	
	if time >= seconds_per_beat * 4:
		play_audios(song_start_offset)
	else:
		var countdown_instance = countdown_node.instantiate()
		
		countdown_instance.speed_scale = get_tempo_at(time - chart.offset) / 60.0
		
		ui.add_child(countdown_instance)
		
		countdown_instance.play(ui_skin.countdown_animation)
		countdown_instance.seek(time)
	
	var notes_list = chart.get_notes_data()
	current_note = bsearch_left_range(notes_list, time)
	var events_list = chart.get_events_data()
	current_event = bsearch_left_range(events_list, max(song_start_offset, 0))

# This if for actually playing the audio tracks, the reason this is a function is because
# I also call it in the process function for when the song starts before 4 beats are possible.
func play_audios(time: float):
	var playback = vocals.get_stream_playback()
	
	for stream in vocal_streams:
		vocal_tracks.append(playback.play_stream(stream, time, \
		0.0, song_speed))
	instrumental.play(time)
	instrumental.pitch_scale = song_speed
	song_started = true

# Binary Search of notes and events, gives the index of the note nearest to the given time
func bsearch_left_range(value_set: Array, left_range: float) -> int:
	var length = value_set.size()
	if (length == 0):
		return -1
	if (value_set[length - 1][0] < left_range):
		return -1
	
	var low: int = 0
	var high: int = length - 1
	
	while (low <= high):
		var mid: int = low + int((high - low) / 2)
		
		if (value_set[mid][0] >= left_range): high = mid - 1
		else: low = mid + 1
	
	return high + 1

static func get_rating(time: float) -> String:
	var ratings = [
		[time <= GameManager.SICK_RATING_WINDOW, "sick"],
		[time <= GameManager.GOOD_RATING_WINDOW, "good"],
		[time <= GameManager.BAD_RATING_WINDOW, "bad"],
		[time <= GameManager.SHIT_RATING_WINDOW, "shit"],
		[true, ],
	]
	
	for condition in ratings:
		if condition[0]:
			return condition[1]
	
	return "miss"

func pause():
	var pause_scene_instance = pause_preload.instantiate()
	
	pause_scene_instance.song_title = song_data.title
	pause_scene_instance.credits = song_data.artist
	if GameManager.freeplay:
		pause_scene_instance.deaths = GameManager.deaths
	else:
		pause_scene_instance.deaths = GameManager.week_deaths
	
	host.add_child(pause_scene_instance)
	
	get_tree().paused = true


func score_note(hit_time: float):
	var factor: float = 1.0 - (1.0 / (1.0 + exp(-SCORING_SLOPE * ((hit_time - SCORING_OFFSET) * 1000))))
	var add: int = int(MAX_SCORE * factor + MIN_SCORE)
	add = clamp(add, MIN_SCORE, MAX_SCORE)
	score += add


func basic_event(time: float, event_name: String, event_parameters: Array):
	match event_name:
		"camera_position":
			var camera_position = host.camera_positions[int(event_parameters[0])].global_position
			if camera_position != null: camera.position = camera_position
		"camera_bop":
			var camera_bop = float(event_parameters[0])
			var ui_bop = float(event_parameters[1])
			
			camera.zoom += Vector2(camera_bop, camera_bop) * camera.zoom
			ui.scale += Vector2(ui_bop, ui_bop)
		"camera_zoom":
			var new_zoom = Vector2(float(event_parameters[0]), float(event_parameters[0]))
			@warning_ignore("incompatible_ternary")
			var zoom_time = 0 if event_parameters[1] == "" else float(event_parameters[1])
			var ease_string = event_parameters.get(2)
			var _ease = [Tween.TRANS_CUBIC, Tween.EASE_OUT]
			if ease_string != null:
				_ease = Global.string_to_ease(ease_string)
			
			var tween = create_tween()
			tween.set_trans(_ease[0]).set_ease(_ease[1]).set_parallel(true)
			tween.tween_property(camera, "target_zoom", new_zoom, zoom_time * song_speed)
			tween.tween_property(camera, "zoom", new_zoom, zoom_time * song_speed)
		"bop_rate":
			bop_rate = int(event_parameters[0])
		"bop_delay":
			bop_rate = int(event_parameters[0])
		"camera_bop_strength":
			camera_bop_strength = Vector2(float(event_parameters[0]), float(event_parameters[0]))
		"ui_bop_strength":
			ui_bop_strength = Vector2(float(event_parameters[0]), float(event_parameters[0]))
		"lerping":
			var lerping = true if event_parameters[0] == "true" else false
			ui.lerping = lerping
			camera.lerping = lerping
		"scroll_speed":
			var scroll_speed = float(event_parameters[0])
			var tween_time = 0.0 if event_parameters[1] == "" else float(event_parameters[1])
			
			for strum in strums:
				for lane in strum.strums.size() - 1:
					var tween = create_tween()
					tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
					var scroll_speed_scale: float = SettingsManager.get_value(SettingsManager.SEC_GAMEPLAY, "scroll_speed_scale")
					tween.tween_method(
						strum.set_scroll_speed, strum.get_scroll_speed(lane), scroll_speed * scroll_speed_scale, tween_time * song_speed
						)
		"camera_shake":
			camera.shake(int(event_parameters[0]), float(event_parameters[1]))
	
	emit_signal("new_event", time, event_name, event_parameters)

func song_finished():
	GameManager.finished_song(score)
	
	if GameManager.freeplay:
		match GameManager.play_mode:
			GameManager.PLAY_MODE.CHARTING:
				Global.change_scene_to("res://scenes/chart editor/chart_editor.tscn")
			_:
				Global.change_scene_to("res://scenes/results/results.tscn")
	else:
		Global.change_scene_to(next_scene)

# Conductor Util
func new_beat(current_beat, measure_relative):
	ui.icon_bop(conductor.seconds_per_beat * 0.5 * (1 / instrumental.pitch_scale))

func new_step(current_step, measure_relative):
	if current_step % bop_rate == 0:
		camera.zoom += camera_bop_strength * camera.zoom
		if SettingsManager.get_value(SettingsManager.SEC_PREFERENCES, "ui_bops"):
			ui.scale += ui_bop_strength

# Strum Util
func note_hit(time, lane, note_type, hit_time, strum_manager):
	var playback = vocals.get_stream_playback()
	if vocal_tracks.size() > strum_manager.id:
		playback.set_stream_volume(vocal_tracks[strum_manager.id], 0.0)
	
	if !strum_manager.enemy_slot:
		if SettingsManager.get_value(SettingsManager.SEC_PREFERENCES, "hit_sounds"):
			SoundManager.hit.play()
		
		var rating = get_rating(abs(hit_time))
		var strum_node = strum_manager.get_strumline(lane)
		
		GameManager.tallies[rating] += 1
		GameManager.tallies["total_notes"] += 1
		score_note(hit_time)
		
		match rating:
			"sick":
				health += 1
				timings_sum += 0.9825
				strum_manager.create_splash(lane, strum_node.strum_name + " splash")
			"good":
				timings_sum += 0.65
			"bad":
				health -= 0.35
				timings_sum += 0.25
				combo = -1
				emit_signal("combo_break")
			"shit":
				health -= 0.35
				timings_sum += -1
				combo = -1
				emit_signal("combo_break")
			_:
				note_miss(time, lane, 0, note_type, hit_time, strum_manager)
		
		entries += 1
		combo += 1
		if combo > GameManager.tallies["max_combo"]:
			GameManager.tallies["max_combo"] = combo
		
		accuracy = (timings_sum / entries)
		if GameManager.tallies.sick == GameManager.tallies.total_notes:
			rating = "fc_" + rating
		
		show_combo(rating, combo)
		update_ui_stats()

func note_holding(time, lane, note_type, strum_manager):
	var playback = vocals.get_stream_playback()
	if vocal_tracks.size() > strum_manager.id: playback.set_stream_volume(vocal_tracks[strum_manager.id], 0.0)
	
	if !strum_manager.enemy_slot:
		health += abs(time) * 4
		score += int(abs(time) * HOLD_SCORE)
		
		timings_sum += time
		entries += time
		
		accuracy = (timings_sum / entries)
		
		update_ui_stats()

func note_miss(time, lane, length, note_type, hit_time, strum_manager):
	var playback = vocals.get_stream_playback()
	if vocal_tracks.size() > strum_manager.id: playback.set_stream_volume(vocal_tracks[strum_manager.id], -80.0)
	
	if !strum_manager.enemy_slot:
		if int(note_type) == -1:
			score -= 10
			health -= 1
			update_ui_stats()
		else:
			score -= 100
			health -= (1 + clamp(combo / 20.0 + (length * HOLD_HEALTH), 0, 20))
			combo = 0
			misses += 1
			 
			GameManager.tallies["miss"] = misses
			GameManager.tallies["total_notes"] += 1
			entries += 1 + length
			accuracy = (timings_sum / entries)
			
			show_combo("miss", combo)
			emit_signal("combo_break")
			update_ui_stats()

func update_ui_stats():
	ui.accuracy = accuracy
	ui.misses = misses
	ui.target_health = health
	ui.score = score

# Visual Util
func show_combo(rating: String, _combo: int):
	var rating_instance = rating_node.instantiate()
	
	rating_instance.ui_skin = ui_skin
	rating_instance.rating = rating
	
	var combo_numbers_manager_instance = combo_numbers_manager_node.instantiate()
	
	combo_numbers_manager_instance.ui_skin = ui_skin
	combo_numbers_manager_instance.combo = _combo
	if misses == 0:
		combo_numbers_manager_instance.fc = true
	
	if SettingsManager.get_value(SettingsManager.SEC_PREFERENCES, "combo_ui"):
		rating_instance.position = Vector2(-32, 182)
		combo_numbers_manager_instance.position = Vector2(96, 232)
		
		ui.add_child(rating_instance)
		ui.add_child(combo_numbers_manager_instance)
	else:
		rating_instance.position = rating_position.global_position
		rating_instance.z_index = 1000
		rating_instance.scale *= combo_scale_multiplier
		combo_numbers_manager_instance.position = combo_position.global_position
		combo_numbers_manager_instance.scale *= combo_scale_multiplier
		combo_numbers_manager_instance.z_index = 1000
		
		self.add_child(rating_instance)
		self.add_child(combo_numbers_manager_instance)
