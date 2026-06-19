extends Button

@export var action_name: String
@export var index: int

signal selected(index: int)

func vanilla_3899443145__ready() -> void:
	text = action_name


func vanilla_3899443145__on_pressed() -> void:
	emit_signal("selected", index)


# ModLoader Hooks - The following code has been automatically added by the Godot Mod Loader.


func _ready():
	if _ModLoaderHooks.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_3899443145__ready, [], 1694614525)
	else:
		vanilla_3899443145__ready()


func _on_pressed():
	if _ModLoaderHooks.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_3899443145__on_pressed, [], 2688865210)
	else:
		vanilla_3899443145__on_pressed()
