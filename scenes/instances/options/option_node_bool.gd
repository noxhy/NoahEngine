extends OptionNode
class_name BoolOptionNode

# Called when the node enters the scene tree for the first time.
func _ready():
	%Button.button_pressed = SaveManager.get_value(setting_category, setting_name)
	%Label.text = display_name
	update()

func _on_check_button_toggled(button_pressed):
	SaveManager.set_value(setting_category, setting_name, button_pressed)
	SoundManager.accept.play()
	update()

func update():
	%Button.text = str(%Button.button_pressed).to_upper()
