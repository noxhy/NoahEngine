extends PanelContainer

@onready var id_label: Label = %"ID Label"
@onready var delete_track: Button = %"Delete Track"
@onready var load_song_button: Button = %"Load Song Button"

#@onready var song_path: TextEdit = %"song path"
@onready var vol_slider: VSlider = %"vol Slider"
@onready var hit_sound_box: CheckBox = %"hit sound box"
var path: String = ''
var parent: Node

@export var strum_id: int = -1

signal remove_requested

func set_id(id: int):
	if id == -1:
		id_label.text = 'Inst'
	else:
		id_label.text = str(id)
	strum_id = id

func set_path(path: String):
	if path.begins_with("uid"):
		path = ResourceUID.uid_to_path(path)
	
	self.path = path

func _on_vol_slider_value_changed(value: float) -> void:
	if not EditorResources.song:
		vol_slider.set_value_no_signal(0)
		return
	
	if strum_id == -1:
		ChartEditor.instrumental_volume = value
	elif is_valid_id():
		EditorResources.strumlines[strum_id].volume = value

func _on_hit_sound_box_toggled(toggled_on: bool) -> void:
	
	if strum_id == -1:
		pass
	elif is_valid_id():
		EditorResources.strumlines[strum_id].hit_sounds = toggled_on

func _on_delete_track_pressed() -> void:
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
	
	
	load_song_button.tooltip_text = path
	
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


func _on_change_track_pressed() -> void:
	%FileDialog.popup()
	#$add.popup()
	#var tree = $add/Tree
	#tree.clear()
	#
	#var files = NoahTools.get_files_with_exts(['ogg', 'wav', 'mp3'], 'res://', ["res://noah"])
	#
	#var found_files:Dictionary
	#for file in files:
		#var dir: String = file.get_base_dir()
		#if !found_files.has(dir):
			#found_files[dir] = []
		#
		#found_files[dir].append(file)
	#
	#var root: TreeItem = tree.create_item()
	#for dir in found_files:
		#var dir_item: TreeItem = root.create_child()
		#dir_item.set_text(0, dir)
		#dir_item.set_custom_color(0, Color(0.5, 0.5, 0.5))
		#
		#for file in found_files[dir]:
			#var file_item: TreeItem = dir_item.create_child()
			#file_item.set_text(0, file.get_file())
			#file_item.set_metadata(0, file)
			#file_item.set_icon(0, load("res://addons/at-icons/node/file.svg"))
			#
			#file_item.set_icon_max_width(0, 16)

func _on_file_dialog_file_selected(path: String) -> void:
	set_path(path)
