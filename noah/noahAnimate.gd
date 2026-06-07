@tool
extends AnimateSymbol
class_name NoahAnimate

signal animation_finished
signal animation_looped

var frame_progress: float

func _process(delta: float) -> void:
	if atlases.size() != last_atlases_size:
		last_atlases_size = atlases.size()
		notify_property_list_changed()
	if atlases.is_empty():
		frame = 0
		return

	var atlas: AnimateAtlas = get_atlas()
	if not is_instance_valid(atlas):
		return
	
	if last_light_mask != light_mask:
		last_light_mask = light_mask
		queue_redraw()
	if last_visibilty_layer != visibility_layer:
		last_visibilty_layer = visibility_layer
		queue_redraw()

	if atlas.wants_redraw():
		queue_redraw()
	elif last_screen_transform != get_backbuffer_transform() and not frame_dirty:
		last_screen_transform = get_backbuffer_transform()
	
		if atlas is AdobeAtlas:
			atlas.use_backbuffer_cache = true
		
		queue_redraw()
		
	if atlas.wants_reload_list():
		notify_property_list_changed()

	if not playing:
		return

	internal_setting_frame = true

	var fps: float = atlas.get_framerate()
	frame_timer += delta * speed_scale
	
	var frame_time: float = 1.0 / fps
	
	frame_progress = frame_timer / frame_time
	if frame_timer >= frame_time:
		var amount: int = floori(frame_timer * fps)
		if frame == get_animation_length() - 1 and (not loop) and amount > 0:
			internal_setting_frame = false
			playing = false
			animation_finished.emit()
			return

		frame += amount
		frame_timer = wrapf(frame_timer, 0.0, 1.0 / fps)

	internal_setting_frame = false


func validate_frame(value: int, length: int = -1) -> int:
	if length == -1:
		length = get_animation_length()

	if value < 0:
		value = 0
	if value > length - 1:
		if loop:
			value = wrapi(value, 0, length)
			animation_looped.emit()
		else:
			value = clampi(value, 0, length - 1)
	if length == 0:
		value = 0

	return value
