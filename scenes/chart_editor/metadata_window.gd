extends Window

signal updated_song_name(text: String)
signal updated_song_artist(text: String)
signal updated_icon_texture(path: String)
signal updated_starting_tempo(tempo: float)
signal updated_song_scene(path: String)

var song_name: String
var song_artist: String
var song_icon: String
var starting_tempo: float
var song_scene: String

func update_stats():
	%"Song Name".text = song_name
	%"Song Artist".text = song_artist
	_on_icon_file_dailog_file_selected(song_icon)
	%Tempo.value = starting_tempo
	_on_scene_file_dailog_file_selected(song_scene)

func _on_icon_file_dailog_file_selected(path: String) -> void:
	path = ResourceUID.path_to_uid(path)
	if !ResourceLoader.exists(path):
		printerr("Icon file doesn't exist.")
		return
	
	var sprite_frames = load(path)
	if sprite_frames is not SpriteFrames:
		printerr("Icon file is not a SpriteFrames")
		return
	
	assert(sprite_frames.has_animation("default"), "Animation \"default\" doesn't exist")
	var texture: Texture = sprite_frames.get_frame_texture("default", 0)
	%Icon.texture = texture
	$HBoxContainer/VBoxContainer/Icons/LineEdit.text = path
	updated_icon_texture.emit(path)

func _on_icon_button_pressed() -> void:
	$"VBoxContainer/Icons/Icon Button/Icon FileDailog".popup()

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
	$"VBoxContainer/Song Scene/Song Scene Button/Scene FileDailog".popup()

func file_dailog_gui_focus_changed(node: Control) -> void:
	emit_signal(&"gui_focus_changed", node)
