extends ResourceFileDialog


func _on_close_requested() -> void:
	self.visible = false
	gui_release_focus()
