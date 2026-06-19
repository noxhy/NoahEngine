extends CanvasLayer
class_name BasicUI

@export_custom(PROPERTY_HINT_LINK, 'x') var target_zoom:Vector2 = Vector2.ONE

@export_group("Zoom Smoothing")
## If [code]true[/code], the camera's zoom smoothly zoom towards its target position at [member zoom_smoothing_speed].
@export_custom(PROPERTY_HINT_GROUP_ENABLE, '') var zoom_smoothing: bool = true
## The asymptotic speed of the camera's zoom smoothing effect when [member zoom_smoothing] is true.
@export_custom(PROPERTY_HINT_RANGE, '1, 64, suffix:weight') var zoom_smoothing_speed: float = 5

@onready var rating_marker: Node = $"Rating Marker"
@onready var combo_marker: Node = $"Combo Marker"

var strums:Array[StrumManager] = []

func vanilla_1903477885__ready() -> void:
	for node in get_tree().get_nodes_in_group(&"strums"):
		strums.append(node)
	
	apply_underlay()


func vanilla_1903477885__process(delta: float) -> void:
	if zoom_smoothing:
		scale = Global.frame_independent_lerp(scale, target_zoom, zoom_smoothing_speed, delta)


func vanilla_1903477885_bump(strength: Vector2):
	scale += strength


func vanilla_1903477885_update_player(player: Character):
	pass


func vanilla_1903477885_update_enemy(enemy: Character):
	pass


func vanilla_1903477885_downscroll_ui():
	for strum_line in strums:
		strum_line.position.y *= -1
	
	$"Health Bar".position.y *= -1



func vanilla_1903477885_apply_underlay():
	var underlay: ColorRect = ColorRect.new()
	underlay.color = Color(0, 0, 0,
	SettingsManager.get_value(SettingsManager.SEC_PREFERENCES, "underlay_opacity"))
	underlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	underlay.position -= self.offset
	underlay.z_index = -1000
	
	add_child(underlay)


# ModLoader Hooks - The following code has been automatically added by the Godot Mod Loader.


func _ready():
	if _ModLoaderHooks.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_1903477885__ready, [], 3406395313)
	else:
		vanilla_1903477885__ready()


func _process(delta: float):
	if _ModLoaderHooks.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_1903477885__process, [delta], 950092667)
	else:
		vanilla_1903477885__process(delta)


func bump(strength: Vector2):
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_1903477885_bump, [strength], 4014241873)
	else:
		return vanilla_1903477885_bump(strength)


func update_player(player: Character):
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_1903477885_update_player, [player], 904101772)
	else:
		return vanilla_1903477885_update_player(player)


func update_enemy(enemy: Character):
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_1903477885_update_enemy, [enemy], 2226986653)
	else:
		return vanilla_1903477885_update_enemy(enemy)


func downscroll_ui():
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_1903477885_downscroll_ui, [], 1095642529)
	else:
		return vanilla_1903477885_downscroll_ui()


func apply_underlay():
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_1903477885_apply_underlay, [], 1380744870)
	else:
		return vanilla_1903477885_apply_underlay()
