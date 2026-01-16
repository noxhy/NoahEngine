extends Node2D

const LABEL_FONT: Font = preload("res://assets/fonts/bold_font.ttf")
const NOTE_PRELOAD = preload("res://scenes/game/note/chart_note.tscn")
const NOTE_SKIN = preload("res://assets/sprites/playstate/default/default_note_skin.tres")
const STRUM_BUTTON_PRELOAD = preload("res://scenes/chart_editor/strum_button.tscn")

const NEW_FILE_POPUP_PRELOAD = preload("res://scenes/chart_editor/new_file_popup.tscn")
const OPEN_FILE_POPUP_PRELOAD = preload("res://scenes/chart_editor/open_file_popup.tscn")
const CONVERT_CHART_POPUP_PRELOAD = preload("res://scenes/chart_editor/convert_chart_popup.tscn")

const SNAPS = [4.0, 8.0, 12.0, 16.0, 20.0, 24.0, 32.0, 48.0, 64.0, 96.0, 192.0]

@onready var undo_redo: UndoRedo = UndoRedo.new()

@export_group("Colors")
@export var hover_color: Color = Color(1, 1, 1, 0.5)
@export var divider_color: Color = Color(1, 1, 1, 0.5)
@export var current_time_color: Color = Color(1, 0, 0, 1)
@export var muted_color: Color = Color(0.8, 0.8, 0.8, 0.5)
@export var box_color: Color = Color.LIGHT_GREEN
@export var selected_color: Color = Color.GREEN

## Chart Variables
var chart: Chart = null
var backup_chart: Chart = null
# So it turns out that the track ID's are not sequential and can be whatever number they want, I did this so it'd be easier
var vocal_tracks: Array = []
var scene: String

## Editor Variables
var song_position: float = 0.0
var start_offset: float = 0.0
var song_speed: float = 1.0
var current_tempo: float = 60.0
var current_beats_per_measure: int = 4
var current_steps_per_measure: int = 16
var current_difficulty: String
var note_list: Array = []
var clipboard: Array = []
var can_chart: bool = false

var current_snap: int = 3
var chart_snap: float = SNAPS[current_snap]

