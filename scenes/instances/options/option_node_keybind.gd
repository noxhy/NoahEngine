extends OptionNode
class_name KeyBindOptionNode

const KEYBIND_BUTTON_PRELOAD = preload("res://scenes/instances/options/keybind_button.tscn")

var selected: int = 0
var object_amount: int = 0
var buttons: Array[Button] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	%Label.text = display_name
	for i in SettingsManager.get_keybind(setting_name):
		var keybind_button_instance = KEYBIND_BUTTON_PRELOAD.instantiate()
		keybind_button_instance.setting_name = setting_name
		keybind_button_instance.index = object_amount
		object_amount += 1
		
		$HBoxContainer.add_child(keybind_button_instance)
		keybind_button_instance.connect("mouse_entered", self.select_button.bind(keybind_button_instance.index))
		# keybind_button_instance.connect("mouse_exited", get_tree().call_group.bind("buttons", "normal"))
		buttons.append(keybind_button_instance)

func select_button(i: int):
	selected = wrapi(i, 0, buttons.size())
	get_tree().call_group("buttons", "normal")
	if i > -1:
		SoundManager.scroll.play()
		buttons[selected].select()

func normal():
	super()
	selected = -1
