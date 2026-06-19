extends OptionNode

@export var checking = false
@export var index = 0

# Called when the node enters the scene tree for the first time.
func vanilla_2713728840__ready():
	self.text = OS.get_keycode_string(SettingsManager.get_keybind(setting_name)[index])

func vanilla_2713728840__input(event):
	if checking:
		if event is InputEventKey:
			if event.is_pressed():
				if event.keycode == KEY_DELETE:
					event.keycode = KEY_NONE
				
				checking = false
				SettingsManager.set_keybind(setting_name, event.keycode, index)
				SettingsManager.flush()
				self.text = OS.get_keycode_string(SettingsManager.get_keybind(setting_name)[index])
				self.button_pressed = false
				SoundManager.accept.play()


func vanilla_2713728840__on_toggled(button_pressed):
	if button_pressed:
		self.text = "..."
		checking = true


func vanilla_2713728840_select():
	var hover_style = get_theme_stylebox("hover", "Button")
	add_theme_stylebox_override("normal", hover_style)

func vanilla_2713728840_normal():
	remove_theme_stylebox_override("normal")
	checking = false
	self.text = OS.get_keycode_string(SettingsManager.get_keybind(setting_name)[index])
	self.button_pressed = false
	_on_toggled(false)


# ModLoader Hooks - The following code has been automatically added by the Godot Mod Loader.


func _ready():
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_2713728840__ready, [], 1091606204)
	else:
		return vanilla_2713728840__ready()


func _input(event):
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_2713728840__input, [event], 1081273239)
	else:
		return vanilla_2713728840__input(event)


func _on_toggled(button_pressed):
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_2713728840__on_toggled, [button_pressed], 4210503081)
	else:
		return vanilla_2713728840__on_toggled(button_pressed)


func select():
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_2713728840_select, [], 1859152968)
	else:
		return vanilla_2713728840_select()


func normal():
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_2713728840_normal, [], 1675559473)
	else:
		return vanilla_2713728840_normal()
