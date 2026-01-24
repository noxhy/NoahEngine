extends ChartEditor


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
						song_position -= $Conductor.seconds_per_beat
						song_position = snapped(song_position - $Conductor.offset, $Conductor.seconds_per_beat) + $Conductor.offset + ChartManager.chart.offset
						song_position = clamp(song_position, start_offset - ChartManager.chart.offset, %Instrumental.stream.get_length())
						%"Song Slider".value = song_position
				else:
					current_snap += 1
					chart_snap = SNAPS[current_snap % SNAPS.size()]
					%"Chart Snap".value = chart_snap
			
			if Input.is_action_just_pressed(&"mouse_scroll_down"):
				if !Input.is_action_pressed(&"control"):
					if can_chart:
						song_position += $Conductor.seconds_per_beat
						song_position = snapped(song_position - $Conductor.offset, $Conductor.seconds_per_beat) + $Conductor.offset
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
	var snapped_position: Vector2i = Vector2i(%Grid.get_grid_position(mouse_position, %Grid.grid_size * Vector2($Conductor.steps_per_measure / chart_snap, 1)))
	
	$"Grid Layer/Parallax2D".repeat_size.x = %Grid.get_size().x
	
	var screen_mouse_position = get_global_mouse_position() - Vector2($Camera2D.position.x, 0)
	
	if Input.is_action_just_pressed(&"mouse_left"):
		if !Input.is_action_pressed(&"control"):
			if screen_mouse_position.x > -512 and screen_mouse_position.x < 640:
				if can_chart:
					if (((grid_position.y - 1) >= 0 and (grid_position.y - 1) <= %Grid.rows)
					and !current_focus_owner):
						var lane: int = snapped_position.x - 1
						var time: float = grid_position_to_time(snapped_position, true)
						
						if time <= %Instrumental.stream.get_length():
							if !is_note_at(lane, time):
								add_action("Placed Note", self.place_note.bind(time, lane, 0, current_note_type, true),
								self.remove_note.bind(lane, time))
								
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
										var note = ChartManager.chart.get_notes_data()[j]
										min_lane = min(min_lane, note[1])
										max_lane = max(max_lane, note[1])
									
									min_lane = 0 + (start_lane - min_lane)
									max_lane = ChartManager.strum_count - 1 - (max_lane - start_lane)
								else:
									var index: int = find_note(lane, time)
									selected_notes = [index]
									selected_note_nodes = [note_nodes[index - current_visible_notes_L]]
									min_lane = 0
									max_lane = ChartManager.strum_count - 1
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
						if !Input.is_action_pressed("control"):
							var lane: int = snapped_position.x - 1
							var time: float = grid_position_to_time(snapped_position, true)
							
							if hovered_note != -1:
								var i: int = hovered_note
								var note = ChartManager.chart.chart_data.notes[i]
								var length: float = note[2]
								var note_type = note[3]
								
								add_action("Removed Note", self.remove_note.bind(i),
								self.place_note.bind(time, lane, length, note_type, true))
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
								
								hovered_note = -1
								
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
								start_offset = grid_position_to_time(snapped_position) - song_position
							else:
								start_offset = grid_position_to_time(grid_position) - song_position
						elif ((grid_position.y - 1) > 0 and (grid_position.y - 1) < ChartManager.strum_count):
							if placing_note:
								var cursor_time = grid_position_to_time(snapped_position, true)
								for i in selected_notes:
									var note: Array = ChartManager.chart.get_notes_data()[i]
									
									var time: float = note[0]
									var lane: int = note[1]
									var note_type = note[3]
									
									var distance = snappedf(clamp(cursor_time - time, 0.0, 16.0) / $Conductor.seconds_per_beat, 1.0 / chart_snap)
									ChartManager.chart.chart_data.notes[i] = [time, lane, distance, note_type]
									
									changed_length = (distance > 0)
									if changed_length:
										if (note_nodes[i - current_visible_notes_L].length != distance): %"Note Stretch".play()
										note_nodes[i - current_visible_notes_L].length = distance
									
									if SettingsManager.get_value(SettingsManager.SEC_CHART, "auto_save"): 
										save()
						
						if ((grid_position.y - 1) > 0 and (grid_position.y - 1) < ChartManager.strum_count):
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
										
										if SettingsManager.get_value(SettingsManager.SEC_CHART, "auto_save"):
											save()
										
										moved_time_distance = time_distance
										moved_lane_distance = lane_distance
										# start_time += time_distance
										# start_lane += lane_distance
										# min_lane = 0 + (start_lane - min_lane)
										# max_lane = ChartManager.strum_count - 1 - (max_lane - start_lane)
	
	if Input.is_action_just_released(&"mouse_left"):
		if placing_note:
			if changed_length:
				var action: String = "Changed Note Length(s)"
				undo_redo.create_action(action)
				for i in selected_notes:
					undo_redo.add_do_property(note_nodes[i - current_visible_notes_L],
					"length", note_nodes[i - current_visible_notes_L].length)
					undo_redo.add_do_method(self.change_length.bind(i, note_nodes[i - current_visible_notes_L].length))
					undo_redo.add_undo_property(note_nodes[i - current_visible_notes_L],
					"length", 0.0)
					undo_redo.add_undo_method(self.change_length.bind(i, 0))
				
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
			var lane_a: int = int(pos_1.x)
			var lane_b: int = int(pos_2.x)
			
			if lane_b < lane_a:
				var temp: int = lane_a
				lane_a = lane_b
				lane_b = temp
			
			var L: int = bsearch_left_range(ChartManager.chart.get_notes_data(), time_a)
			var R: int = bsearch_right_range(ChartManager.chart.get_notes_data(), time_b)
			
			if (L == R + 1):
				L -= 1
			L = max(0, L)
			add_action("Selected Area", self.select_area.bind(L, R, lane_a, lane_b), self.deselect_all)
		
		if moving_notes:
			add_action("Moved Note(s)", self.move_selection.bind(moved_time_distance, moved_lane_distance),
			self.move_selection.bind(-moved_time_distance, -moved_lane_distance))
	
	if Input.is_action_just_released(&"control"):
		bounding_box = false
	
	if Input.is_action_pressed(&"ui_cut"):
		if can_chart:
			cut()
	
	# Postponed
	if Input.is_action_just_pressed(&"ui_copy"):
		copy()
	
	if Input.is_action_just_pressed(&"ui_paste"):
		paste()
	
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
			%Grid.get_grid_position(mouse_position, %Grid.grid_size * Vector2($Conductor.steps_per_measure / chart_snap, 1)))
		
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
		if (grid_position.y >= 1 and grid_position.y <= %Grid.rows and !current_focus_owner):
			rect = Rect2(%Grid.get_real_position(snapped_position, %Grid.grid_size * Vector2($Conductor.steps_per_measure / chart_snap, 1)) + grid_offset, \
			%Grid.grid_size * %Grid.zoom * Vector2($Conductor.steps_per_measure / chart_snap, 1))
			draw_rect(rect, hover_color)
		
		## Note Highlighting
		for i in selected_notes.size():
			var note = selected_note_nodes[i]
			if note:
					var length: float = note.length + ($Conductor.beats_per_measure * 1.0 / $Conductor.steps_per_measure)
					length *= %Grid.grid_size.y * %Grid.zoom.y
					length *= ($Conductor.steps_per_measure * 1.0 / $Conductor.beats_per_measure)
					rect = Rect2(note.global_position - (%Grid.grid_size / 2 * %Grid.zoom),
					Vector2(%Grid.grid_size.x * %Grid.zoom.x, length))
					draw_rect(rect, selected_color)
	
	if hovered_event != -1 and ChartManager.chart:
		var event = ChartManager.chart.get_events_data()[hovered_note][1]
		var parameters = ChartManager.chart.get_events_data()[hovered_note][2]
		var text: String = str("\"", event, "\":  ", ", ".join(PackedStringArray(parameters)))
		draw_string_outline(default_font, get_global_mouse_position(), text,
		HORIZONTAL_ALIGNMENT_LEFT, -1, default_font_size, default_font_size / 2, Color.BLACK)
		draw_string(default_font, get_global_mouse_position(), text,
		HORIZONTAL_ALIGNMENT_LEFT, -1, default_font_size)

