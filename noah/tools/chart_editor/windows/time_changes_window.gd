extends Window

signal selected_time_change(time: float)
signal add_time_change
signal remove_time_change

var current_time_change: int = -1

func update_stats() -> void:
	%"Time Changes".clear()
	var i: int = 0
	for time_change in EditorResources.song.time_changes:
		%"Time Changes".add_item(format_time_change(i))
		i += 1
	
	_on_time_changes_item_selected(0, false)

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
	SoundManager.tool_note_place.play()
	emit_signal(&"add_time_change")

func _on_remove_time_change_pressed() -> void:
	var time_changes: Dictionary = EditorResources.song.time_changes
	var time: float = time_changes.keys()[current_time_change]
	
	EditorResources.song.time_changes.erase(time)
	%"Time Changes".remove_item(current_time_change)
	%"Time Changes".select(current_time_change - 1)
	_on_time_changes_item_selected(current_time_change - 1)
	
	emit_signal(&"remove_time_change")

## Formats the time changes into a readable format
func format_time_change(index: int) -> String:
	var time_changes: Dictionary[float, Vector3] = EditorResources.song.time_changes
	var time: float = time_changes.keys()[index]
	var time_change: Vector3 = time_changes[time]
	return str(NoahTools.format_time(time), " - BPM: ", time_change.x, " in ", int(time_change.y), "/", int(time_change.z))

func _on_tempo_value_changed(value: float) -> void:
	var time: float = EditorResources.song.time_changes.keys()[current_time_change]
	
	EditorResources.song.time_changes[time].x = value
	%"Time Changes".set_item_text(current_time_change, format_time_change(current_time_change))

func _on_numerator_value_changed(value: float) -> void:
	var time: float = EditorResources.song.time_changes.keys()[current_time_change]
	
	EditorResources.song.time_changes[time].y = value
	%"Time Changes".set_item_text(current_time_change, format_time_change(current_time_change))

func _on_denominator_value_changed(value: float) -> void:
	var time: float = EditorResources.song.time_changes.keys()[current_time_change]
	
	EditorResources.song.time_changes[time].z = value
	%"Time Changes".set_item_text(current_time_change, format_time_change(current_time_change))
