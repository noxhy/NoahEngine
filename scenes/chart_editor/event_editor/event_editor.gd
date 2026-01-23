extends ChartEditor


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super(delta)

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
	if ChartManager.chart.get_notes_data().is_empty():
		return
	
	var _range: float = $Conductor.seconds_per_beat * $Conductor.beats_per_measure * 2 / %Grid.zoom.y
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
