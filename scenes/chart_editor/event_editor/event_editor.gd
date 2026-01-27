extends ChartEditor

const TRACK_BUTTON = preload("res://scenes/chart_editor/event_editor/event_button.tscn")

var current_event_time: float
var current_event: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if start_offset < 0:
		start_offset = 0
	
	if ChartManager.song:
		if %Instrumental.playing:
			song_position = %Instrumental.get_playback_position() - start_offset
			%"Song Slider".value = song_position
			
			GameManager.seconds_per_beat = $Conductor.seconds_per_beat
			
			for strum in ChartManager.strum_data.size():
				var track = ChartManager.strum_data[strum]["track"]
				if track < vocal_tracks.size():
					if ChartManager.strum_data[strum]["muted"]:
						%Vocals.get_stream_playback().set_stream_volume(vocal_tracks[track], -80)
					else:
						%Vocals.get_stream_playback().set_stream_volume(vocal_tracks[track], 0)
		else:
			if Input.is_action_just_pressed(&"mouse_scroll_up"):
				if !Input.is_action_pressed(&"control"):
					if can_chart:
						song_position += $Conductor.seconds_per_beat
						song_position = snapped(song_position - $Conductor.offset, $Conductor.seconds_per_beat) + $Conductor.offset
						song_position = clamp(song_position, start_offset - ChartManager.chart.offset, %Instrumental.stream.get_length())
						%"Song Slider".value = song_position
				else:
					current_snap += 1
					chart_snap = SNAPS[current_snap % SNAPS.size()]
					%"Chart Snap".value = chart_snap
			
			if Input.is_action_just_pressed(&"mouse_scroll_down"):
				if !Input.is_action_pressed(&"control"):
					if can_chart:
						song_position -= $Conductor.seconds_per_beat
						song_position = snapped(song_position - $Conductor.offset, $Conductor.seconds_per_beat) + $Conductor.offset + ChartManager.chart.offset
						song_position = clamp(song_position, start_offset - ChartManager.chart.offset, %Instrumental.stream.get_length())
						%"Song Slider".value = song_position
				else:
					current_snap -= 1
					chart_snap = SNAPS[current_snap % SNAPS.size()]
					%"Chart Snap".value = chart_snap
			
			$Conductor.time = song_position
	
	if ChartManager.chart:
		$Conductor.tempo = ChartManager.chart.get_tempo_at(song_position + start_offset)
		var meter = ChartManager.chart.get_meter_at(song_position + start_offset)
		$Conductor.beats_per_measure = meter[0]
		$Conductor.steps_per_measure = meter[1]
		$Camera2D.position.x = 640 + time_to_y_position(song_position)
		$Conductor.offset = ChartManager.chart.get_tempo_time_at(song_position + start_offset) - ChartManager.chart.offset
		$"Grid Layer/Parallax2D".scroll_offset.x = time_to_y_position($Conductor.offset)
	
	%"Current Time Label".text = Global.float_to_time(song_position + start_offset)
	if song_speed != 1:
		%"Current Time Label".text += str(" (", song_speed, "x)")
	
	if ChartManager.song:
		%"Time Left Label".text = "-" + Global.float_to_time(%Instrumental.stream.get_length() - song_position)
	else:
		%"Time Left Label".text = "- ??:??"
	
	if Input.is_action_just_pressed(&"ui_accept"):
		_on_play_button_toggled(!%Instrumental.stream_paused)
	
	var grid_offset: Vector2 = %Grid.position + $"Grid Layer".offset# - $"Grid Layer/Parallax2D".scroll_offset
	var mouse_position: Vector2 = get_global_mouse_position() - grid_offset
	var grid_position: Vector2 = %Grid.get_grid_position(mouse_position)
	var snapped_position: Vector2i = Vector2i(
			%Grid.get_grid_position(mouse_position, %Grid.grid_size * Vector2($Conductor.steps_per_measure / chart_snap, 1))
			)
	
	$"Grid Layer/Parallax2D".repeat_size.x = %Grid.get_size().x
	
	var screen_mouse_position = get_global_mouse_position() - Vector2($Camera2D.position.x, 0)
	
	if Input.is_action_just_pressed(&"mouse_left"):
		if !Input.is_action_pressed(&"control"):
			if screen_mouse_position.x > -512 and screen_mouse_position.x < 640:
				if can_chart:
					if (((snapped_position.y - 1) >= 0 and (snapped_position.y - 1) < %Grid.rows)
					and !current_focus_owner):
						var event: String = ChartManager.event_tracks[snapped_position.y - 1]
						var time: float = grid_position_to_time(snapped_position, true)
						
						if time <= %Instrumental.stream.get_length():
							if !is_event_at(event, time):
								if ChartManager.EVENT_DATA.has(event):
									current_event = event
									current_event_time = time
									if ChartManager.EVENT_DATA.get(event).has("parameters"):
										%"Event Creator".popup()
									else:
										add_action("Placed Event", self.place_event.bind(time, event, [], true),
										self.remove_note.bind(event, time))
										%"Note Place".play()
							else:
								var i: int = find_event(event, time)
								if selected_notes.has(i):
									moving_notes = true
									start_time = time
								else:
									selected_notes = [i]
									selected_note_nodes = [event_nodes[i - current_visible_events_L]]
					elif (((grid_position.y - 1) >= -1 and (grid_position.y - 1) <= ChartManager.strum_count)
					and current_focus_owner):
						current_focus_viewport.gui_release_focus()
						current_focus_owner = null
		else:
			if can_chart:
				bounding_box = true
				start_box = get_global_mouse_position()
	
	if Input.is_action_pressed(&"mouse_right"):
		if !Input.is_action_pressed(&"control"):
				if screen_mouse_position.x > -512 and screen_mouse_position.x < 640 and !current_focus_owner:
					if can_chart:
						if !Input.is_action_pressed(&"control"):
							var time: float = grid_position_to_time(snapped_position, true)
							
							if hovered_event != -1:
								var i: int = hovered_event
								var event = ChartManager.chart.chart_data.events[i]
								var event_name: String = event[1]
								var parameters = event[2]
								
								add_action("Removed Event", self.remove_note.bind(i),
								self.place_event.bind(time, event_name, parameters, true))
								%"Note Remove".play()
								
								if selected_notes.has(i):
									var j: int = selected_notes.find(i)
									
									selected_notes.remove_at(j)
									selected_note_nodes.remove_at(j)
									
									if selected_notes.size() > 1:
										var k: int = 0
										for _i in range(selected_notes.size()):
											if k >= j:
												selected_notes[k] -= 1
											k += 1
								
								hovered_event = -1
								
								if SettingsManager.get_value(SettingsManager.SEC_CHART, "auto_save"):
									save()
	
	if Input.is_action_pressed(&"mouse_left"):
		if !Input.is_action_pressed(&"control"):
			if screen_mouse_position.x > -512 and screen_mouse_position.x < 640:
				if !%Instrumental.playing:
					if can_chart and !current_focus_owner:
						## Song Position Slider
						if grid_position.y < 1 and grid_position.y >= 0:
							if Input.is_action_pressed(&"shift"):
								start_offset = grid_position_to_time(snapped_position, true) - song_position
							else:
								start_offset = grid_position_to_time(grid_position) - song_position
						
						if ((grid_position.y - 1) > 0 and (grid_position.y - 1) < %Grid.rows):
							if moving_notes:
								var cursor_time = grid_position_to_time(snapped_position, true)
								
								var time_distance = cursor_time - start_time
								changed_length = true
								
								if true:
									if changed_length:
										var j: int = 0
										for i in selected_notes:
											var node = selected_note_nodes[j]
											var time: float = node.time
											
											node.position.x = time_to_y_position((node.time + time_distance)
											) + $"Grid Layer".offset.x + (%Grid.grid_size.x * %Grid.zoom.x / 2)
											j += 1
										
										if SettingsManager.get_value(SettingsManager.SEC_CHART, "auto_save"):
											save()
										
										moved_time_distance = time_distance
	
	if Input.is_action_just_released(&"mouse_left"):
		if bounding_box:
			bounding_box = false
			
			var rect = Rect2(start_box, get_global_mouse_position() - start_box).abs()
			# Added leniency since notes are centered from the top
			var pos_1: Vector2 = %Grid.get_grid_position(rect.position - grid_offset) - Vector2(0, 1)
			var pos_2: Vector2 = %Grid.get_grid_position(rect.end - grid_offset) - Vector2(0, 1)
			
			var time_a: float = grid_position_to_time(pos_1, true)
			var time_b: float = grid_position_to_time(pos_2, true)
			var lane_a: int = int(pos_1.y)
			var lane_b: int = int(pos_2.y)
			
			var events: Array = []
			
			for i in range(max(lane_a, 0), min(lane_b + 1, ChartManager.event_tracks.size())):
				events.append(ChartManager.event_tracks[i])
			
			var L: int = bsearch_left_range(ChartManager.chart.get_events_data(), time_a)
			var R: int = bsearch_right_range(ChartManager.chart.get_events_data(), time_b)
			
			if (L == R + 1):
				L -= 1
			L = max(0, L)
			add_action("Selected Area", self.select_area.bind(L, R, events), self.deselect_all)
		
		if moving_notes:
			add_action("Moved Events(s)", self.move_selection.bind(moved_time_distance, 0),
			self.move_selection.bind(-moved_time_distance, 0))
	
	if Input.is_action_just_released(&"control"):
		bounding_box = false
	
	queue_redraw()


