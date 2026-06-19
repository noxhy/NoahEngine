extends HBoxContainer

signal removed

var event: String:
	set(v):
		%"Track Name".text = v
		var icon: String = Constants.EVENT_DATA.get(v, {}).get("texture", "")
		if ResourceLoader.exists(icon):
			%"Track Name".right_icon = load(icon)
		
		event = v


func vanilla_1252320656__on_remove_track_pressed() -> void:
	emit_signal(&"removed")


# ModLoader Hooks - The following code has been automatically added by the Godot Mod Loader.


func _on_remove_track_pressed():
	if _ModLoaderHooks.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_1252320656__on_remove_track_pressed, [], 3006759906)
	else:
		vanilla_1252320656__on_remove_track_pressed()
