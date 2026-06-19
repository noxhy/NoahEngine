extends FileDialog


func vanilla_579016864__on_file_selected(path): self.queue_free()
func vanilla_579016864__on_close_requested(): self.queue_free()


# ModLoader Hooks - The following code has been automatically added by the Godot Mod Loader.


func _on_file_selected(path):
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_579016864__on_file_selected, [path], 4128419491)
	else:
		return vanilla_579016864__on_file_selected(path)


func _on_close_requested():
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_579016864__on_close_requested, [], 828216898)
	else:
		return vanilla_579016864__on_close_requested()
