extends OptionNode
class_name BoolOptionNode

# Called when the node enters the scene tree for the first time.
func vanilla_400122256__ready():
	%Button.button_pressed = SettingsManager.get_value(setting_category, setting_name)
	%Label.text = display_name
	update()

func vanilla_400122256__on_check_button_toggled(button_pressed):
	SettingsManager.set_value(setting_category, setting_name, button_pressed)
	SoundManager.accept.play()
	update()

func vanilla_400122256_update():
	%Button.text = str(%Button.button_pressed).capitalize()


# ModLoader Hooks - The following code has been automatically added by the Godot Mod Loader.


func _ready():
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_400122256__ready, [], 3661780740)
	else:
		return vanilla_400122256__ready()


func _on_check_button_toggled(button_pressed):
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_400122256__on_check_button_toggled, [button_pressed], 2548669449)
	else:
		return vanilla_400122256__on_check_button_toggled(button_pressed)


func update():
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_400122256_update, [], 225384819)
	else:
		return vanilla_400122256_update()