func _draw() -> void:
	var rect: Rect2
	
	## Box when you're holding control
	if bounding_box:
		rect = Rect2(start_box, get_global_mouse_position() - start_box).abs()
		draw_rect(rect, box_color)
	
	if ChartManager.chart:
		## The offset the grid has from the normal canvas layer
		var grid_offset: Vector2 = %Grid.position + $"Grid Layer".offset
		var mouse_position: Vector2 = get_global_mouse_position() - grid_offset
		var grid_position: Vector2i = Vector2i(%Grid.get_grid_position(mouse_position))
		var snapped_position: Vector2i = Vector2i(
			%Grid.get_grid_position(mouse_position, %Grid.grid_size * Vector2($Conductor.steps_per_measure / chart_snap, 1))
			)
		
		## Song Start Offset Marker
		rect = Rect2(grid_offset +
		%Grid.get_real_position(Vector2(0, 0)) + Vector2(time_to_y_position(song_position - ChartManager.chart.offset + start_offset) - 2, 0), \
		%Grid.get_real_position(Vector2(0, %Grid.rows)) - %Grid.get_real_position(Vector2(0, 0)) + Vector2(4, 0))
		draw_rect(rect, current_time_color)
		
		# The box at the start of the marker
		rect = Rect2(grid_offset + %Grid.get_real_position(Vector2(0, 0)) + Vector2(time_to_y_position(song_position - ChartManager.chart.offset + start_offset) - 4, 0), \
		%Grid.get_real_position(Vector2(0, 1)) - %Grid.get_real_position(Vector2(0, 0)) + Vector2(8, 0))
		draw_rect(rect, current_time_color)
		
		## Hover Box
		if (grid_position.y >= 1 and grid_position.y < %Grid.rows and !current_focus_owner):
			rect = Rect2(%Grid.get_real_position(snapped_position, %Grid.grid_size * Vector2($Conductor.steps_per_measure / chart_snap, 1)) + grid_offset, \
			%Grid.grid_size * %Grid.zoom * Vector2($Conductor.steps_per_measure / chart_snap, 1))
			draw_rect(rect, hover_color)
		
		## Note Highlighting
		for i in selected_notes.size():
			var note = selected_note_nodes[i]
			if note:
					var length: float = ($Conductor.beats_per_measure * 1.0 / $Conductor.steps_per_measure)
					length *= %Grid.grid_size.x * %Grid.zoom.x
					length *= ($Conductor.steps_per_measure * 1.0 / $Conductor.beats_per_measure)
					rect = Rect2(note.global_position - (%Grid.grid_size / 2 * %Grid.zoom),
					Vector2(%Grid.grid_size.x * %Grid.zoom.x, length))
					draw_rect(rect, selected_color)
	
	if hovered_event != -1 and ChartManager.chart:
		var event: String = ChartManager.chart.get_events_data()[hovered_event][1]
		var parameters = ChartManager.chart.get_events_data()[hovered_event][2]
		var text: String =  ""
		if ChartManager.EVENT_DATA.has(event):
			var i: int = 0
			for parameter in parameters:
				text = str(ChartManager.EVENT_DATA[event]["parameters"][i], ": ", parameter)
				draw_string_outline(default_font, get_global_mouse_position() + Vector2(0, default_font_size * i), text,
				HORIZONTAL_ALIGNMENT_LEFT, -1, default_font_size, default_font_size / 2, Color.BLACK)
				draw_string(default_font, get_global_mouse_position() + Vector2(0, default_font_size * i), text,
				HORIZONTAL_ALIGNMENT_LEFT, -1, default_font_size)
				i += 1
		else:
			text = str(parameters)
			draw_string_outline(default_font, get_global_mouse_position(), text,
			HORIZONTAL_ALIGNMENT_LEFT, -1, default_font_size, default_font_size / 2, Color.BLACK)
			draw_string(default_font, get_global_mouse_position(), text,
			HORIZONTAL_ALIGNMENT_LEFT, -1, default_font_size)

