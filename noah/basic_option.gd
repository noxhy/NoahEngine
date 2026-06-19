extends Node2D
class_name MenuOption

@export var text: String = "Menu Option"
@export var icon: Texture

@onready var label: Variant
@onready var sprite = $Sprite2D

# Called when the node enters the scene tree for the first time.
func vanilla_1974258127__ready():
	label = $Label
	label.text = text
	if icon:
		sprite.texture = icon
		await Engine.get_main_loop().process_frame
		sprite.position.x = label.size.x + sprite.texture.get_width() * 0.5 + 15


# ModLoader Hooks - The following code has been automatically added by the Godot Mod Loader.


func _ready():
	if _ModLoaderHooks.any_mod_hooked:
		return await _ModLoaderHooks.call_hooks_async(vanilla_1974258127__ready, [], 2761470595)
	else:
		return await vanilla_1974258127__ready()
