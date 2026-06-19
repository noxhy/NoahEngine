extends Node2D

var COMBO_NUMBER_PRELOAD = load("uid://b28wu6vajuag3")

@export var ui_skin: UISkin
@export var combo = 0
@export var fc = false

# Called when the node enters the scene tree for the first time.
func vanilla_750113866__ready():
	if combo > 0:
		var digits = str(combo).length()
		for digit in digits:
			
			var combo_number_instance = COMBO_NUMBER_PRELOAD.instantiate()
			
			combo_number_instance.position.x = ui_skin.numbers_spacing * (digit - (digits / 2.0)) * ui_skin.numbers_scale
			combo_number_instance.ui_skin = ui_skin
			combo_number_instance.digit = int(combo / pow(10, digits - digit - 1)) % 10
			combo_number_instance.fc = fc
			
			add_child(combo_number_instance)


func vanilla_750113866__on_timer_timeout():
	queue_free()


# ModLoader Hooks - The following code has been automatically added by the Godot Mod Loader.


func _ready():
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_750113866__ready, [], 2164026686)
	else:
		return vanilla_750113866__ready()


func _on_timer_timeout():
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_750113866__on_timer_timeout, [], 3104329324)
	else:
		return vanilla_750113866__on_timer_timeout()