## View button item pressed
func view_button_item_pressed(id):
	match id:
		0:
			ChartManager.event_editor = false
			get_tree().change_scene_to_file("res://scenes/chart_editor/chart_editor.tscn")
		
		1:
			can_chart = false
			%"Note Skin Window".popup()
			%"Open Window".play()
		
		3:
			%Grid.zoom = clamp(%Grid.zoom + Vector2.ONE * 0.1, Vector2.ONE * 0.5, Vector2.ONE * 1.5)
			update_grid()
			load_dividers()
			load_section(song_position)
		
		4:
			%Grid.zoom = clamp(%Grid.zoom - Vector2.ONE * 0.1, Vector2.ONE * 0.5, Vector2.ONE * 1.5)
			update_grid()
			load_dividers()
			load_section(song_position)
		
		_:
			print("id: ", id)


## Loads all the notes and waveforms for the next two waveforms.
func load_section(time: float):
	if ChartManager.chart.get_events_data().is_empty():
		return
	
	var _range: float = $Conductor.seconds_per_beat * $Conductor.beats_per_measure * 2.5 / %Grid.zoom.y
	var L: int = bsearch_left_range(ChartManager.chart.get_events_data(), time - _range)
	var R: int = bsearch_right_range(ChartManager.chart.get_events_data(), time + _range)
	
	if selected_notes.size() > 0:
		L = min(selected_notes[0], L)
		R = max(R, selected_notes[selected_notes.size() - 1])
	
	if L > -1 and R > -1:
		## Clearing any invisible notes
		if current_visible_events_L != L or current_visible_events_R != R:
			var i: int = 0
			for _i in range(event_nodes.size()):
				var event = event_nodes[i]
				if (event.time < ChartManager.chart.get_events_data()[L][0]
				or event.time > ChartManager.chart.get_events_data()[R][0]):
					event.queue_free()
					event_nodes.remove_at(i)
					i -= 1
				
				i += 1
		
		for i in range(L, R + 1):
			if i >= current_visible_events_L and i <= current_visible_events_R:
				update_note_position(event_nodes[i - L])
				continue
			
			var event = ChartManager.chart.get_events_data()[i]
			place_event(event[0], event[1], event[2], false, false, true, i - L)
		
		current_visible_events_L = L
		current_visible_events_R = R

