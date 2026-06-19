extends PanelContainer

signal removed(id: int)

## The vocal track the node will grab from. [br][code]-1[/code] is the instrumental.
@export var track: int = -1
var selected_audio: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update()


func update():
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


func _on_button_pressed() -> void:
	%FileDialog.popup()


func _on_file_dialog_file_selected(path: String) -> void:
	if FileAccess.file_exists(path):
		selected_audio = ResourceUID.path_to_uid(path)
		%"Vocals File Location".text = selected_audio


func _on_remove_track_pressed() -> void:
	removed.emit(track)
	queue_free()
