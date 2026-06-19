extends OptionNode
class_name KeyBindOptionNode

var KEYBIND_BUTTON_PRELOAD = load("uid://darhx23v4e15y")

var selected: int = 0
var object_amount: int = 0
var buttons: Array[Button] = []

# Called when the node enters the scene tree for the first time.
func vanilla_1160196842__ready():
	%Label.text = display_name
	for i in SettingsManager.get_keybind(setting_name):
		var keybind_button_instance = KEYBIND_BUTTON_PRELOAD.instantiate()
		keybind_button_instance.setting_name = setting_name
		keybind_button_instance.index = object_amount
		object_amount += 1
		
		$HBoxContainer.add_child(keybind_button_instance)
		keybind_button_instance.connect("mouse_entered", self.select_button.bind(keybind_button_instance.index))
		#keybind_button_instance.connect("pressed")
		# keybind_button_instance.connect("mouse_exited", get_tree().call_group.bind("buttons", "normal"))
		buttons.append(keybind_button_instance)

func vanilla_1160196842_select_button(i: int):
	selected = wrapi(i, 0, buttons.size())
	get_tree().call_group("buttons", "normal")
	if i > -1:
		SoundManager.scroll.play()
		buttons[selected].select()

func vanilla_1160196842_normal():
	super.normal()
	selected = -1


# ModLoader Hooks - The following code has been automatically added by the Godot Mod Loader.


func _ready():
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_1160196842__ready, [], 1759658974)
	else:
		return vanilla_1160196842__ready()


func select_button(i: int):
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_1160196842_select_button, [i], 1265304197)
	else:
		return vanilla_1160196842_select_button(i)


func normal():
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_1160196842_normal, [], 2343612243)
	else:
		return vanilla_1160196842_normal()
