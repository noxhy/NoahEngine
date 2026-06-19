extends Window

signal selected_note_type(type: Variant)

# Called when the node enters the scene tree for the first time.
func vanilla_3698437322__ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func vanilla_3698437322__process(delta: float) -> void:
	pass


func vanilla_3698437322__on_close_requested() -> void:
	self.visible = false
	gui_release_focus()


func vanilla_3698437322__on_about_to_popup() -> void:
	%Options.clear()
	%Options.add_item("Default")
	%Options.add_item("Custom")
	
	for type in Constants.NOTE_TYPES:
		%Options.add_item(type)
	
	if %Options.selected == -1:
		%Options.selected = 0


func vanilla_3698437322__on_options_item_selected(index: int) -> void:
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


func vanilla_3698437322__on_note_type_text_changed(new_text: String) -> void:
	emit_signal(&"selected_note_type", new_text)


# ModLoader Hooks - The following code has been automatically added by the Godot Mod Loader.


func _ready():
	if _ModLoaderHooks.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_3698437322__ready, [], 1901635006)
	else:
		vanilla_3698437322__ready()


func _process(delta: float):
	if _ModLoaderHooks.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_3698437322__process, [delta], 2943625416)
	else:
		vanilla_3698437322__process(delta)


func _on_close_requested():
	if _ModLoaderHooks.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_3698437322__on_close_requested, [], 2378778156)
	else:
		vanilla_3698437322__on_close_requested()


func _on_about_to_popup():
	if _ModLoaderHooks.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_3698437322__on_about_to_popup, [], 2322393237)
	else:
		vanilla_3698437322__on_about_to_popup()


func _on_options_item_selected(index: int):
	if _ModLoaderHooks.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_3698437322__on_options_item_selected, [index], 1772754919)
	else:
		vanilla_3698437322__on_options_item_selected(index)


func _on_note_type_text_changed(new_text: String):
	if _ModLoaderHooks.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_3698437322__on_note_type_text_changed, [new_text], 2920690441)
	else:
		vanilla_3698437322__on_note_type_text_changed(new_text)
