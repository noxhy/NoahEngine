extends Control
class_name OptionNode

@export var setting_category:String = ''
@export var setting_name: String = ""
@export var display_name = ""
@export var description: String

@onready var background = %Background

func vanilla_1770053125_set_offset_left(offset: float):
	offset_left = offset

func vanilla_1770053125_select() -> void:
	if background:
		background.color = Color(1.0, 1.0, 1.0, 0.5)

func vanilla_1770053125_normal() -> void:
	if background:
		background.color = Color(0.0, 0.0, 0.0, 0.5)


# ModLoader Hooks - The following code has been automatically added by the Godot Mod Loader.


func set_offset_left(offset: float):
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_1770053125_set_offset_left, [offset], 3607386625)
	else:
		return vanilla_1770053125_set_offset_left(offset)


func select():
	if _ModLoaderHooks.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_1770053125_select, [], 515140805)
	else:
		vanilla_1770053125_select()


func normal():
	if _ModLoaderHooks.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_1770053125_normal, [], 331547310)
	else:
		vanilla_1770053125_normal()
