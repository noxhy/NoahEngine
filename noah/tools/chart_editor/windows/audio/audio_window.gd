extends Window

signal updated_current_song

@onready var track_container: HBoxContainer = %"Track Container"

@onready var save_button: Button = $"VBoxContainer/HBoxContainer/Save Button"
@onready var add_track_button: Button = $"VBoxContainer/HBoxContainer/Add Track"

var PANEL_PRELOAD = load("uid://c3w2xmw47elm3")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	close_requested.connect(hide_popup)
	about_to_popup.connect(prepare_tracks)
	

func prepare_tracks():
	if not EditorResources.song:
		return
	
	for panel in track_container.get_children():
		track_container.remove_child(panel)
		panel.queue_free()
	
	
	add_track(-1)
	
	var idx: int = 1
	
	for vocals in EditorResources.song.vocals:
		add_track(idx)
		idx += 1

func add_track(idx:int):
	var instance: Control = PANEL_PRELOAD.instantiate()
	track_container.add_child(instance)
	instance.set_id(idx)
	instance.load_current_song()
	instance.remove_requested.connect(func():
		remove_track(instance.strum_id)
	)

func get_track_from_id(id: int) -> Control:
	for node in track_container.get_children():
		if node.strum_id > -1 and id == node.strum_id:
			return node
	return null

func remove_track(id: int):
	var track = get_track_from_id(id)
	if not track:
		return
	track_container.remove_child(track)
	track.queue_free()
	
	var idx: int = 1
	for node in track_container.get_children():
		if node.strum_id > -1:
			node.set_id(idx)
			node.load_current_song()
			idx += 1

func hide_popup():
	hide()

func _on_add_track_pressed() -> void:
	add_track(track_container.get_child_count())

func _on_save_button_pressed() -> void:
	EditorResources.song.vocals.clear()
	for node in track_container.get_children():
		if node.id == -1:
			EditorResources.song.instrumental = ResourceUID.path_to_uid(node.path)
		else:
			EditorResources.song.vocals.append(ResourceUID.path_to_uid(node.path))
		
	updated_current_song.emit()
	close_requested.emit()
