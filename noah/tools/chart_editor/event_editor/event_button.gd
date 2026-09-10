extends HBoxContainer

signal removed

var event: String:
	set(v):
		%"Track Name".text = v
		var icon: String = Constants.EVENT_DATA.get(v, {}).get("texture", "res://addons/at-icons/node/diamond_shape.svg")
		%"Track Name".right_icon = load(icon)
		
		var tip: String = str("event: ", v)
		
		var desc: String = Constants.EVENT_DATA.get(v, {}).get("description", "")
		if not desc.is_empty():
			tip += str('\ndesc: ', Constants.EVENT_DATA.get(v, {}).get("description", ""))
		
		%"Track Name".tooltip_text = tip
		
		event = v


func _on_remove_track_pressed() -> void:
	if Input.is_action_pressed("shift"):
		emit_signal(&"removed")
	else:
		var dialog = ConfirmationDialog.new()
		pre_delete()
		
		var close_window = func():
			if dialog:
				dialog.queue_free()
			SoundManager.tool_close_window.play()
			post_we_are_safe_woohoo()
			
		var confirmed = func():
			emit_signal(&"removed")
			SoundManager.tool_close_window.play()
			
		
		dialog.unresizable = true
		dialog.size = Vector2i(380, 100)
		dialog.dialog_text = "Deleting (%s) track will remove all events associated with it. Are you sure?" % event
		dialog.dialog_autowrap = true
		dialog.canceled.connect(close_window)
		dialog.confirmed.connect(confirmed)
		dialog.add_to_group(&"windows")
		add_child(dialog)
		dialog.popup_centered()
		SoundManager.tool_open_window.play()

func pre_delete():
	modulate = Color(1, 0.3, 0.3,1)
	
func post_we_are_safe_woohoo():
	modulate = Color.WHITE
