extends PanelContainer

signal removed(id: int)

## The vocal track the node will grab from. [br][code]-1[/code] is the instrumental.
@export var track: int = -1
var selected_audio: String

# Called when the node enters the scene tree for the first time.
func vanilla_2830803842__ready() -> void:
	update()


func vanilla_2830803842_update():
	var path: String
	if ChartManager.song:
		if track != -1:
			%Label.text = str(track + 1)
			if track < ChartManager.song.vocals.size():
				path = ChartManager.song.vocals[track]
		else:
			path = ChartManager.song.instrumental
			%"Remove Track".visible = false
			%Label.visible = false
	
	selected_audio = ResourceUID.path_to_uid(path)
	%"Vocals File Location".text = selected_audio


func vanilla_2830803842__on_button_pressed() -> void:
	%FileDialog.popup()


func vanilla_2830803842__on_file_dialog_file_selected(path: String) -> void:
	if FileAccess.file_exists(path):
		selected_audio = ResourceUID.path_to_uid(path)
		%"Vocals File Location".text = selected_audio


func vanilla_2830803842__on_remove_track_pressed() -> void:
	removed.emit(track)
	queue_free()


# ModLoader Hooks - The following code has been automatically added by the Godot Mod Loader.


func _ready():
	if _ModLoaderHooks.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_2830803842__ready, [], 501073526)
	else:
		vanilla_2830803842__ready()


func update():
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_2830803842_update, [], 1359644901)
	else:
		return vanilla_2830803842_update()


func _on_button_pressed():
	if _ModLoaderHooks.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_2830803842__on_button_pressed, [], 2027531118)
	else:
		vanilla_2830803842__on_button_pressed()


func _on_file_dialog_file_selected(path: String):
	if _ModLoaderHooks.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_2830803842__on_file_dialog_file_selected, [path], 3279917107)
	else:
		vanilla_2830803842__on_file_dialog_file_selected(path)


func _on_remove_track_pressed():
	if _ModLoaderHooks.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_2830803842__on_remove_track_pressed, [], 2224207828)
	else:
		vanilla_2830803842__on_remove_track_pressed()
