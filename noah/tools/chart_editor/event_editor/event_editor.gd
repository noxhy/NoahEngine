extends ChartEditor

var TRACK_BUTTON = load("uid://dguo6hi3l0pxv")

var current_event_time: float
var current_event: String
var editing: int = -1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	upper_ui.view_button.get_popup().set_item_disabled(1, true)

func update_camera_song_position(instant: bool = false):
	if instant:
		camera_2d.position.x = 640 + time_to_y_position(song_position)
	else:
		camera_2d.position.x = NoahTools.fps_lerp(
			camera_2d.position.x, 640 + time_to_y_position(song_position), 20, get_process_delta_time())

func is_mouse_over_grid() -> bool:
	var screen_mouse_pos = get_global_mouse_position() - Vector2(camera_2d.position.x, 0)
	return screen_mouse_pos.x > -512 and screen_mouse_pos.x < 640

## Loads all the notes and waveforms for the next two waveforms.
func load_section(time: float = song_position, reset: bool = true) -> void:
	if not EditorResources.chart or EditorResources.chart.notes.is_empty():
		return
	
	if reset:
		current_visible_events_L = -1
		current_visible_events_R = -1
	
	var _range: float = get_visible_time() * 1.5
	var L: int = NoahTools.bsearch_note_data_left_range(song_events, time - _range)
	var R: int = NoahTools.bsearch_note_data_right_range(song_events, time + _range)
	
	if selected_notes.size() > 0:
		L = min(selected_notes.front(), L)
		R = max(R, selected_notes.back())
	elif bounding_box:
		L = min(current_visible_events_L, L)
		R = max(R, current_visible_events_R)
	
	load_events(L, R)

func load_dividers() -> void:
	get_tree().call_group(&"dividers", &"queue_free")
	for i in range(conductor.numerator):
		var rect = ColorRect.new()
		var size: float = 4 if i == 0 else 2
		
		rect.color = divider_color
		rect.size = Vector2(size, grid.get_size().y)
		rect.position = grid.position
		rect.position.y -= grid.get_size().y / 2
		rect.position.x += (grid.grid_size.x * grid.zoom.x) * conductor.numerator * i
		rect.position.x -= rect.size.x / 2
		
		$"Grid Layer/Parallax2D".add_child(rect)
		rect.add_to_group(&"dividers")
	
	for i in [0, 1, maxi(grid.rows, 2)]:
		var rect = ColorRect.new()
		var size: float = 2
		
		rect.color = divider_color
		rect.size = Vector2(grid.get_size().x, size)
		rect.position = grid.position
		rect.position.y -= grid.get_size().y / 2
		rect.position.y += (grid.grid_size.y * grid.zoom.y) * i
		
		$"Grid Layer/Parallax2D".add_child(rect)
		rect.add_to_group(&"dividers")
	
	var times: Array = [music.stream.get_length()]
	times.append_array(EditorResources.song.time_changes.keys())
	times.erase(0.0)
	for i in times:
		var rect = ColorRect.new()
		var size: float = 2
		
		rect.size = Vector2(size, grid.get_size().y)
		rect.position = grid.position
		rect.position.y -= grid.get_size().y / 2
		rect.position.x = time_to_y_position(i)
		rect.position.x -= rect.size.x / 2
		rect.position += grid.position + $"Grid Layer".offset
		rect.color = time_change_color
		
		self.add_child(rect)
		rect.add_to_group(&"dividers")

func load_chart(file: Chart) -> void:
	super(file)
	EditorResources.event_tracks = []
	for event in song_events:
		if !EditorResources.event_tracks.has(event[1]):
			EditorResources.event_tracks.append(event[1])
		else:
			continue
	
	update_grid()
	_on_event_tracks_ready()

