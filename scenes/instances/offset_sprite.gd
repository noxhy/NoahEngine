extends AnimatedSprite2D
class_name OffsetSprite

## Each key is the animation id and the value is the real animation name in the [code]SpriteFrames[/code]
@export var animation_names: Dictionary[StringName, StringName] = {}
## Each key is the animation name in the [code]SpriteFrames[/code] and the value is the offset
@export var offsets: Dictionary[StringName, Vector2] = {}

func play_animation(animation_name: StringName, forced: bool = true):
	if animation_names.has(animation_name):
		var real_animation_name: String = animation_names.get(animation_name)
		
		if not forced and animation == real_animation_name:
			return
		
		play(real_animation_name)
		offset = offsets.get(real_animation_name, Vector2.ZERO)

## Returns the animation name of the given id in SpriteFrames.
func get_real_animation(animation_name: StringName) -> Variant:
	return animation_names.get(animation_name)
