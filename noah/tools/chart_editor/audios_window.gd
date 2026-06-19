extends Window

var AUDIO_TRACK_PRELOAD = load("uid://ngxlibrfoqjc")

signal updated

# Called when the node enters the scene tree for the first time.
func vanilla_3285930008__ready() -> void:
	pass

func vanilla_3285930008__on_close_requested() -> void:
	self.visible = false
	gui_release_focus()


func vanilla_3285930008__on_about_to_popup() -> void:
	for node in %Audios.get_children():
		node.queue_free()
	
	var i: int = 0
	for path in ChartManager.song.vocals:
		create_track_node(i)
		i += 1
	
	%"Instrumental Track".update()


func vanilla_3285930008__on_save_button_pressed() -> void:
	ChartManager.song.instrumental = %"Instrumental Track".selected_audio
	
	ChartManager.song.vocals = []
	for node in %Audios.get_children():
		ChartManager.song.vocals.append(node.selected_audio)
	
	emit_signal(&"updated")
	hide()
	close_requested.emit()


func vanilla_3285930008_create_track_node(id: int):
	var track = AUDIO_TRACK_PRELOAD.instantiate()
	track.track = id
	%Audios.add_child(track)
	track.connect(&"removed", self.remove_track)


func vanilla_3285930008__on_add_track_pressed() -> void:
	create_track_node(%Audios.get_children().size())


func vanilla_3285930008_remove_track(id: int):
	%Audios.get_children()[id].queue_free()
	var i: int = 0
	for node in %Audios.get_children():
		node.track = i
		node.update()
		if i == id:
			i -= 1
			id = -1
		
		i += 1


# ModLoader Hooks - The following code has been automatically added by the Godot Mod Loader.


func _ready():
	if _ModLoaderHooks.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_3285930008__ready, [], 1282345868)
	else:
		vanilla_3285930008__ready()


func _on_close_requested():
	if _ModLoaderHooks.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_3285930008__on_close_requested, [], 1091185338)
	else:
		vanilla_3285930008__on_close_requested()


func _on_about_to_popup():
	if _ModLoaderHooks.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_3285930008__on_about_to_popup, [], 331117411)
	else:
		vanilla_3285930008__on_about_to_popup()


func _on_save_button_pressed():
	if _ModLoaderHooks.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_3285930008__on_save_button_pressed, [], 2537028594)
	else:
		vanilla_3285930008__on_save_button_pressed()


func create_track_node(id: int):
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_3285930008_create_track_node, [id], 1834867525)
	else:
		return vanilla_3285930008_create_track_node(id)


func _on_add_track_pressed():
	if _ModLoaderHooks.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_3285930008__on_add_track_pressed, [], 671216837)
	else:
		vanilla_3285930008__on_add_track_pressed()


func remove_track(id: int):
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_3285930008_remove_track, [id], 1472432506)
	else:
		return vanilla_3285930008_remove_track(id)
