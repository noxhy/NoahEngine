extends Window

signal selected_note_type(type: Variant)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_close_requested() -> void:
	self.visible = false
	gui_release_focus()


func _on_about_to_popup() -> void:
	%Options.clear()
	%Options.add_item("Default")
	%Options.add_item("Custom")
	
	for type in Strum.NOTE_TYPES:
		%Options.add_item(type)
	
	if %Options.selected == -1:
		%Options.selected = 0


func _on_options_item_selected(index: int) -> void:
	var type: Variant
	$VBoxContainer/type.visible = (index == 1)
	match index:
		0:
			type = ""
		
		1:
			if %"Note Type".text == "":
				return
			else:
				type = %"Note Type".text
		
		_:
			type = %Options.get_item_text(index)
	
	emit_signal(&"selected_note_type", type)


func _on_note_type_text_changed(new_text: String) -> void:
	emit_signal(&"selected_note_type", new_text)