func update_grid() -> void:
	grid.columns = conductor.numerator * conductor.denominator
	grid.rows = 1 + EditorResources.event_tracks.size()
	
	$"UI/Event Tracks/Add Track".custom_maximum_size.y = grid.grid_size.y * grid.zoom.y
	
	$"UI/Event Tracks".position.y = -grid.get_size().y / 2.0
	$"UI/Event Tracks".size.y = 0
	
	get_tree().call_group(&"tracks",  &"queue_free")
	for track in EditorResources.event_tracks:
		var track_instance = TRACK_BUTTON.instantiate()
		
		track_instance.event = track
		track_instance.custom_maximum_size.y = grid.grid_size.y * grid.zoom.y
		
		%"Event Tracks".add_child(track_instance)
		
		track_instance.add_to_group(&"tracks")
		track_instance.connect(&"removed", self.remove_track.bind(track_instance))
	
	await Engine.get_main_loop().process_frame
	$"UI/Event Tracks".custom_minimum_size.y = grid.get_size().y

func update_waveforms(time: float = 0) -> void:
	var time_range: float = get_visible_time() * 1.2
	
	if waveform_nodes.is_empty() and (instrumental_waveforms or vocal_waveforms):
		load_waveforms()
	
	for id in waveform_nodes:
		var strumline: Strumline = EditorResources.strumlines[id]
		var waveform: AudioStreamVisualizer = waveform_nodes[id]
		
		if not waveform:
			return
		
		if id == -1:
			waveform.visible = instrumental_waveforms
		else:
			waveform.visible = vocal_waveforms
		
		if not waveform.visible:
			continue
		
		var L: float = max(time, 0)
		var i: int = conductor.get_time_change_index_at(L)
		var R_time: float = music.stream.get_sync_stream(0).get_length()
		if conductor.time_changes.keys().get(i + 1):
			R_time = conductor.time_changes.keys()[i + 1]
		
		var R: float = min(time + time_range, R_time)
		
		waveform.set_section(L, R - L)
		waveform.rotation_degrees = 90
		waveform.size.x = time_to_y_position(R) - time_to_y_position(L)
		if id == -1:
			waveform.position = grid.get_real_position(Vector2(1, 0))
			waveform.size.y = grid.grid_size.x * 1 * grid.zoom.x
		else:
			waveform.position = grid.get_real_position(Vector2(strumline.right_lane + 2, 0))
			waveform.size.y = grid.grid_size.x * strumline.lane_count * grid.zoom.x
		
		waveform.position.y += time_to_y_position(L)

func remove_track(node) -> void:
	var event: String = node.event
	node.queue_free()
	
	EditorResources.event_tracks.erase(event)
	song_events = song_events.filter(
		func(_event): return _event[1] != event
	)
	
	_on_event_tracks_ready()
	get_tree().call_group(&"events", &"queue_free")
	selected_notes = []
	current_visible_events_L = -1
	current_visible_events_R = -1
	load_section(song_position)
	SoundManager.tool_mouse_click.play()
	
	if minimap:
		minimap.refresh(EditorResources.chart.notes, song_events)


func _on_event_tracks_ready() -> void:
	if EditorResources.chart:
		await Engine.get_main_loop().process_frame
		update_grid()
		load_dividers()

## This assumes that the tempo and meter dictionaries are sorted
func grid_position_to_time(p: Vector2, factor_in_snap: bool = false) -> float:
	var time_change: Vector3 = conductor.get_time_change_at(song_position + start_offset)
	var yR: float = p.x
	if factor_in_snap:
		yR *= time_change.y * time_change.z / chart_snap
	
	var spb: float = (60.0 / time_change.x) * (4.0 / time_change.z)
	return yR * (spb / time_change.z)

