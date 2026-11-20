extends PanelContainer

signal remove_requested

@export var strum_id: int = -1

@onready var id_label: Label = %"ID Label"
@onready var delete_track: Button = %"Delete Track"
@onready var load_song_button: Button = %"Load Song Button"
@onready var vol_slider: VSlider = %"vol Slider"
@onready var hit_sound_box: CheckBox = %"hit sound box"
@onready var file_dialog: FileDialog = $FileDialog

var original_path: String = ''
var path: String = ''
var parent: Node

var first_load: bool = true

var dirty: bool :
	set(v):
		dirty = v
		if dirty:
			self_modulate = Color(1.0, 0.5, 0.5)
		else:
			self_modulate = Color.WHITE

func set_id(id: int):
	if id == -1:
		id_label.text = 'Inst'
	else:
		if EditorResources.song and EditorResources.strumlines.size() > id:
			id_label.text = EditorResources.strumlines[id].name
		else:
			id_label.text = str(id)
		
		id_label.tooltip_text = "ID: " + id_label.text
	strum_id = id

func set_path(_path: String) -> void:
	if _path.begins_with("uid"):
		_path = ResourceUID.uid_to_path(_path)
	
	path = _path
	load_song_button.tooltip_text = path
	
	if first_load:
		original_path = path
		first_load = false

func _on_vol_slider_value_changed(value: float) -> void:
	if not EditorResources.song:
		vol_slider.set_value_no_signal(0)
		return
	
	if strum_id == -1:
		ChartEditor.instrumental_volume = value
	elif is_valid_id():
		EditorResources.strumlines[strum_id].volume = value
	
	vol_slider.tooltip_text = str(value * 100) + '%'

func _on_hit_sound_box_toggled(toggled_on: bool) -> void:
	
	SoundManager.tool_mouse_click.play()
	
	if strum_id == -1:
		pass
	elif is_valid_id():
		EditorResources.strumlines[strum_id].hit_sounds = toggled_on

func _on_delete_track_pressed() -> void:
	SoundManager.tool_note_remove.play()
	
	remove_requested.emit()

func _on_waveform_toggled(toggled_on: bool) -> void:
	EditorResources.strumlines[strum_id].waveform = toggled_on

func is_valid_id() -> bool:
	return strum_id == -1 or EditorResources.strumlines.size() > strum_id

func load_current_song():
	if not EditorResources.song:
		return
	
	var volume: float = ChartEditor.instrumental_volume
	
	if strum_id == -1:
		set_path(EditorResources.song.instrumental)
	elif is_valid_id():
		if EditorResources.song.vocals.size() > strum_id:
			set_path(EditorResources.song.vocals[strum_id])
		
		volume = EditorResources.strumlines[strum_id].volume
		hit_sound_box.set_pressed_no_signal(EditorResources.strumlines[strum_id].hit_sounds)
	else:
		volume = 0
	
	vol_slider.set_value_no_signal(volume)
	
	if strum_id == -1:
		delete_track.disabled = true
		hit_sound_box.disabled = true
		delete_track.mouse_default_cursor_shape = Control.CURSOR_ARROW
		hit_sound_box.mouse_default_cursor_shape = Control.CURSOR_ARROW
	else:
		delete_track.disabled = false
		hit_sound_box.disabled = false
		delete_track.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		hit_sound_box.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	
	if is_valid_id():
		vol_slider.editable = true
		vol_slider.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	else:
		vol_slider.editable = false
		vol_slider.mouse_default_cursor_shape = Control.CURSOR_ARROW

func _on_file_dialog_file_selected(_path: String) -> void:
	if path == original_path:
		dirty = false
	elif path != _path:
		dirty = true
	set_path(_path)

func _on_load_song_button_pressed() -> void:
	if path.is_empty() and EditorResources.song:
		var maybe_path = ResourceUID.ensure_path(EditorResources.song.resource_path)
		if maybe_path:
			file_dialog.current_dir = maybe_path.get_base_dir()
	else:
		file_dialog.current_dir = path.get_base_dir()
	SoundManager.tool_open_window.play()
	file_dialog.popup()


func _on_vol_slider_drag_started() -> void:
	SoundManager.tool_mouse_click.play()

func _on_vol_slider_drag_ended(value_changed: bool) -> void:
	SoundManager.tool_mouse_click.play()
