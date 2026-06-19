@tool
extends Line2D

@export var start_texture: Texture
@export var end_texture: Texture

func vanilla_2369915565__draw():
	if points.size() > 1:
		var direction: Vector2
		
		if start_texture:
			var start_pos: Vector2 = points[0]
			direction = points[0] - points[1]
			var angle: float = direction.angle()
			var offset: Vector2 = Vector2(-start_texture.get_height() / 2.0, start_texture.get_height() / 2.0) * Vector2(sin(angle), cos(angle))
			draw_set_transform(start_pos - offset, angle)
			draw_texture(start_texture, Vector2.ZERO)
		
		if end_texture:
			var end_pos: Vector2 = points[points.size() - 1]
			direction = end_pos - points[points.size() - 2]
			var angle: float = direction.angle()
			var offset: Vector2 = Vector2(-end_texture.get_height() / 2.0, end_texture.get_height() / 2.0) * Vector2(sin(angle), cos(angle))
			draw_set_transform(end_pos - offset, angle)
			draw_texture(end_texture, Vector2.ZERO)


# ModLoader Hooks - The following code has been automatically added by the Godot Mod Loader.


func _draw():
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_2369915565__draw, [], 345284218)
	else:
		return vanilla_2369915565__draw()
