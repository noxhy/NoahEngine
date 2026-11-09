@tool
extends Character2
class_name CharacterAnimatedSprite2D

func get_animation_names() -> Array[StringName]:
	if animation_player and "sprite_frames" in animation_player:
		return Array(animation_player.sprite_frames.get_animation_names())
	return [&""]
