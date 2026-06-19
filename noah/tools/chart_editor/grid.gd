extends Node2D
class_name Grid

@export_group("Zoom")
@export var zoom: Vector2 = Vector2(1, 1):
	set(v):
		zoom = v
		draw()
	get():
		return zoom

@export_group("Grid Settings")
@export var event_grid: bool = false
@export var grid_size: Vector2 = Vector2(16, 16):
	set(v):
		grid_size = v
		draw()
	get():
		return grid_size

@export var columns: int = 4:
	set(v):
		columns = v
		draw()
	get():
		return columns

@export var rows: int = 16:
	set(v):
		rows = v
		draw()
	get():
		return rows

@export var centered: bool = true:
	set(v):
		centered = v
		draw()
	get():
		return centered
@export var grid_color: Color = Color(0, 0):
	set(v):
		grid_color = v
		draw()
	get():
		return grid_color

@export_group("Colors")
@export var event_column_color: Color = Color(1, 1, 1, 0.5)
@export var position_column_color: Color = Color(1, 1, 1, 0.5)

# Called when the node enters the scene tree for the first time.
func vanilla_3579225474_draw():
	$TextureRect.size = Vector2(16, 16) * Vector2(columns, rows)
	$TextureRect.scale = grid_size / Vector2(16, 16)
	$TextureRect.scale *= zoom
	$TextureRect.self_modulate = grid_color
	
	if centered:
		if !event_grid:
			$TextureRect.position.x = ($TextureRect.size.x * $TextureRect.scale.x) / -2.0
		else:
			$TextureRect.position.y = ($TextureRect.size.y * $TextureRect.scale.y) / -2.0
	else:
		$TextureRect.position = Vector2.ZERO


# Called every frame. 'delta' is the elapsed time since the previous frame.
func vanilla_3579225474__process(_delta):
	queue_redraw()


func vanilla_3579225474__draw():
	if !event_grid:
		## Color's the events column (the last one)
		var rect = Rect2(get_real_position(Vector2(0, 0)), get_real_position(Vector2(columns, rows)) - get_real_position(Vector2(columns - 1, 0)))
		draw_rect(rect, event_column_color)
		
		## Color's the position column (the first one)
		rect = Rect2(get_real_position(Vector2(columns - 1, 0)), get_real_position(Vector2(1, rows)) - get_real_position(Vector2(0, 0)))
		draw_rect(rect, position_column_color)
	else:
		## Color's the position column (the first one)
		var rect = Rect2(get_real_position(Vector2(0, 0)), get_real_position(Vector2(columns, 1)) - get_real_position(Vector2(0, 0)))
		draw_rect(rect, position_column_color)

## Returns the relative position of a grid position from the top left corner of a gridspace
func vanilla_3579225474_get_real_position(location: Vector2, snap: Vector2 = grid_size) -> Vector2:
	var output: Vector2 = Vector2(location) * snap * zoom
	output += $TextureRect.position
	return output

## Returns the grid position of a location
func vanilla_3579225474_get_grid_position(location: Vector2, snap: Vector2 = grid_size) -> Vector2:
	var output: Vector2 = location - $TextureRect.position
	output /= snap * zoom
	return output

## Returns the size of the grid
func vanilla_3579225474_get_size() -> Vector2:
	return $TextureRect.size * $TextureRect.scale


# ModLoader Hooks - The following code has been automatically added by the Godot Mod Loader.


func draw():
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_3579225474_draw, [], 1133141584)
	else:
		return vanilla_3579225474_draw()


func _process(_delta):
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_3579225474__process, [_delta], 2470599040)
	else:
		return vanilla_3579225474__process(_delta)


func _draw():
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_3579225474__draw, [], 3027519087)
	else:
		return vanilla_3579225474__draw()


func get_real_position(location: Vector2, snap: Vector2=grid_size) -> Vector2:
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_3579225474_get_real_position, [location, snap], 3883774585)
	else:
		return vanilla_3579225474_get_real_position(location, snap)


func get_grid_position(location: Vector2, snap: Vector2=grid_size) -> Vector2:
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_3579225474_get_grid_position, [location, snap], 89467099)
	else:
		return vanilla_3579225474_get_grid_position(location, snap)


func get_size() -> Vector2:
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_3579225474_get_size, [], 2854356316)
	else:
		return vanilla_3579225474_get_size()