## This assumes that the tempo and meter dictionaries are sorted
func time_to_y_position(time: float) -> float:
	var tempo_data: Dictionary[float, Vector3] = conductor.time_changes
	var _offset: float = 0# -EditorResources.chart.offset
	var y_offset: float = 0
	
	var i: int = 0
	
	var L: float = tempo_data.keys()[0]
	var R: float = tempo_data.keys()[0]
	
	var tempo: float = 60.0
	var time_calc: Callable = func(t, bpm, d) -> float:
		var spb: float = (60.0 / bpm) * (4.0 / d)
		return t / spb
	
	while R < time:
		if i + 1 >= tempo_data.size():
			R = time
		else:
			R = tempo_data.keys()[i + 1]
		
		if R > time:
			R = time
		
		tempo = tempo_data[L].x
		
		_offset += R - L
		y_offset += grid.get_real_position(
			Vector2(time_calc.call(R - L, tempo, tempo_data[L].z) * tempo_data[L].z, 0)).x
		
		L = R
		i += 1
	
	return y_offset

func is_event_at(_name: String, time: float) -> bool:
	return (find_event(_name, time) != -1)

## Returns the index of the given event in the events list.
func find_event(_name: String, time: float) -> int:
	var L: int = NoahTools.bsearch_note_data_left_range(song_events, time - EPSILON)
	var R: int = NoahTools.bsearch_note_data_right_range(song_events, time + EPSILON)
	
	if (L == -1 or R == -1):
		return -1
	
	# Just so I don't have to make a new return case because I'm lazy
	if (L == R + 1):
		L -= 1
	
	for i in range(L, R + 1):
		var event: Array = song_events[i]
		if (event[1] == _name):
			if is_equal_approx(event[0], time):
				return i
	
	return -1

## Giving only 1 parameter removes the note at the given index
func remove_note(_name, time: float = -1) -> void:
	var i: int
	if time != -1:
		i = find_event(_name, time)
	else:
		i = _name
	
	if i <= -1:
		return
	
	var ev: Array = song_events.get(i)
	if minimap and ev:
		if find_events_within_time(ev[0], conductor.seconds_per_step).size() <= 1: # TODO this still removes events in cases it shouldnt maybe make a custom epsilon or just refresh the entire texture
			minimap.unmap_event_from_image(ev[0])
	
	song_events.remove_at(i)


## In the event editor, lane_a is a list of event names
func select_area(L: int, R: int, lane_a: int, lane_b: int) -> void:
	selected_notes = range(L, R + 1).filter(func(i):
		var lane: int = NoahTools.array_get(song_events[i], 3, 0)
		return (lane >= lane_a and lane <= lane_b))
	
	if selected_notes.size() > 0:
		SoundManager.tool_mouse_click.play()


func move_selection(time_distance: float, lane_distance: float) -> void:
	moving_notes = false
	var events: Array = []
	var offset: int = 0
	for i in selected_notes:
		events.insert(0, song_events.pop_at(i - offset))
		offset += 1
	
	for packet in events:
		packet[0] += time_distance
		packet[3] = NoahTools.array_get(packet, 3, 0) + lane_distance
		place_event(packet[0], packet[1], packet[2], packet[3], true)
	
	selected_notes = []
	for packet in events:
		var i: int = find_note(packet[1], packet[0], packet[3])
		if i != -1:
			selected_notes.append(i)
	
	selected_notes.sort()
	SoundManager.tool_note_place.play()


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


func remove_notes(events: Array) -> void:
	var i: int = 0
	for event in events:
		var _event = song_events[event - i]
		remove_note(_event[1], _event[0])
		i += 1


func cut() -> void:
	if selected_notes.size() > 0:
		undo_redo.create_action("Cut Event(s)")
		var temp: Array = []
		for i in selected_notes:
			var event = song_events[i]
			temp.append([event[0], event[1], event[2]])
		
		undo_redo.add_do_method(remove_notes.bind(selected_notes))
		undo_redo.add_do_property(self, &"clipboard", temp)
		undo_redo.add_do_property(self, &"selected_notes", [])
		undo_redo.add_do_method(SoundManager.tool_note_remove.play)
		undo_redo.add_undo_method(place_notes.bind(temp))
		undo_redo.add_undo_property(self, &"clipboard", clipboard)
		undo_redo.add_undo_property(self, &"selected_notes", selected_notes)
		undo_redo.commit_action()


