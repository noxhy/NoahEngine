extends OptionNode

@export var checking = false
@export var index = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	self.text = OS.get_keycode_string(SettingsManager.get_keybind(setting_name)[index])

func _input(event):
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


func _on_toggled(button_pressed):
	if button_pressed:
		self.text = "..."
		checking = true


func select():
	var hover_style = get_theme_stylebox("hover", "Button")
	add_theme_stylebox_override("normal", hover_style)

func normal():
	remove_theme_stylebox_override("normal")
	checking = false
	self.text = OS.get_keycode_string(SettingsManager.get_keybind(setting_name)[index])
	self.button_pressed = false
	_on_toggled(false)
