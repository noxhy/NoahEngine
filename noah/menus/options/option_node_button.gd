extends OptionNode
class_name ButtonOptionNode

@onready var button = $HBoxContainer/Button

# Called when the node enters the scene tree for the first time.
func vanilla_2506796800__ready() -> void:
	button.text = display_name

func vanilla_2506796800_select():
	var hover_style = button.get_theme_stylebox("hover", "Button")
	button.add_theme_stylebox_override("normal", hover_style)

func vanilla_2506796800_normal():
	button.remove_theme_stylebox_override("normal")


# ModLoader Hooks - The following code has been automatically added by the Godot Mod Loader.


func _ready():
	if _ModLoaderHooks.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_2506796800__ready, [], 1918105716)
	else:
		vanilla_2506796800__ready()


func select():
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_2506796800_select, [], 2685652480)
	else:
		return vanilla_2506796800_select()


func normal():
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_2506796800_normal, [], 2502058985)
	else:
		return vanilla_2506796800_normal()
