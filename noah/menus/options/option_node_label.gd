extends OptionNode

# Called when the node enters the scene tree for the first time.
func vanilla_4181189604__ready() -> void:
	%Label.text = display_name

func vanilla_4181189604_normal() -> void:
	if background:
		background.color = Color(0.0, 0.0, 0.0, 0.0)

func vanilla_4181189604_select() -> void:
	super.select()


# ModLoader Hooks - The following code has been automatically added by the Godot Mod Loader.


func _ready():
	if _ModLoaderHooks.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_4181189604__ready, [], 521554008)
	else:
		vanilla_4181189604__ready()


func normal():
	if _ModLoaderHooks.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_4181189604_normal, [], 1105507277)
	else:
		vanilla_4181189604_normal()


func select():
	if _ModLoaderHooks.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_4181189604_select, [], 1289100772)
	else:
		vanilla_4181189604_select()
