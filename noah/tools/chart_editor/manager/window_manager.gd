extends Node
class_name ChartEditorWindowManager

var editor: ChartEditor

var OPEN_WINDOW_SFX: String = 'uid://cj2c8fsy4ltsw'
var CLOSE_WINDOW_SFX: String = 'uid://cr0bkyuutvvt'

func _init(_editor: ChartEditor) -> void:
	editor = _editor


func update(delta: float) -> void:
	pass

func init_window(window: Window, free_on_close: bool = false) -> void:
	if not window.is_in_group(&"windows"):
		window.add_to_group(&"windows")
	
	if not window.about_to_popup.is_connected(window_opened):
		window.about_to_popup.connect(window_opened)
	
	if not window.close_requested.is_connected(close_window):
		window.close_requested.connect(close_window.bind(window, free_on_close))
		
func popup_window(window: Window, free_on_close: bool = false) -> void:
	init_window(window, free_on_close)
	window.popup()

func window_opened() -> void:
	SoundManager.play_sound_once(OPEN_WINDOW_SFX)

func close_window(window: Window, free_on_close: bool) -> void:
	SoundManager.play_sound_once(CLOSE_WINDOW_SFX)
	
	if free_on_close:
		window.queue_free()
	else:
		window.hide()

func is_point_in_any_window(point: Vector2) -> bool:
	for window: Window in get_tree().get_nodes_in_group(&"windows"):
		if not window or not window.visible or window is not Window:
			continue
		
		var position_offset = window.get_position_with_decorations() - window.position
		
		#the decoration addition is only needed for the y
		var window_rect = Rect2i(window.get_position_with_decorations() + position_offset, window.get_size_with_decorations())
		window_rect.position.x = window.position.x
		window_rect.size.x = window.size.x
		
		if window_rect.has_point(point):
			return true
	
	return false
