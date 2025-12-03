extends OptionNode
class_name BoolOptionNode

# Called when the node enters the scene tree for the first time.
func _ready():
	%Button.button_pressed = SaveManager.get_pref(setting_category,setting_name)
	%Label.text = display_name
	update()


func _on_check_button_toggled(button_pressed):
	SaveManager.set_pref(setting_category, setting_name, button_pressed)
	SoundManager.scroll.play()
	update()

func update():
	%Button.text = str(%Button.button_pressed)
	if %Button.button_pressed:
		%Button.add_theme_color_override("font_color", Color.AQUA)
		%Button.add_theme_color_override("font_hover_color", Color.AQUA)
		%Button.add_theme_color_override("font_pressed_color", Color.AQUA)
		%Button.add_theme_color_override("font_hover_pressed_color", Color.AQUA)
		%Button.add_theme_color_override("font_focus_color", Color.AQUA)
	else:
		%Button.add_theme_color_override("font_color", Color.DEEP_PINK)
		%Button.add_theme_color_override("font_hover_color", Color.DEEP_PINK)
		%Button.add_theme_color_override("font_pressed_color", Color.DEEP_PINK)
		%Button.add_theme_color_override("font_hover_pressed_color", Color.DEEP_PINK)
		%Button.add_theme_color_override("font_focus_color", Color.DEEP_PINK)
