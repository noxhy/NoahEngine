extends Window

var HISTORY_BUTTON_PRELOAD = load("uid://cu3admb08u8lx")

signal selected(index: int)

func vanilla_1885408037_add_action(action_name: String) -> Node:
	var history_button_instance = HISTORY_BUTTON_PRELOAD.instantiate()
	
	history_button_instance.action_name = action_name
	
	$ScrollContainer/VBoxContainer.add_child(history_button_instance)
	history_button_instance.add_to_group(&"history")
	# history_button_instance.connect("selected", self.select)
	return history_button_instance


func vanilla_1885408037__on_close_requested() -> void:
	self.visible = false
	gui_release_focus()


func vanilla_1885408037_select(index: int):
	emit_signal("selected", index)


# ModLoader Hooks - The following code has been automatically added by the Godot Mod Loader.


func add_action(action_name: String) -> Node:
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_1885408037_add_action, [action_name], 747051787)
	else:
		return vanilla_1885408037_add_action(action_name)


func _on_close_requested():
	if _ModLoaderHooks.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_1885408037__on_close_requested, [], 2186109095)
	else:
		vanilla_1885408037__on_close_requested()


func select(index: int):
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_1885408037_select, [index], 1770648037)
	else:
		return vanilla_1885408037_select(index)