## Adds an instance of a event on the chart editor, placed boolean adds it to the chart data.
func place_event(time: float, event: String, parameters: Array, placed: bool = false, moved: bool = false,
sorted: bool = false, sort_index: int = -1) -> int:
	var event_instance = EVENT_PRELOAD.instantiate()
	
	event_instance.time = time
	event_instance.event = event
	event_instance.parameters = parameters
	update_note_position(event_instance)
	
	var output: int
	
	if placed:
		var L: int = ChartManager.chart.get_events_data().bsearch_custom(time, self.bsearch_note)
		if L != -1:
			ChartManager.chart.chart_data["events"].insert(L, [time, event, parameters])
			
			if event_nodes.is_empty():
				event_nodes.append(event_instance)
			elif (L - current_visible_events_L) < 0:
				event_nodes.insert(0, event_instance)
			elif (L - current_visible_events_L) >= event_nodes.size():
				event_nodes.append(event_instance)
			else:
				event_nodes.insert((L - current_visible_events_L), event_instance)
			
			if !moved:
				selected_notes = [L]
				selected_note_nodes = [event_instance]
				min_lane = 0
				max_lane = ChartManager.strum_count - 1
			
			output = L
		else:
			event_nodes.append(event_instance)
			ChartManager.chart.chart_data["events"].append([time, event, parameters])
			selected_notes = [ChartManager.chart.get_events_data().size() - 1]
			selected_note_nodes = [event_instance]
			min_lane = 0
			max_lane = ChartManager.strum_count - 1
			output = event_nodes.size() - 1
	else:
		if sorted:
			var L: int = sort_index
			
			if event_nodes.is_empty():
				event_nodes.append(event_instance)
			elif L < 0:
				event_nodes.insert(0, event_instance)
			elif L >= event_nodes.size():
				event_nodes.append(event_instance)
			else:
				event_nodes.insert(L, event_instance)
		else:
			event_nodes.append(event_instance)
	
	$"Notes Layer".add_child(event_instance)
	event_instance.add_to_group(&"events")
	event_instance.area.connect(&"mouse_entered", self.update_event.bind(event_instance))
	event_instance.area.connect(&"mouse_exited", self.update_event.bind(null))
	return output