func delete() -> void:
	if selected_notes.size() > 0:
		undo_redo.create_action("Delete Event(s)")
		var temp: Array = []
		for i in selected_notes:
			var event = song_events[i]
			temp.append([event[0], event[1], event[2]])
		
		undo_redo.add_do_method(remove_notes.bind(selected_notes))
		undo_redo.add_do_property(self, &"selected_notes", [])
		undo_redo.add_do_method(SoundManager.tool_note_remove.play)
		undo_redo.add_undo_method(place_notes.bind(temp))
		undo_redo.add_undo_property(self, &"selected_notes", selected_notes)
		undo_redo.commit_action()


func copy() -> void:
	clipboard = []
	for note in selected_notes:
		clipboard.append(song_events[note])
	
	SoundManager.tool_note_place.play()


func delete_stacked_notes() -> void:
	if song_events.size() > 1:
		var i: int = 0
		var deleted: bool = false
		selected_notes = []
		for index in range(song_events.size() - 1):
			var note_a = song_events[index - i]
			var note_b = song_events[index - i + 1]
			
			if (is_equal_approx(note_a[0], note_b[0]) and note_a[1] == note_b[1]):
				deleted = true
				remove_note(index - i)
				i += 1
			
			if deleted:
				SoundManager.tool_note_remove.play()


func select_all() -> void:
	selected_notes = range(song_events.size())
	if selected_notes.size() > 0:
		SoundManager.tool_note_place.play()


func _on_event_parameters_about_to_popup() -> void:
	can_chart = false
	for node in %"Event Parameters".get_children():
		node.queue_free()
	
	var parameters: Array = []
	
	if hovered_event != -1:
		parameters = song_events[hovered_event][2]
		%"Place Event".text = "Edit Event"
	else:
		%"Place Event".text = "Place Event"
	
	update_desc(Constants.EVENT_DATA[current_event].get("description", ""))
	
	%"Event Name".text = current_event.capitalize()
	var parameter_names: Array = Constants.EVENT_DATA[current_event]["parameters"]
	
	var i: int = 0
	for _name in parameter_names:
		var line_edit: LineEdit = LineEdit.new()
		
		line_edit.placeholder_text = _name
		if (i < parameters.size()):
			line_edit.text = str(parameters[i])
		
		%"Event Parameters".add_child(line_edit)
		i += 1
	
	SoundManager.tool_open_window.play()


func _on_place_event_pressed() -> void:
	var parameters: Array = []
	for node in %"Event Parameters".get_children():
		parameters.append(node.text)
	
	if editing == -1:
		add_action("Placed Event", self.place_event.bind(current_event_time, current_event, parameters, true),
		self.remove_note.bind(current_event, current_event_time))
		SoundManager.tool_note_place.play()
		%"Event Creator".hide()
		if minimap:
			minimap.map_event_to_image(current_event_time)
	else:
		var action: String = "Edit Event"
		undo_redo.create_action(action)
		undo_redo.add_do_method(self.change_parameters.bind(editing, parameters))
		undo_redo.add_do_reference(%"Upper UI".get_node("%History Window").add_action(action))
		undo_redo.commit_action()
		SoundManager.tool_note_place.play()
		%"Event Creator".hide()
	
	auto_save()


func change_parameters(i: int, parameters: Array) -> void:
	song_events[i][2] = parameters


func _on_add_track_pressed() -> void:
	%"Add Track Window".popup()
	SoundManager.tool_open_window.play()

