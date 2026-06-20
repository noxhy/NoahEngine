extends PanelContainer


func _input(event: InputEvent) -> void:
	# Click outside handling
	if event is InputEventMouseButton and event.is_pressed():
		if not get_global_rect().has_point(get_global_mouse_position()):
			hide()