## View button item pressed
func view_button_item_pressed(id):
	match id:
		0:
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
	
	var _range: float = $Conductor.seconds_per_beat * $Conductor.beats_per_measure * 4 / %Grid.zoom.y
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
	event_instance.position = Vector2(time_to_y_position(time) + %Grid.grid_size.x * %Grid.zoom.x / 2,
	%Grid.get_real_position(Vector2(0, 0.5 + 1)).y)
	event_instance.position += $"Grid Layer".offset
	event_instance.grid_size = (%Grid.grid_size * %Grid.zoom)
	
	var output: int
	
	if placed:
		var L: int = bsearch_left_range(ChartManager.chart.get_events_data(), time)
		if L != -1:
			ChartManager.chart.chart_data["events"].insert(L, [time, event, parameters])
			event_nodes.insert(L - current_visible_notes_L, event_instance)
			
			if !moved:
				selected_notes = [L]
				selected_note_nodes = [event_instance]
				min_lane = 0
				max_lane = ChartManager.strum_count - 1
			
			output = L
		else:
			event_nodes.append(event_instance)
			ChartManager.chart.chart_data["events"].append([time, event, parameters])
			selected_notes = [ChartManager.chart.get_notes_data().size() - 1]
			selected_note_nodes = [event_instance]
			min_lane = 0
			max_lane = ChartManager.strum_count - 1
			output = event_nodes.size() - 1
	else:
		if sorted:
			var L: int = sort_index
			
			if note_nodes.is_empty():
				event_nodes.append(event_instance)
			elif L < 0:
				event_nodes.insert(0, event_instance)
			elif L >= note_nodes.size():
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


func load_dividers():
	get_tree().call_group(&"dividers",  &"queue_free")
	for i in range($Conductor.beats_per_measure):
		var rect = ColorRect.new()
		var size: float = 4 if i == 0 else 2
		
		rect.size = Vector2(size, %Grid.get_size().y)
		rect.position = %Grid.position
		rect.position.y -= %Grid.get_size().y / 2
		rect.position.x += (%Grid.grid_size.x * %Grid.zoom.x) * $Conductor.steps_per_measure / $Conductor.beats_per_measure * i
		rect.position.x -= rect.size.x / 2
		
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


func update_grid():
	%Grid.columns = $Conductor.steps_per_measure
	%Grid.rows = 4
	
	$"UI/Event Tracks".position.y = -%Grid.get_size().y / 2
	$"UI/Event Tracks".size.y = %Grid.get_size().y
