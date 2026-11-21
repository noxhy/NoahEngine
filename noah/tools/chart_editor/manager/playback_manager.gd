extends Node
class_name ChartEditorPlaybackManager

var editor: ChartEditor

func _init(_editor: ChartEditor) -> void:
	editor = _editor

func update(delta: float) -> void:
	pass


func update_song_streams() -> void:
	if not EditorResources.song:
		return
		
	editor.music.stream.stream_count = EditorResources.song.vocals.size() + 1
	
	editor.music.stream.set_sync_stream(0, SoundManager.get_stream(EditorResources.song.instrumental))
	var idx: int = 1
	for path in EditorResources.song.vocals:
		editor.music.stream.set_sync_stream(idx, SoundManager.get_stream(path))
		idx += 1

func change_playback_speed(delta: float) -> void:
	SettingsManager.data.song_speed = clamp(SettingsManager.data.song_speed + delta, 0.0, 2.0)
	editor.song_speed = SettingsManager.data.song_speed
	SettingsManager.flush()


func seek_to(time: float) -> void:
	time = clamp(time, 0, get_inst_length() - editor.EPSILON)
	editor.song_position = time + editor.start_offset
	
	editor.music.play(editor.song_position)

func toggle_playing(paused: bool) -> void:
	editor.music.stream_paused = paused
	
	if not paused:
		seek_to(editor.song_position)
	


func get_inst_length() -> float:
	if not editor.music:
		return 0.0
	
	if not editor.music.stream.get_sync_stream(0):
		return 0.0
	
	return editor.music.stream.get_sync_stream(0).get_length()
