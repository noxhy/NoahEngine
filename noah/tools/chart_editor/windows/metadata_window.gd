extends Window

signal updated_song_name(text: String)
signal updated_song_artist(text: String)
signal updated_song_charter(text: String)
signal updated_song_scene(path: String)
signal updated_scroll_speed(speed: float)

var scroll_speed: float
var has_updated_scroll_speed: bool = false

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

func _on_icon_button_pressed() -> void:
	%"Icon FileDailog".popup()

func _on_scene_file_dailog_file_selected(path: String) -> void:
	if !ResourceLoader.exists(path):
		printerr("(Metadata Window): Scene \"%s\" doesn't exist." % path)
		%"Song Scene".text = ""
		%"Song Scene".tooltip_text = ""
		return
	
	path = ResourceUID.path_to_uid(path)
	%"Song Scene".text = path
	%"Song Scene".tooltip_text = path
	updated_song_scene.emit(path)

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


func _on_song_charter_text_changed(new_text: String) -> void:
	updated_song_charter.emit(new_text)