func update_note_position(node: Node2D):
	if node is ChartEvent:
		node.position = Vector2(time_to_y_position(node.time) + %Grid.grid_size.x * %Grid.zoom.x / 2,
		%Grid.get_real_position(Vector2(0, 1.5 + ChartManager.event_tracks.find(node.event))).y)
		node.position += $"Grid Layer".offset
		node.grid_size = (%Grid.grid_size * %Grid.zoom)
		node.update()
	else:
		printerr(node.get_class(), " isn't a valid node.")


func load_dividers():
	get_tree().call_group(&"dividers",  &"queue_free")
	for i in range($Conductor.beats_per_measure):
		var rect = ColorRect.new()
		var size: float = 4 if i == 0 else 2
		
		rect.color = divider_color
		rect.size = Vector2(size, %Grid.get_size().y)
		rect.position = %Grid.position
		rect.position.y -= %Grid.get_size().y / 2
		rect.position.x += (%Grid.grid_size.x * %Grid.zoom.x) * $Conductor.steps_per_measure / $Conductor.beats_per_measure * i
		rect.position.x -= rect.size.x / 2
		
		$"Grid Layer/Parallax2D".add_child(rect)
		rect.add_to_group(&"dividers")
	
	for i in [0, 1, %Grid.rows]:
		var rect = ColorRect.new()
		var size: float = 2
		
		rect.color = divider_color
		rect.size = Vector2(%Grid.get_size().x, size)
		rect.position = %Grid.position
		rect.position.y -= %Grid.get_size().y / 2
		rect.position.y += (%Grid.grid_size.y * %Grid.zoom.y)* i
		
		$"Grid Layer/Parallax2D".add_child(rect)
		rect.add_to_group(&"dividers")
	
	var times: Array = [%Instrumental.stream.get_length()]
	times.append_array(ChartManager.chart.get_tempos_data().keys())
	times.erase(0.0)
	for i in times:
		var rect = ColorRect.new()
		var size: float = 2
		
		rect.size = Vector2(size, %Grid.get_size().y)
		rect.position = %Grid.position
		rect.position.y -= %Grid.get_size().y / 2
		rect.position.x = time_to_y_position(i)
		rect.position.x -= rect.size.x / 2
		rect.position += %Grid.position + $"Grid Layer".offset
		rect.color = time_change_color
		
		self.add_child(rect)
		rect.add_to_group(&"dividers")