func _on_window_about_to_popup() -> void:
	can_chart = false
	var events: Array = Constants.EVENT_DATA.keys()
	events = events.filter(func(_name): return !EditorResources.event_tracks.has(_name))
	
	%add_event_tree.clear()
	%add_event_tree.create_item()
	
	for event in events:
		var item: TreeItem = %add_event_tree.create_item()
		item.set_text(0, event)
		var desc = Constants.EVENT_DATA.get(event,{}).get("description", "")
		if not desc.is_empty():
			item.set_tooltip_text(0, desc)
		
		var icon: String = Constants.EVENT_DATA.get(event, {}).get("texture", "res://addons/at-icons/node/help.svg")
		if ResourceLoader.exists(icon):
			item.set_icon(0, load(icon))
			item.set_icon_max_width(0, 16)

func update_desc(_str: String) -> void:
	%"Desc Label".text = _str
	
	#%"Desc Label".visible = !_str.is_empty()
	#%"Event Desc Label".visible = !_str.is_empty()

func _on_add_track_window_close_requested() -> void:
	%"Add Track Window".hide()


func _on_export_external_popup_canceled() -> void:
	pass # Replace with function body.


func _on_note_skin_window_canceled() -> void:
	pass # Replace with function body.


func _on_note_type_window_selected_note_type(type: Variant) -> void:
	pass # Replace with function body.


#func update_waveforms(time: float = 0) -> void:
	#var time_range: float = conductor.numerator * conductor.seconds_per_beat * 2 / grid.zoom.x
	#
	#if (waveform_nodes.is_empty() or waveform_dirty) and (instrumental_waveforms or vocal_waveforms):
		#load_waveforms()
		#waveform_dirty = false
	#
	#for id in waveform_nodes:
		#var waveform = waveform_nodes.get(id)
		#
		#if not waveform:
			#return
		#
		#if id == -1:
			#waveform.visible = instrumental_waveforms
		#else:
			#waveform.visible = vocal_waveforms
		#
		#if not waveform.visible:
			#continue
		#
		#var L: float = max(time, 0)
		#var R: float = min(time + time_range, music.stream.get_length())
		#waveform.time = L
		#waveform.duration = R - L
		#
		#waveform.position = grid.get_real_position(Vector2(0, 0))
		#waveform.size.x = time_to_y_position(R) - time_to_y_position(L)
		#waveform.size.y = grid.grid_size.y * 1 * grid.zoom.y
		#
		#waveform.position.x += time_to_y_position(L)


func get_corrected_mouse_position() -> Vector2:
	return get_global_mouse_position() - Vector2(camera_2d.position.x - 640, camera_2d.position.y - 360)


func brush_note_type() -> void:
	return


func _on_event_option_item_selected(index: int) -> void:
	var event: String = %"Event Option".get_item_text(%"Event Option".get_selected_id())
	var desc = Constants.EVENT_DATA[event].get('description', "")
	update_desc(desc)


func is_mouse_over_any_ui() -> bool:
	var ret = super()
	
	var mouse = get_corrected_mouse_position()
	
	for button in %"Event Tracks".get_children():
		if Rect2i(button.get_screen_position(), button.size).has_point(mouse):
			return true
	
	return ret

# add a event track now
func tree_event_activated() -> void:
	var item: TreeItem = %add_event_tree.get_selected()
	EditorResources.event_tracks.append(item.get_text(0))
	
	update_grid()
	load_dividers()
	
	%"Add Track Window".hide()
	close_popup()
	load_section(song_position, true)

func _on_viewport_size_changed() -> void:
	var width: float = clamp(get_window().size.y, MINIMUM_WINDOW_SIZE.y, 1280)
	
	grid.grid_size = Vector2(10, 24) * (MINIMUM_WINDOW_SIZE.y / width)
	$"Grid Layer/Parallax2D".repeat_times = ceili(MINIMUM_PARALLAX_REPEAT * (width / MINIMUM_WINDOW_SIZE.y))
	update_grid()
	load_dividers()
	note_renderer.update_render_transforms()
	event_renderer.update_render_transforms()
	update_camera_song_position(true)