var selected_notes: Array = []
var selected_note_nodes: Array = []
var placing_note: bool = false
var changed_length: bool = false
var current_note: int = -1
var start_box: Vector2 = Vector2.ZERO
var bounding_box: bool = false
var moving_notes: bool = false
var start_lane: int = 0
var start_time: float = 0.0
var min_lane: int = 0
var max_lane: int = 0
var moved_time_distance: float
var moved_lane_distance: int
var hovered_note: int = 0
var current_focus_owner = null
var current_focus_viewport: Viewport = null
var current_visible_notes_L: int = -1
var current_visible_notes_R: int = -1
var min_visible_note_time: float
var max_visible_note_time: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_viewport().gui_focus_changed.connect(_on_gui_focus_changed)
	Global.set_window_title("Chart Editor")
	song_speed = SettingsManager.get_value("gameplay", "song_speed")
	
	if ChartManager.song != null:
		var old_song = null
		var song = ChartManager.song
		load_song(song, ChartManager.difficulty)
		var action: String = "Loaded Song"
		undo_redo.create_action(action)
		undo_redo.add_do_property(self, "song", song)
		undo_redo.add_do_reference(%"History Window".add_action(action))
		undo_redo.add_undo_property(self, "song", old_song)
		undo_redo.commit_action()
		can_chart = true
	
	update_grid()
	
	%"Chart Snap".value = chart_snap
	
	## Initializing Popup Signals
	%"File Button".get_popup().connect("id_pressed", self.file_button_item_pressed)
	%"File Button".get_popup().set_item_checked(
		%"File Button".get_popup().get_item_index(3), SettingsManager.get_value("chart", "auto_save"))
	%"File Button".get_popup().set_hide_on_checkable_item_selection(false)
	
	%"Edit Button".get_popup().connect("id_pressed", self.edit_button_item_pressed)
	%"Edit Button".get_popup().set_hide_on_checkable_item_selection(false)
	
	%"Window Button".get_popup().connect("id_pressed", self.window_button_item_pressed)
	%"Window Button".get_popup().set_hide_on_checkable_item_selection(false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if start_offset < 0: start_offset = 0
	
	if ChartManager.song != null:
		if %Instrumental.playing:
			song_position = %Instrumental.get_playback_position() - start_offset
			%"Song Slider".value = song_position
			
			GameManager.seconds_per_beat = $Conductor.seconds_per_beat
			
			var notes_list = chart.get_notes_data()
			
			if notes_list.size() > 0:
				if current_note < notes_list.size():
					var note = notes_list[current_note]
					if note[0] <= (song_position + start_offset):
						var lane: float = note[1]
						for id in ChartManager.strum_data.size():
							if ((lane >= ChartManager.strum_data[id]["strums"][0]) and (lane <= ChartManager.strum_data[id]["strums"][1])):
								if (!ChartManager.strum_data[id]["muted"]):
									%"Hit Sound".play()
						
						current_note += 1
			
			for strum in ChartManager.strum_data.size():
				var track = ChartManager.strum_data[strum]["track"]
				if track < vocal_tracks.size():
					if ChartManager.strum_data[strum]["muted"]:
						%Vocals.get_stream_playback().set_stream_volume(vocal_tracks[track], -80)
					else:
						%Vocals.get_stream_playback().set_stream_volume(vocal_tracks[track], 0)
		else:
			if Input.is_action_just_pressed("mouse_scroll_up"):
				if !Input.is_action_pressed("control"):
					if can_chart:
						song_position -= $Conductor.seconds_per_beat
						song_position = snapped(song_position, $Conductor.seconds_per_beat)
						song_position = clamp(song_position, start_offset - chart.offset, %Instrumental.stream.get_length())
						%"Song Slider".value = song_position
				else:
					current_snap += 1
					chart_snap = SNAPS[current_snap % SNAPS.size()]
					%"Chart Snap".value = chart_snap
			
			if Input.is_action_just_pressed("mouse_scroll_down"):
				if !Input.is_action_pressed("control"):
					if can_chart:
						song_position += $Conductor.seconds_per_beat
						song_position = snapped(song_position, $Conductor.seconds_per_beat)
						song_position = clamp(song_position, start_offset - chart.offset, %Instrumental.stream.get_length())
						%"Song Slider".value = song_position
				else:
					current_snap -= 1
					chart_snap = SNAPS[current_snap % SNAPS.size()]
					%"Chart Snap".value = chart_snap
			
			$Conductor.time = song_position
		
		if chart != null:
			if Input.is_action_pressed("control") and Input.is_action_just_pressed("save"):
				save()
	
	if chart != null:
		current_tempo = chart.get_tempo_at(song_position + start_offset)
		$Conductor.tempo = current_tempo
		var meter = chart.get_meter_at(song_position + start_offset)
		current_beats_per_measure = meter[0]
		current_steps_per_measure = meter[1]
		$Camera2D.position.y = 360 + time_to_y_position(song_position)
		$Conductor.offset = chart.get_tempo_time_at(song_position + start_offset) - chart.offset
		$"Grid Layer/Parallax2D".scroll_offset.y = time_to_y_position($Conductor.offset)
		
		if Input.is_action_pressed("control") and Input.is_action_just_pressed("undo"):
			undo()
		if Input.is_action_pressed("control") and Input.is_action_just_pressed("redo"):
			redo()
	
	%"Current Time Label".text = float_to_time(song_position + start_offset)
	if ChartManager.song:
		%"Time Left Label".text = "-" + float_to_time(%Instrumental.stream.get_length() - song_position)
	else:
		%"Time Left Label".text = "- ??:??"
	
	if Input.is_action_just_pressed("ui_accept"):
		_on_play_button_toggled(!%Instrumental.stream_paused)
	
	var grid_offset: Vector2 = %Grid.position + $"Grid Layer".offset# - $"Grid Layer/Parallax2D".scroll_offset
	var mouse_position: Vector2 = get_global_mouse_position() - grid_offset
	var grid_position: Vector2 = %Grid.get_grid_position(mouse_position)
	var snapped_position: Vector2i = Vector2i(%Grid.get_grid_position(mouse_position, %Grid.grid_size * Vector2(1, current_steps_per_measure / chart_snap)))
	
	$"Grid Layer/Parallax2D".repeat_size.y = %Grid.get_size().y
	
	var screen_mouse_position = get_global_mouse_position() - Vector2(0, $Camera2D.position.y - 360)
	
	if Input.is_action_just_pressed(&"mouse_left"):
		if !Input.is_action_pressed(&"control"):
			if screen_mouse_position.y > 64 and screen_mouse_position.y < 640:
				if can_chart:
					if (((grid_position.x - 1) > 0 and (grid_position.x - 1) < ChartManager.strum_count)
					and !current_focus_owner):
						var lane: int = snapped_position.x - 1
						var time: float = grid_position_to_time(snapped_position, true)
						
						if !is_note_at(lane, time):
							var action: String = "Add Note"
							undo_redo.create_action(action)
							undo_redo.add_do_method(self.place_note.bind(time, lane, 0, 0, true))
							undo_redo.add_do_reference(%"History Window".add_action(action))
							undo_redo.add_undo_method(self.remove_note.bind(lane, time))
							undo_redo.commit_action()
							%"Note Place".play()
							placing_note = true
						else:
							var i: int = find_note(lane, time)
							if selected_notes.has(i):
								moving_notes = true
								start_lane = lane
								start_time = time
								min_lane = ChartManager.strum_count
								max_lane = 0
								for j in selected_notes:
									var note = chart.get_notes_data()[j]
									min_lane = min(min_lane, note[1])
									max_lane = max(max_lane, note[1])
								
								min_lane = 0 + (start_lane - min_lane)
								max_lane = ChartManager.strum_count - 1 - (max_lane - start_lane)
							else:
								var index: int = find_note(lane, time)
								selected_notes = [index]
								selected_note_nodes = [note_list[index - current_visible_notes_L]]
								min_lane = 0
								max_lane = ChartManager.strum_count - 1
					elif (((grid_position.x - 1) > 0 and (grid_position.x - 1) < ChartManager.strum_count)
					and current_focus_owner):
						current_focus_viewport.gui_release_focus()
						current_focus_owner = null
		else:
			if can_chart:
				bounding_box = true
				start_box = get_global_mouse_position()
	
	if Input.is_action_pressed("mouse_right"):
		if !Input.is_action_pressed("control"):
				if screen_mouse_position.y > 64 and screen_mouse_position.y < 640:
					if can_chart:
						if !Input.is_action_pressed("control"):
							var lane: int = snapped_position.x - 1
							var time: float = grid_position_to_time(snapped_position, true)
							
							if hovered_note != -1:
								var i: int = hovered_note
								var note = chart.chart_data.notes[i]
								var length: float = note[2]
								var note_type: int = note[3]
								
								var action: String = "Remove Note"
								undo_redo.create_action(action)
								undo_redo.add_do_method(self.remove_note.bind(i))
								undo_redo.add_do_reference(%"History Window".add_action(action))
								undo_redo.add_undo_method(self.place_note.bind(time, lane, length, note_type, true))
								undo_redo.commit_action()
								%"Note Remove".play()
								selected_notes.erase(i)
								var j: int = 0
								for k in selected_notes:
									if k > i:
										selected_notes[j] = k - 1
									j += 1
								
								hovered_note = -1
								
								if SettingsManager.get_value("chart", "auto_save"):
									save()
	
	if Input.is_action_pressed("mouse_left"):
		if !Input.is_action_pressed("control"):
			if screen_mouse_position.y > 64 and screen_mouse_position.y < 640:
				if !%Instrumental.playing:
					if can_chart:
						## Song Position Slider
						if grid_position.x < 1 and grid_position.x >= 0:
							start_offset = grid_position_to_time(grid_position) - song_position
						elif ((grid_position.x - 1) > 0 and (grid_position.x - 1) < ChartManager.strum_count):
							if placing_note:
								var cursor_time = grid_position_to_time(snapped_position, true)
								for i in selected_notes:
									var note: Array = chart.get_notes_data()[i]
									
									var time: float = note[0]
									var lane: int = note[1]
									var note_type: int = note[3]
									
									var distance = snappedf(clamp(cursor_time - time, 0.0, 16.0) / $Conductor.seconds_per_beat, 1.0 / chart_snap)
									chart.chart_data.notes[i] = [time, lane, distance, note_type]
									
									changed_length = (distance > 0)
									if changed_length:
										if (note_list[i - current_visible_notes_L].length != distance): %"Note Stretch".play()
										note_list[i - current_visible_notes_L].length = distance
									
									if SettingsManager.get_value("chart", "auto_save"): 
										save()
						
						if ((grid_position.x - 1) > 0 and (grid_position.x - 1) < ChartManager.strum_count):
							if moving_notes:
								var cursor_time = grid_position_to_time(snapped_position, true)
								var cursor_lane = snapped_position.x - 1
								
								var lane_distance = cursor_lane - start_lane
								var time_distance = cursor_time - start_time
								changed_length = true
								
								if ((start_lane + lane_distance) >= min_lane and (start_lane + lane_distance) <= max_lane):
									if changed_length:
										var j: int = 0
										for i in selected_notes:
											var node = selected_note_nodes[j]
											var time: float = node.time
											var lane: int = node.lane
											
											node.position = Vector2(
												%Grid.get_real_position(Vector2(1.5 + node.lane + lane_distance, 0)).x,
												time_to_y_position(node.time + time_distance) + %Grid.grid_size.y * %Grid.zoom.y / 2) + $"Grid Layer".offset
											j += 1
										
										if SettingsManager.get_value("chart", "auto_save"):
											save()
										
										moved_time_distance = time_distance
										moved_lane_distance = lane_distance
										# start_time += time_distance
										# start_lane += lane_distance
										# min_lane = 0 + (start_lane - min_lane)
										# max_lane = ChartManager.strum_count - 1 - (max_lane - start_lane)
	
	if Input.is_action_just_released("mouse_left"):
		if placing_note:
			if changed_length:
				var action: String = "Changed Note Length(s)"
				undo_redo.create_action(action)
				for i in selected_notes:
					undo_redo.add_do_property(note_list[i - current_visible_notes_L],
					"length", note_list[i - current_visible_notes_L].length)
					undo_redo.add_undo_property(note_list[i - current_visible_notes_L],
					"length", 0.0)
				
				undo_redo.add_do_reference(%"History Window".add_action(action))
				undo_redo.commit_action()
			
			placing_note = false
			changed_length = false
		
		if bounding_box:
			bounding_box = false
			
			var rect = Rect2(start_box, get_global_mouse_position() - start_box).abs()
			# Added leniency since notes are centered from the top
			var pos_1: Vector2 = %Grid.get_grid_position(rect.position - grid_offset) - Vector2(1, 0.5)
			var pos_2: Vector2 = %Grid.get_grid_position(rect.end - grid_offset) - Vector2(1, 0.5)
			var time_a: float = grid_position_to_time(pos_1, true)
			var time_b: float = grid_position_to_time(pos_2, true)
			
			print("time a: ", time_a, " time b: ", time_b)
			print("lane a: ", pos_1.x, " lane b: ", (pos_2.x))
			
			var L: int = bsearch_left_range(chart.get_notes_data(), time_a)
			var R: int = bsearch_right_range(chart.get_notes_data(), time_b)
			
			if (L == R + 1):
				L -= 1
			L = max(0, L)
			selected_notes = range(L, R + 1)
			selected_note_nodes = []
			
			var j: int = 0
			for i in range(selected_notes.size()):
				var lane: int = int(chart.get_notes_data()[selected_notes[i - j]][1])
				if !(range(int(pos_1.x), int(pos_2.x) + 1).has(lane)):
					selected_notes.remove_at(selected_notes[i - j])
					j += 1
			
			for i in selected_notes:
				selected_note_nodes.append(note_list[i - current_visible_notes_L])
				print(current_visible_notes_L)
				print(note_list[i - current_visible_notes_L].time)
			
			if selected_notes.size() > 0:
				%"Note Place".play()
		
		if moving_notes:
			var temp: Array = []
			var i: int = 0
			for note in selected_note_nodes:
				temp.append([note.time + moved_time_distance, note.lane + moved_lane_distance, note.length, note.note_type])
				remove_note(selected_notes[i] - i)
				i += 1
			
			selected_notes = []
			selected_note_nodes = []
			for packet in temp:
				place_note(packet[0], packet[1], packet[2], packet[3], true, true)
			
			for packet in temp:
				i = find_note(packet[1], packet[0])
				selected_notes.append(i)
				selected_note_nodes.append(note_list[i - current_visible_notes_L])
			selected_notes.sort()
			
			moving_notes = false
			%"Note Place".play()
	
	if Input.is_action_just_released("control"):
		bounding_box = false
	
	if Input.is_action_pressed("ui_text_delete"):
		if can_chart:
			if selected_notes.size() > 0:
				var temp: Array = []
				for i in selected_notes:
					var note = chart.get_notes_data()[i]
					temp.append([note[0], note[1], note[2], note[3]])
				var action: String = "Remove Notes"
				undo_redo.create_action(action)
				undo_redo.add_do_method(self.remove_notes.bind(selected_notes))
				undo_redo.add_do_reference(%"History Window".add_action(action))
				undo_redo.add_undo_method(self.place_notes.bind(temp))
				undo_redo.commit_action()
				selected_notes = []
				%"Note Remove".play()
	
	# Postponed
	#if Input.is_action_just_pressed("ui_copy"):
		#clipboard = []
		#for note in selected_notes:
			#clipboard.append(chart.get_notes_data()[note])
		#print("copied notes: ", clipboard)
	#
	#if Input.is_action_just_pressed("ui_paste"):
		#if clipboard.size() > 0:
			#selected_notes = place_notes(clipboard)
			#selected_note_nodes = []
			#for index in selected_notes:
				#selected_note_nodes.append(note_list[index - current_visible_notes_L])
			#print("pasted notes: ", clipboard)
	
	queue_redraw()


func _draw() -> void:
	var rect: Rect2
	
	## Box when you're holding control
	if bounding_box:
		rect = Rect2(start_box, get_global_mouse_position() - start_box).abs()
		draw_rect(rect, box_color)
	
	if chart != null:
		## The offset the grid has from the normal canvas layer
		var grid_offset: Vector2 = %Grid.position + $"Grid Layer".offset# + $"Grid Layer/Parallax2D".scroll_offset
		var mouse_position: Vector2 = get_global_mouse_position() - grid_offset
		var grid_position: Vector2i = Vector2i(%Grid.get_grid_position(mouse_position))
		var snapped_position: Vector2i = Vector2i(%Grid.get_grid_position(mouse_position, %Grid.grid_size * Vector2(1, current_steps_per_measure / chart_snap)))
		
		## Song Start Offset Marker
		rect = Rect2(grid_offset + %Grid.get_real_position(Vector2(1, 0)) + Vector2(0, time_to_y_position(song_position + chart.offset + start_offset) - 2), \
		%Grid.get_real_position(Vector2(%Grid.columns, 0)) - %Grid.get_real_position(Vector2(1, 0)) + Vector2(0, 4))
		draw_rect(rect, current_time_color)
		# The box at the start of the marker
		rect = Rect2(grid_offset + %Grid.get_real_position(Vector2(0, 0)) + Vector2(0, time_to_y_position(song_position + chart.offset + start_offset) - 4), \
		%Grid.get_real_position(Vector2(1, 0)) - %Grid.get_real_position(Vector2(0, 0)) + Vector2(0, 8))
		draw_rect(rect, current_time_color)
		
		## Hover Box
		if (grid_position.x >= 0 and grid_position.x < %Grid.columns and !current_focus_owner):
			rect = Rect2(%Grid.get_real_position(snapped_position, %Grid.grid_size * Vector2(1, current_steps_per_measure / chart_snap)) + grid_offset, \
			%Grid.grid_size * %Grid.zoom * Vector2(1, current_steps_per_measure / chart_snap))
			draw_rect(rect, hover_color)
		
		## Note Highlighting
		for i in selected_notes:
			if i >= current_visible_notes_L and i <= current_visible_notes_R:
				var note = note_list[i - current_visible_notes_L]
				var length: float = note.length + ($Conductor.beats_per_measure * 1.0 / $Conductor.steps_per_measure)
				length *= %Grid.grid_size.y * %Grid.zoom.y
				length *= ($Conductor.steps_per_measure * 1.0 / $Conductor.beats_per_measure)
				rect = Rect2(note.global_position - (%Grid.grid_size / 2), Vector2(%Grid.grid_size.x, length))
				draw_rect(rect, selected_color)


func update_grid():
	%Grid.columns = 2 + ChartManager.strum_count
	%Grid.rows = current_steps_per_measure
	%"Strum Labels".position = %Grid.get_real_position(Vector2(1, -1)) - Vector2(2, 296)
	%"Strum Labels".custom_minimum_size.x = ChartManager.strum_count * %Grid.grid_size.x * %Grid.zoom.x + 4
	
	for n in %"Strum Labels".get_children():
		n.queue_free()

	for id in ChartManager.strum_data.size():
		var strum_label_instance = STRUM_BUTTON_PRELOAD.instantiate()
		
		strum_label_instance.id = id
		strum_label_instance.muted = ChartManager.strum_data[id]["muted"]
		
		%"Strum Labels".add_child(strum_label_instance)
		strum_label_instance.custom_minimum_size.x = (ChartManager.strum_data[id]["strums"][1] + 1 - ChartManager.strum_data[id]["strums"][0]) * %Grid.grid_size.x * %Grid.zoom.x
		strum_label_instance.size.y = 32
		
		if ChartManager.strum_data[id]["strums"][0] == 0:
			strum_label_instance.get_node("Move Lane Left").visible = false
		if ChartManager.strum_data[id]["strums"][1] == ChartManager.strum_count - 1:
			strum_label_instance.get_node("Move Lane Right").visible = false
		
		strum_label_instance.connect(&"move_bound_left", self.move_bound_left)
		strum_label_instance.connect(&"move_bound_right", self.move_bound_right)
		strum_label_instance.connect(&"opened", self.disable_charting)
		strum_label_instance.connect(&"closed", self.close_popup)
		strum_label_instance.connect(&"updated", self.updated_strums)
		strum_label_instance.connect(&"gui_focus_changed", self._on_gui_focus_changed)
	
	%"Strum Labels".size.y = 32


func load_song(song: Song, difficulty: Variant = null):
	ChartManager.song = song
	if difficulty == null:
		difficulty = ChartManager.song.difficulties.keys()[0]
	current_difficulty = difficulty
	var difficulty_data: Dictionary = song.difficulties.get(difficulty)
	chart = load(difficulty_data.chart)
	scene = song.scene if !difficulty_data.has("scene") else difficulty_data.scene
	ChartManager.difficulty = difficulty
	undo_redo.clear_history()
	get_tree().call_group(&"history", &"queue_free")
	%Instrumental.stream = load(ChartManager.song.instrumental)
	play_audios(0.0)
	
	%"Song Slider".max_value = %Instrumental.stream.get_length()
	%"Song Slider".value = 0.0
	current_tempo = chart.get_tempo_at(0.0)
	var meter = chart.get_meter_at(0.0)
	current_beats_per_measure = meter[0]
	current_steps_per_measure = meter[1]
	$Conductor.offset = chart.offset
	
	%"Difficulty Button".get_popup().clear()
	for d in ChartManager.song.difficulties.keys():
		%"Difficulty Button".get_popup().add_item(d)
	
	%"Difficulty Button".select(ChartManager.song.difficulties.keys().find(difficulty))
	
	%"Metadata Window".song_name = ChartManager.song.title
	%"Metadata Window".song_artist = ChartManager.song.artist
	%"Metadata Window".song_icon = ChartManager.song.icons.resource_path
	%"Metadata Window".song_scene = ChartManager.song.scene
	%"Metadata Window".starting_tempo = ChartManager.song.tempo
	%"Metadata Window".update_stats()
	
	load_chart(chart)
	update_grid()
	load_waveforms()
	can_chart = true


func load_song_path(path: String, difficulty: Variant = null):
	var song = load(path)
	if song is not Song:
		printerr("File: ", path, " is not a song file.")
		return
	load_song(song, difficulty)


func load_chart(file: Chart, ghost: bool = false):
	if file:
		backup_chart = file.duplicate(true)
	selected_notes = []
	selected_note_nodes = []
	get_tree().call_group(&"notes", &"queue_free")
	note_list = []
	undo_redo.clear_history()
	get_tree().call_group(&"history", &"queue_free")
	var action: String = "Loaded Chart"
	undo_redo.create_action(action)
	undo_redo.add_do_property(self, "chart", file)
	undo_redo.add_do_reference(%"History Window".add_action(action))
	undo_redo.commit_action()
	can_chart = true
	load_section(song_position)

## Loads all the notes and waveforms for the next two waveforms.
func load_section(time: float):
	var _range: float = $Conductor.seconds_per_beat * $Conductor.beats_per_measure * 2
	var L: int = bsearch_left_range(chart.get_notes_data(), time - _range)
	var R: int = bsearch_right_range(chart.get_notes_data(), time + _range)
	
	if selected_notes.size() > 0:
		L = min(selected_notes[0], L)
		R = max(R, selected_notes[selected_notes.size() - 1])
	
	var cache = []
	if L > -1 and R > -1:
		## Clearing any invisible notes
		if current_visible_notes_L != L or current_visible_notes_R != R:
			var i: int = 0
			for note in note_list:
				if note:
					if (note.time < chart.get_notes_data()[L][0]
					or note.time > chart.get_notes_data()[R][0]):
						note_list[i].queue_free()
						note_list.remove_at(i)
						i -= 1
				
				i += 1
		
		for i in range(L, R + 1):
			if i >= current_visible_notes_L and i <= current_visible_notes_R:
				continue
			
			var note = chart.get_notes_data()[i]
			place_note(note[0], note[1], note[2], note[3], false, false, true)
		
		current_visible_notes_L = L
		current_visible_notes_R = R
		min_visible_note_time = INF
		max_visible_note_time = 0
	
	get_tree().call_group(&"dividers",  &"queue_free")
	for i in range($Conductor.beats_per_measure):
		var rect = ColorRect.new()
		var size: float = 4 if i == 0 else 2
		
		rect.size = Vector2(%Grid.get_size().x, size)
		rect.position = %Grid.position
		rect.position.x -= %Grid.get_size().x / 2
		rect.position.y += %Grid.grid_size.y * $Conductor.steps_per_measure / $Conductor.beats_per_measure * i
		rect.position.y -= rect.size.y / 2
		
		$"Grid Layer/Parallax2D".add_child(rect)
		rect.add_to_group(&"dividers")
	
	for i in [1]:
		var rect = ColorRect.new()
		var size: float = 4 if i == 0 else 2
		
		rect.size = Vector2(size, %Grid.get_size().y)
		rect.position = %Grid.position
		rect.position.x += %Grid.grid_size.x * i
		rect.position.x -= %Grid.get_size().x / 2
		rect.position.x -= rect.size.x / 2
		
		$"Grid Layer/Parallax2D".add_child(rect)
		rect.add_to_group(&"dividers")
	
	for packet in ChartManager.strum_data:
		var rect = ColorRect.new()
		var size: float = 2
		
		rect.size = Vector2(size, %Grid.get_size().y)
		rect.position = %Grid.position
		rect.position.x += %Grid.grid_size.x * (packet.get("strums")[1] + 2)
		rect.position.x -= %Grid.get_size().x / 2
		rect.position.x -= rect.size.x / 2
		
		$"Grid Layer/Parallax2D".add_child(rect)
		rect.add_to_group(&"dividers")


func new_file(path: String, song: Song):
	var old_song = ChartManager.song
	load_song(song)
	var action: String = "Created New Song"
	undo_redo.create_action(action)
	undo_redo.add_do_property(self, "song", song)
	undo_redo.add_do_reference(%"History Window".add_action(action))
	undo_redo.add_undo_property(self, "song", old_song)
	undo_redo.commit_action()
	can_chart = true

## Adds an instance of a note on the chart editor, placed boolean adds it to the chart data.
## Reset the select notes and note nodes list before calling moved
func place_note(time: float, lane: int, length: float, type: int, placed: bool = false, moved: bool = false, sorted: bool = false) -> int:
	var directions = ["left", "down", "up", "right"]
	
	var note_instance = NOTE_PRELOAD.instantiate()
	
	var meter = chart.get_meter_at(time)
	
	note_instance.time = time
	note_instance.length = length
	note_instance.lane = lane
	note_instance.note_type = type
	note_instance.position = Vector2(%Grid.get_real_position(Vector2(1.5 + lane, 0)).x, time_to_y_position(time) + %Grid.grid_size.y * %Grid.zoom.y / 2)
	note_instance.position += Vector2(640, 64)
	note_instance.grid_size = (%Grid.grid_size * %Grid.zoom)
	# I am treating scroll speed as a multiplier that would've acted like the grid size for
	# sizing purposes
	note_instance.scroll_speed = (meter[1] * 1.0 / meter[0])
	note_instance.direction = directions[int(lane) % 4]
	note_instance.animation = directions[int(lane) % 4]
	
	note_instance.note_skin = NOTE_SKIN
	
	var output: int
	
	if placed:
		var L: int = bsearch_left_range(chart.get_notes_data(), time)
		if L != -1:
			note_list.insert(L - current_visible_notes_L, note_instance)
			chart.chart_data["notes"].insert(L, [time, lane, length, type])
			
			if !moved:
				selected_notes = [L]
				selected_note_nodes = [note_instance]
				min_lane = 0
				max_lane = ChartManager.strum_count - 1
			
			output = L
		else:
			note_list.append(note_instance)
			chart.chart_data["notes"].append([time, lane, length, type])
			selected_notes = [chart.get_notes_data().size() - 1]
			selected_note_nodes = [note_instance]
			min_lane = 0
			max_lane = ChartManager.strum_count - 1
			output = note_list.size()
	else:
		if sorted:
			var L: int = bsearch_left_range_note(note_list, time)
			if L == -1:
				note_list.append(note_instance)
				output = note_list.size()
			else:
				note_list.insert(L, note_instance)
				output = L
			
			# This is just here to see if the insertion sort worked
			# note_list.sort_custom(self.sort_note)
		else:
			note_list.append(note_instance)
			output = note_list.size()
	
	$"Notes Layer".add_child(note_instance)
	note_instance.add_to_group(&"notes")
	note_instance.area.connect(&"mouse_entered", self.update_note.bind(note_instance))
	note_instance.area.connect(&"mouse_exited", self.update_note.bind(null))
	return output

func sort_note(a, b):
	return a.time < b.time

# Returns the indexes of the new notes
func place_notes(notes: Array) -> Array:
	var indices: Array = []
	for note in notes:
		indices.append(place_note(note[0], note[1], note[2], note[3], true))
	
	return indices

## Giving only 1 parameter removes the note at the given index
func remove_note(lane: int, time: float = -1):
	var i: int
	if time != -1:
		i = find_note(lane, time)
	else:
		i = lane
	
	if i <= -1:
		return
	
	if range(note_list.size()).has(i - current_visible_notes_L):
		note_list[i - current_visible_notes_L].queue_free()
		note_list.remove_at(i - current_visible_notes_L)
	chart.chart_data["notes"].remove_at(i)

func remove_notes(notes: Array):
	var i: int = 0
	for note in notes:
		remove_note(note - i)
		i += 1

## Returns the index of the given note in the notes list.
func find_note(lane: int, time: float) -> int:
	var L: int = bsearch_left_range(chart.get_notes_data(), time - 0.1)
	var R: int = bsearch_right_range(chart.get_notes_data(), time + 0.1)
	
	if (L == -1 or R == -1):
		return -1
	
	# Just so I don't have to make a new return case because I'm lazy
	if (L == R + 1):
		L -= 1
	for i in range(L, R + 1):
		var note: Array = chart.get_notes_data()[i]
		if (note[1] == lane):
			if is_equal_approx(note[0], time):
				return i
	
	return -1

func play_audios(time: float):
	%Vocals.stream = AudioStreamPolyphonic.new()
	# This is to prevent null references
	%Vocals.play()
	%Vocals.stream.polyphony = ChartManager.song.vocals.size()
	
	var playback = %Vocals.get_stream_playback()
	vocal_tracks = []
	for stream in ChartManager.song.vocals:
		vocal_tracks.append(playback.play_stream(load(stream),
		time - chart.offset + start_offset, 0.0, song_speed))
	
	time = clamp(time, 0, %Instrumental.stream.get_length() - 0.1)
	%Instrumental.play(time - chart.offset + start_offset)
	%Instrumental.pitch_scale = song_speed
	song_position = time - chart.offset + start_offset
	
	current_note = bsearch_left_range(chart.get_notes_data(), song_position)
	
	if chart.get_notes_data().size() > 0:
		if song_position > chart.get_notes_data()[chart.get_notes_data().size() - 1][0]:
			current_note = chart.get_notes_data().size() - 1

## Converts a float of seconds into a time format of MM:SS.mmm
func float_to_time(time: float) -> String:
	var minutes: int = floor(fmod(time, 3600.0) / 60.0)
	var seconds: int = floor(fmod(time, 60.0))
	var milliseconds: int = floor(fmod(time, 1.0) * 100.0)
	
	return "%02d:%02d.%02d" % [minutes, seconds, milliseconds]

## This assumes that the tempo and meter dictionaries are sorted
func time_to_y_position(time: float) -> float:
	var tempo_data: Dictionary = chart.get_tempos_data()
	var _offset: float = -chart.offset
	var y_offset: float = 0
	
	var i: int = 0
	var meter: Array = []
	
	var L: float = tempo_data.keys()[0]
	var R: float = tempo_data.keys()[0]
	
	var tempo: float = 60.0
	
	while R < time:
		if i + 1 >= tempo_data.size():
			R = time
		else:
			R = tempo_data.keys()[i + 1]
		
		if R > time:
			R = time
		
		tempo = tempo_data.get(L)
		meter = chart.get_meter_at(L)
		
		_offset += R - L
		y_offset += %Grid.get_real_position(Vector2(0, (R - L) / (60.0 / tempo) * (meter[1] / meter[0]))).y
		
		L = R
		i += 1
	
	return y_offset


func grid_position_to_time(p: Vector2, factor_in_snap: bool = false) -> float:
	var tempo_data: Dictionary = chart.get_tempos_data()
	var i: int = 0
	var meter: Array = []
	var L: float = tempo_data.keys()[0]
	var R: float = 0.0
	var yL: float = time_to_y_position(L)
	var yR: float = 0.0
	var yC: float = yL
	var seconds_per_beat: float = 0.0
	var output: float = chart.offset
	
	while yL <= yC:
		if i + 1 >= tempo_data.keys().size():
			R = %Instrumental.stream.get_length()
		else:
			R = tempo_data.keys()[i + 1]
		
		meter = chart.get_meter_at(L)
		var tempo = tempo_data.get(L)
		seconds_per_beat = 60.0 / tempo
		yL = time_to_y_position(L)
		yR = time_to_y_position(R)
		yC = p.y * %Grid.grid_size.y * %Grid.zoom.y
		if factor_in_snap:
			yC *= meter[1] / chart_snap
		
		if (yC >= yL and yC < yR):
			output += (yC - yL) / (%Grid.grid_size.y * %Grid.zoom.y * (meter[1] / meter[0])) * seconds_per_beat
			return output
		else:
			output += R - L
		
		L = R
		i += 1
	
	return output

## Binary searches for both notes and events
func bsearch_left_range(value_set: Array, left_range: float) -> int:
	var length: int = value_set.size()
	if (length == 0):
		return -1
	if (value_set[length - 1][0] < left_range):
		return -1
	
	var low: int = 0
	var high: int = length - 1
	
	while (low <= high):
		var mid: int = low + ((high - low) / 2)
		
		if (value_set[mid][0] >= left_range):
			high = mid - 1
		else:
			low = mid + 1
	
	return high + 1


func bsearch_right_range(value_set: Array, right_range: float) -> int:
	var length: int = value_set.size()
	if (length == 0):
		return -1
	if (value_set[0][0] > right_range):
		return -1
	
	var low: int = 0
	var high: int = length - 1
	
	while (low <= high):
		@warning_ignore("integer_division")
		var mid: int = low + ((high - low) / 2)
		
		if value_set[mid][0] > right_range: high = mid - 1
		else: low = mid + 1
	
	return low - 1

## Binary searches for note nodes
func bsearch_left_range_note(value_set: Array, left_range: float) -> int:
	var length: int = value_set.size()
	if (length == 0):
		return -1
	if (value_set[length - 1].time < left_range):
		return -1
	
	var low: int = 0
	var high: int = length - 1
	
	while (low <= high):
		var mid: int = low + ((high - low) / 2)
		
		if (value_set[mid].time >= left_range):
			high = mid - 1
		else:
			low = mid + 1
	
	return high + 1

func is_note_at(lane: int, time: float) -> bool:
	return (find_note(lane, time) != -1)

func _on_play_button_toggled(toggled_on: bool) -> void:
	%Vocals.stream_paused = !toggled_on
	%Instrumental.stream_paused = !toggled_on
	
	if toggled_on:
		%"Play Button".icon = load("res://assets/sprites/menus/chart editor/pause_button.png")
		if song_position != %Instrumental.get_playback_position():
			play_audios(song_position)
	
	else: %"Play Button".icon = load("res://assets/sprites/menus/chart editor/play_button.png")

func move_bound_left(strum_id: int):
	var strum_data = ChartManager.strum_data[strum_id]
	strum_data["strums"][0] = clamp(strum_data["strums"][0] - 1, 0, ChartManager.strum_count - 1)
	
	for id in ChartManager.strum_data.size():
		if ChartManager.strum_data[id]["strums"][1] == strum_data["strums"][0]:
			ChartManager.strum_data[id]["strums"][1] = clamp(ChartManager.strum_data[id]["strums"][1] - 1, 0, ChartManager.strum_count - 1)
	
	update_grid()

func move_bound_right(strum_id: int):
	var strum_data = ChartManager.strum_data[strum_id]
	strum_data["strums"][1] = clamp(strum_data["strums"][1] + 1, 0, ChartManager.strum_count - 1)
	
	for id in ChartManager.strum_data.size():
		if ChartManager.strum_data[id]["strums"][0] ==  strum_data["strums"][1]:
			ChartManager.strum_data[id]["strums"][0] = clamp(ChartManager.strum_data[id]["strums"][0] + 1, 0, ChartManager.strum_count - 1)
	
	update_grid()

func find_strum_id(strum_name: String) -> int:
	for id in ChartManager.strum_data.size():
		var strum_data = ChartManager.strum_data[id]
		if strum_data["name"] == strum_name:
			return id
	return -1

func _on_song_slider_value_changed(value: float) -> void:
	song_position = value

func _on_skip_forward_pressed() -> void:
	song_position += 10
	_on_play_button_toggled(true)

func _on_skip_backward_pressed() -> void:
	song_position -= 10
	_on_play_button_toggled(true)

func _on_skip_to_beginning_pressed() -> void:
	song_position = start_offset
	_on_play_button_toggled(true)

func _on_skip_to_end_pressed() -> void:
	song_position = %Instrumental.stream.get_length() - 0.1
	_on_play_button_toggled(true)

func _on_instrumental_finished() -> void:
	_on_play_button_toggled(false)

func _on_conductor_new_beat(current_beat: int, measure_relative: int) -> void:
	if measure_relative == 0:
		%"Conductor Beat".play(0.55)
	else:
		%"Conductor Off Beat".play(0.55)
	
	if chart:
		load_section(song_position)
	
	%Debug.text = str("Beat: ", current_beat)

func _on_conductor_new_step(current_step: int, measure_relative: int) -> void:
	%"Conductor Step".play(0.55)

## File button item pressed
func file_button_item_pressed(id):
	var item_name: String = %"File Button".get_popup().get_item_text(id)
	if item_name == "Create New Song":
		can_chart = false
		var new_file_popup_instance = NEW_FILE_POPUP_PRELOAD.instantiate()
		
		add_child(new_file_popup_instance)
		new_file_popup_instance.popup()
		new_file_popup_instance.connect("file_created", self.new_file)
		new_file_popup_instance.connect("close_requested", self.close_popup)
		new_file_popup_instance.connect(&"gui_focus_changed", self._on_gui_focus_changed)
		%"Open Window".play()
	elif item_name == "Open Song":
		can_chart = false
		var open_file_popup_instance = OPEN_FILE_POPUP_PRELOAD.instantiate()
		
		add_child(open_file_popup_instance)
		open_file_popup_instance.popup()
		open_file_popup_instance.connect("file_selected", self.load_song_path)
		open_file_popup_instance.connect("close_requested", self.close_popup)
		open_file_popup_instance.connect("canceled", self.close_popup)
		open_file_popup_instance.connect(&"gui_focus_changed", self._on_gui_focus_changed)
		%"Open Window".play()
	elif id == 2:
		save()
	elif id == 7:
		can_chart = false
		
		var convert_chart_popup_instance = CONVERT_CHART_POPUP_PRELOAD.instantiate()
		
		add_child(convert_chart_popup_instance)
		convert_chart_popup_instance.popup()
		# convert_chart_popup_instance.connect("file_created", self._on_save_folder_dialog_dir_selected)
		convert_chart_popup_instance.connect("file_created", self.new_file)
		convert_chart_popup_instance.connect("close_requested", self.close_popup)
		convert_chart_popup_instance.connect(&"gui_focus_changed", self._on_gui_focus_changed)
		%"Open Window".play()
	elif id == 3:
		SettingsManager.set_value("chart", "auto_save", !SettingsManager.get_value("chart", "auto_save"))
		%"File Button".get_popup().set_item_checked(
			%"File Button".get_popup().get_item_index(id), SettingsManager.get_value("chart", "auto_save"))
		%"Note Place".play()
	elif id == 6:
		set_chart_from_chart(backup_chart)
		Global.change_scene_to("res://scenes/main menu/main_menu.tscn")
		can_chart = false
	elif id == 8:
		can_chart = false
		%"Export External Popup".popup()
		%"Open Window".play()

## Edit button item pressed
func edit_button_item_pressed(id):
	if id == 0:
		undo()
	elif id == 1:
		redo()

## Window button item pressed
func window_button_item_pressed(id):
	match id:
		0:
			%"History Window".popup()
			%"Window Button".get_popup().set_item_checked(id, true)
		1:
			%"Metadata Window".popup()
			%"Window Button".get_popup().set_item_checked(id, true)

func disable_charting():
	can_chart = false
func close_popup():
	can_chart = true
	%"Close Window".play()

func undo():
	if undo_redo.has_undo():
		%Undo.play()
		undo_redo.undo()
		if SettingsManager.get_value("chart", "auto_save"):
			save()
	
	%"Edit Button".get_popup().set_item_checked(0, !undo_redo.has_undo())

func redo():
	if undo_redo.has_redo():
		%Redo.play()
		undo_redo.redo()
		if SettingsManager.get_value("chart", "auto_save"):
			save()
	
	%"Edit Button".get_popup().set_item_checked(1, !undo_redo.has_redo())

func save():
	ResourceSaver.save(ChartManager.song, ChartManager.song.resource_path)
	ResourceSaver.save(chart, chart.resource_path)
	backup_chart = chart

func updated_strums():
	can_chart = true
	update_grid()

func load_waveforms():
	get_tree().call_group(&"waveforms", &"queue_free")
	return
	@warning_ignore("unreachable_code")
	if ChartManager.song:
		for id in ChartManager.strum_data.size():
			var track: int = ChartManager.strum_data[id]["track"]
			if track < ChartManager.song.vocals.size():
				for i in chart.get_tempos_data().size():
					var L: float = chart.get_tempos_data().keys()[i]
					var R: float
					if (i + 1) == chart.get_tempos_data().size():
						R = %Instrumental.stream.get_length()
					else:
						R = chart.get_tempos_data().keys()[i + 1]
					var waveform = WaveformRenderer.new()
					
					var stream = ChartManager.song.vocals[track]
					waveform.keepData = true
					waveform.width = time_to_y_position(R) - time_to_y_position(L)
					waveform.position = %Grid.get_real_position(Vector2(ChartManager.strum_data[id]["strums"][1] + 1.5, 0.5))
					waveform.position.y += time_to_y_position(L)
					waveform.duration = R - L
					
					$"Waveform Layer".add_child(waveform)
					waveform.setOrientation("VERTICAL")
					waveform.add_to_group(&"waveforms")
					waveform.create(stream, Color.MEDIUM_PURPLE, null, (R - L) * 130)
			else:
				printerr("(load_waveforms) Track ", track, " does not exist.")

func _on_chart_snap_value_changed(value: float) -> void:
	# This is really dumb and janky
	chart_snap = value

func _on_difficulty_button_item_selected(index: int) -> void:
	var option = %"Difficulty Button".get_popup().get_item_text(index)
	if ChartManager.song.difficulties.keys().has(option):
		chart = load(ChartManager.song.difficulties.get(option).get("chart"))
		load_chart(chart)

func _on_history_window_close_requested() -> void:
	%"Window Button".get_popup().set_item_checked(0, false)

func _on_metadata_window_close_requested() -> void:
	%"Window Button".get_popup().set_item_checked(1, false)

func _on_metadata_window_updated_icon_texture(path: String) -> void:
	ChartManager.song.icons = load(path)

func _on_metadata_window_updated_song_artist(text: String) -> void:
	ChartManager.song.artist = text

func _on_metadata_window_updated_song_name(text: String) -> void:
	ChartManager.song.title = text

func _on_metadata_window_updated_song_scene(path: String) -> void:
	ChartManager.song.scene = path

func _on_metadata_window_updated_starting_tempo(tempo: float) -> void:
	ChartManager.song.tempo = tempo

func update_note(note):
	if note:
		hovered_note = find_note(note.lane, note.time)
	else:
		hovered_note = -1

func _on_export_external_popup_file_selected(path: String) -> void:
	ResourceSaver.save(chart, path)
	%"Export External Popup".hide()

func _on_gui_focus_changed(node):
	current_focus_owner = node
	current_focus_viewport = node.get_viewport()

func set_chart_from_chart(_chart: Chart):
	if !_chart:
		return
	chart.chart_data = backup_chart.chart_data
	chart.scroll_speed = backup_chart.scroll_speed
	chart.offset = backup_chart.offset