func load_chart(file: Chart, ghost: bool = false):
	super(file, ghost)
	ChartManager.event_tracks = []
	for event in file.get_events_data():
		if !ChartManager.event_tracks.has(event[1]):
			ChartManager.event_tracks.append(event[1])
	update_grid()
	_on_event_tracks_ready()

func update_grid():
	%Grid.columns = $Conductor.steps_per_measure
	%Grid.rows = 1 + ChartManager.event_tracks.size()
	
	$"UI/Event Tracks".position.y = -%Grid.get_size().y / 2 - 4
	$"UI/Event Tracks".size.y = 0
	$"UI/Event Tracks".custom_minimum_size.y = %Grid.get_size().y + (ChartManager.event_tracks.size() * 2)
	
	get_tree().call_group(&"tracks",  &"queue_free")
	for track in ChartManager.event_tracks:
		var track_instance = TRACK_BUTTON.instantiate()
		
		track_instance.event = track
		
		%"Event Tracks".add_child(track_instance)
		
		track_instance.add_to_group(&"tracks")
		track_instance.connect(&"removed", self.remove_track.bind(track_instance))
	
	await Engine.get_main_loop().process_frame
	$"UI/Event Tracks".size.y = %Grid.get_size().y + (ChartManager.event_tracks.size() * 2)


func remove_track(node):
	var event: String = node.event
	node.queue_free()
	
	ChartManager.event_tracks.erase(event)
	ChartManager.chart.chart_data["events"] = ChartManager.chart.chart_data["events"].filter(
		func(_event): return _event[1] != event
	)
	
	_on_event_tracks_ready()
	get_tree().call_group(&"events", &"queue_free")
	event_nodes = []
	selected_notes = []
	selected_note_nodes = []
	current_visible_events_L = -1
	current_visible_events_R = -1
	load_section(song_position)
	%"Mouse Click".play()


func _on_event_tracks_ready() -> void:
	if ChartManager.chart:
		await Engine.get_main_loop().process_frame
		update_grid()
		load_dividers()

## This assumes that the tempo and meter dictionaries are sorted
func time_to_y_position(time: float) -> float:
	var tempo_data: Dictionary = ChartManager.chart.get_tempos_data()
	var _offset: float = -ChartManager.chart.offset
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
		meter = ChartManager.chart.get_meter_at(L)
		
		_offset += R - L
		y_offset += %Grid.get_real_position(Vector2((R - L) / (60.0 / tempo) * (meter[1] / meter[0]), 0)).x
		
		L = R
		i += 1
	
	return y_offset

