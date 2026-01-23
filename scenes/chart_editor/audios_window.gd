extends Window

const AUDIO_TRACK_PRELOAD = preload("res://scenes/chart_editor/audio_track.tscn")

signal updated

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func _on_close_requested() -> void:
	self.visible = false
	gui_release_focus()


func _on_about_to_popup() -> void:
	for node in %Audios.get_children():
		node.queue_free()
	
	var i: int = 0
	for path in ChartManager.song.vocals:
		create_track_node(i)
		i += 1
	
	%Instrumental.update()


func _on_save_button_pressed() -> void:
	ChartManager.song.instrumental = %Instrumental.selected_audio
	
	ChartManager.song.vocals = []
	for node in %Audios.get_children():
		ChartManager.song.vocals.append(node.selected_audio)
	
	emit_signal(&"updated")
	hide()
	close_requested.emit()


func create_track_node(id: int):
	var track = AUDIO_TRACK_PRELOAD.instantiate()
	track.track = id
	%Audios.add_child(track)
	track.connect(&"removed", self.remove_track)


func _on_add_track_pressed() -> void:
	create_track_node(%Audios.get_children().size())


func remove_track(id: int):
	%Audios.get_children()[id].queue_free()
	var i: int = 0
	for node in %Audios.get_children():
		node.track = i
		node.update()
		if i == id:
			i -= 1
			id = -1
		
		i += 1
