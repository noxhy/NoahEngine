extends Window

signal updated_song_name(text: String)
signal updated_song_artist(text: String)
signal updated_song_charter(text: String)
signal updated_starting_tempo(tempo: float)
signal updated_song_scene(path: String)
signal updated_scroll_speed(speed: float)
signal selected_time_change(time: float)
signal add_time_change
signal remove_time_change

var scroll_speed: float
var has_updated_scroll_speed: bool = false
var current_time_change: int = -1

func update_stats():
	%"Song Name".text = EditorResources.song.title
	%"Song Artist".text = EditorResources.song.artist
	%"Song Charter".text = EditorResources.song.charter
	
	_on_scene_file_dailog_file_selected(EditorResources.song.scene)
	
	%Difficulty.text = EditorResources.difficulty
	if has_updated_scroll_speed:
		%"Scroll Speed".value = EditorResources.chart.scroll_speed
	else:
		%"Scroll Speed".set_value_no_signal(EditorResources.chart.scroll_speed)
		%"Scroll Speed Label".text = str("Scroll Speed: ", EditorResources.chart.scroll_speed, "x")
	
	%"Time Changes".clear()
	var i: int = 0
	for time_change in EditorResources.song.time_changes:
		%"Time Changes".add_item(format_time_change(i))
		i += 1
	
	_on_time_changes_item_selected(0, false)

func _on_icon_button_pressed() -> void:
	%"Icon FileDailog".popup()

func _on_scene_file_dailog_file_selected(path: String) -> void:
	path = ResourceUID.path_to_uid(path)
	if !ResourceLoader.exists(path):
		printerr("Scene doesn't exist.")
		return
	
	%"Song Scene".text = path
	updated_song_scene.emit(path)

func _on_starting_tempo_value_changed(value: float) -> void:
	%"Tempo".value = value
	updated_starting_tempo.emit(value)

func _on_song_name_text_changed(new_text: String) -> void:
	updated_song_name.emit(new_text)

func _on_song_artist_text_changed(new_text: String) -> void:
	updated_song_artist.emit(new_text)

func _on_close_requested() -> void:
	self.visible = false
	gui_release_focus()

func _on_song_scene_button_pressed() -> void:
	%"Scene FileDailog".popup()

func file_dailog_gui_focus_changed(node: Control) -> void:
	emit_signal(&"gui_focus_changed", node)

func _on_scroll_speed_value_changed(value: float) -> void:
	%"Scroll Speed Label".text = str("Scroll Speed: ", value, "x")
	emit_signal(&"updated_scroll_speed", value)

func _on_time_changes_item_selected(index: int, emit: bool = true) -> void:
	%"Remove Time Change".disabled = (index == 0)
	current_time_change = index
	
	var time_changes: Dictionary[float, Vector3] = EditorResources.song.time_changes
	var time: float = time_changes.keys()[index]
	%Tempo.value = time_changes[time].x
	%Numerator.value = time_changes[time].y
	%Denominator.value = time_changes[time].z
	if emit:
		emit_signal(&"selected_time_change", time)

func _on_add_time_change_pressed() -> void:
	emit_signal(&"add_time_change")

func _on_remove_time_change_pressed() -> void:
	var tempo_data: Dictionary = EditorResources.chart.tempos
	var time: float = tempo_data.keys()[current_time_change]
	
	EditorResources.song.time_changes.erase(time)
	%"Time Changes".remove_item(current_time_change)
	%"Time Changes".select(current_time_change - 1)
	_on_time_changes_item_selected(current_time_change - 1)
	
	emit_signal(&"remove_time_change")

func _on_tempo_value_changed(value: float) -> void:
	var tempo_data: Dictionary = EditorResources.chart.tempos
	var time: float = tempo_data.keys()[current_time_change]
	
	EditorResources.song.tempo = tempo_data.get(0.0)
	EditorResources.chart.tempos[time] = value
	%"Time Changes".set_item_text(current_time_change, format_time_change(current_time_change))

func format_time_change(index: int) -> String:
	var time_changes: Dictionary[float, Vector3] = EditorResources.song.time_changes
	var time: float = time_changes.keys()[index]
	var time_change: Vector3 = time_changes[time]
	return str(NoahTools.format_time(time), " - BPM: ", time_change.x, " in ", time_change.y, "/", time_change.z)

func _on_numerator_value_changed(value: float) -> void:
	var tempo_data: Dictionary = EditorResources.chart.tempos
	var time: float = tempo_data.keys()[current_time_change]
	
	EditorResources.chart.time_signature_vectors[time] = Vector2i(int(value), int(%Denominator.value))
	%"Time Changes".set_item_text(current_time_change, format_time_change(current_time_change))

func _on_denominator_value_changed(value: float) -> void:
	var tempo_data: Dictionary = EditorResources.chart.tempos
	var time: float = tempo_data.keys()[current_time_change]
	
	EditorResources.chart.time_signature_vectors[time] = Vector2i(int(%Numerator.value), int(value))
	%"Time Changes".set_item_text(current_time_change, format_time_change(current_time_change))


func _on_song_charter_text_changed(new_text: String) -> void:
	updated_song_charter.emit(new_text)