## This assumes that the tempo and meter dictionaries are sorted
func grid_position_to_time(p: Vector2, factor_in_snap: bool = false) -> float:
	var tempo_data: Dictionary = ChartManager.chart.get_tempos_data()
	var i: int = 0
	var meter: Array = []
	var L: float = tempo_data.keys()[0]
	var R: float = 0.0
	var yL: float = time_to_y_position(L)
	var yR: float = 0.0
	var yC: float = yL
	var seconds_per_beat: float = 0.0
	var output: float = ChartManager.chart.offset
	
	while yL <= yC:
		if i + 1 >= tempo_data.keys().size():
			R = %Instrumental.stream.get_length()
		else:
			R = tempo_data.keys()[i + 1]
		
		if L >= %Instrumental.stream.get_length():
			L = tempo_data.keys()[i - 1]
			R = INF
		
		meter = ChartManager.chart.get_meter_at(L)
		var tempo = tempo_data.get(L)
		seconds_per_beat = 60.0 / tempo
		yL = time_to_y_position(L)
		yR = time_to_y_position(R)
		yC = p.x * %Grid.grid_size.x * %Grid.zoom.x
		if factor_in_snap:
			yC *= meter[1] / chart_snap
		
		if (yC >= yL and yC < yR):
			output += (yC - yL) / (%Grid.grid_size.x * %Grid.zoom.x * (meter[1] / meter[0])) * seconds_per_beat
			return output
		else:
			output += R - L
		
		L = R
		i += 1
	
	return output

func is_event_at(_name: String, time: float) -> bool:
	return (find_event(_name, time) != -1)

## Returns the index of the given event in the events list.
func find_event(_name: String, time: float) -> int:
	var L: int = bsearch_left_range(ChartManager.chart.get_events_data(), time - 0.00001)
	var R: int = bsearch_right_range(ChartManager.chart.get_events_data(), time + 0.00001)
	
	if (L == -1 or R == -1):
		return -1
	
	# Just so I don't have to make a new return case because I'm lazy
	if (L == R + 1):
		L -= 1
	
	for i in range(L, R + 1):
		var event: Array = ChartManager.chart.get_events_data()[i]
		if (event[1] == _name):
			if is_equal_approx(event[0], time):
				return i
	
	return -1

## Giving only 1 parameter removes the note at the given index
func remove_note(_name, time: float = -1):
	var i: int
	if time != -1:
		i = find_event(_name, time)
	else:
		i = _name
	
	if i <= -1:
		return
	
	if (i - current_visible_events_L) < event_nodes.size() and (i - current_visible_events_L) >= 0:
		event_nodes[i - current_visible_events_L].queue_free()
		event_nodes.remove_at(i - current_visible_events_L)
	
	#if selected_notes.size() > 0:
		#for j in range(selected_notes.size()):
			#var note: int = selected_notes[j]
			#if note > i:
				#selected_notes[j] -= 1
	
	ChartManager.chart.chart_data["events"].remove_at(i)

## In the event editor, lane_a is a list of event names
func select_area(L: int, R: int, lane_a, lane_b = null):
	selected_notes = range(L, R + 1)
	selected_note_nodes = []
	
	var _i: int = 0
	for i in range(selected_notes.size()):
		var event: String = ChartManager.chart.get_events_data()[selected_notes[_i]][1]
		if !lane_a.has(event):
			selected_notes.remove_at(_i)
			_i -= 1
		
		_i += 1
	
	for i in selected_notes:
		selected_note_nodes.append(event_nodes[i - current_visible_events_L])
	
	if selected_notes.size() > 0:
		%"Note Place".play()

func move_selection(time_distance: float, lane_distance: float):
	var events: Array = []
	for event in selected_note_nodes:
		events.append([event.time + time_distance, event.event, event.parameters])
		remove_note(event.event, event.time)
	
	var temp = place_notes(events)
	selected_notes = temp
	selected_note_nodes = []
	for i in selected_notes:
		selected_note_nodes.append(event_nodes[i - current_visible_events_L])
	
	moving_notes = false
	%"Note Place".play()

# Returns the indexes of the new notes
func place_notes(events: Array) -> Array:
	var indices: Array = []
	for event in events:
		place_event(event[0], event[1], event[2], true)
	
	# Surely there's a cleaner way to do this
	for event in events:
		var i: int = find_event(event[1], event[0])
		if i != -1:
			indices.append(i)
	
	indices.sort()
	return indices

