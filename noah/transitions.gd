extends Node2D

signal waiting

@onready var anim_player: AnimationPlayer = $AnimationPlayer

func vanilla_1835221907__ready():
	anim_player.play(&"RESET")

func vanilla_1835221907_transition(transition_name: StringName):
	anim_player.play(&"RESET")
	anim_player.seek(0) # reset all other transitions
	anim_player.play(transition_name)
	anim_player.seek(0)

func vanilla_1835221907_pause():
	if Global.transitioning:
		anim_player.pause()
		emit_signal(&"waiting")

func vanilla_1835221907_resume():
	if !anim_player.is_playing():
		anim_player.play()


func vanilla_1835221907__on_animation_player_animation_finished(_anim_name: StringName) -> void:
	if _anim_name != &"RESET":
		anim_player.play(&"RESET")


# ModLoader Hooks - The following code has been automatically added by the Godot Mod Loader.


func _ready():
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_1835221907__ready, [], 1125936967)
	else:
		return vanilla_1835221907__ready()


func transition(transition_name: StringName):
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_1835221907_transition, [transition_name], 4251559806)
	else:
		return vanilla_1835221907_transition(transition_name)


func pause():
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_1835221907_pause, [], 3958202769)
	else:
		return vanilla_1835221907_pause()


func resume():
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_1835221907_resume, [], 1854617636)
	else:
		return vanilla_1835221907_resume()


func _on_animation_player_animation_finished(_anim_name: StringName):
	if _ModLoaderHooks.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_1835221907__on_animation_player_animation_finished, [_anim_name], 1900305090)
	else:
		vanilla_1835221907__on_animation_player_animation_finished(_anim_name)