func remove_notes(events: Array):
	var i: int = 0
	for event in events:
		var _event = ChartManager.chart.get_events_data()[event - i]
		remove_note(_event[1], _event[0])
		i += 1


func cut() -> void:
	if selected_notes.size() > 0:
		var temp: Array = []
		for i in selected_notes:
			var event = ChartManager.chart.get_events_data()[i]
			temp.append([event[0], event[1], event[2]])
		
		add_action("Cut Note(s)", self.remove_notes.bind(selected_notes), self.place_notes.bind(temp))
		selected_notes = []
		%"Note Remove".play()


func copy() -> void:
	clipboard = []
	for note in selected_notes:
		clipboard.append(ChartManager.chart.get_events_data()[note])
	%"Note Place".play()


func paste() -> void:
	if clipboard.is_empty():
		return
	
	var temp = place_notes(clipboard)
	selected_notes = temp
	selected_note_nodes = []
	for i in selected_notes:
		selected_note_nodes.append(event_nodes[i - current_visible_events_L])
	%"Note Place".play()


func delete_stacked_notes() -> void:
	if ChartManager.chart.get_events_data().size() > 1:
		var i: int = 0
		var deleted: bool = false
		selected_notes = []
		selected_note_nodes = []
		for index in range(ChartManager.chart.get_events_data().size() - 1):
			var note_a = ChartManager.chart.get_events_data()[index - i]
			var note_b = ChartManager.chart.get_events_data()[index - i + 1]
			
			if (is_equal_approx(note_a[0], note_b[0]) and note_a[1] == note_b[1]):
				deleted = true
				remove_note(index - i)
				i += 1
			
			if deleted:
				%"Note Remove".play()


func select_all():
	selected_notes = range(current_visible_events_L, current_visible_events_R + 1)
	selected_note_nodes = get_tree().get_nodes_in_group(&"events")
	if selected_notes.size() > 0:
		%"Note Place".play()


func _on_event_parameters_about_to_popup() -> void:
	can_chart = false
	for node in %"Event Parameters".get_children():
		node.queue_free()
	
	var parameters: Array = ChartManager.EVENT_DATA[current_event]["parameters"]
	
	for parameter in parameters:
		var line_edit: LineEdit = LineEdit.new()
		
		line_edit.placeholder_text = parameter
		
		%"Event Parameters".add_child(line_edit)
	
	%"Open Window".play()


func _on_place_event_pressed() -> void:
	var parameters: Array = []
	for node in %"Event Parameters".get_children():
		parameters.append(node.text)
	
	add_action("Placed Event", self.place_event.bind(current_event_time, current_event, parameters, true),
	self.remove_note.bind(current_event, current_event_time))
	%"Note Place".play()
	%"Event Creator".hide()


func _on_add_track_pressed() -> void:
	%"Add Track Window".popup()
	%"Mouse Click".play()


func _on_window_about_to_popup() -> void:
	can_chart = false
	%"Event Option".clear()
	var events: Array = ChartManager.EVENT_DATA.keys()
	events = events.filter(func(_name): return !ChartManager.event_tracks.has(_name))
	
	print(events)
	
	for event in events:
		%"Event Option".add_item(event)


func _on_add_event_track_pressed() -> void:
	if %"Event Option".selected != -1:
		var event: String = %"Event Option".get_item_text(%"Event Option".get_selected_id())
		ChartManager.event_tracks.append(event)
		
		update_grid()
		load_dividers()
	
	%"Add Track Window".hide()
	close_popup()


func _on_add_track_window_close_requested() -> void:
	%"Add Track Window".hide()


func _on_export_external_popup_canceled() -> void:
	pass # Replace with function body.


func _on_note_skin_window_canceled() -> void:
	pass # Replace with function body.


func _on_note_type_window_selected_note_type(type: Variant) -> void:
	pass # Replace with function body.
