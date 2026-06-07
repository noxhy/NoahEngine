@tool
@icon("symbol.svg")
extends Node2D
class_name AnimateSymbol


@export_placeholder("Name or Prefix") var symbol: String = "":
	set(value):
		if symbol != value:
			frame_dirty = true
			queue_redraw()

		symbol = value

@export var frame: int = 0:
	set(value):
		if atlases.is_empty():
			frame = value
			queue_redraw()
			return

		var length: int = get_animation_length()
		value = validate_frame(value, length)

		if frame != value:
			frame_dirty = true
			queue_redraw()

		frame = value

		if not internal_setting_frame:
			frame_timer = 0.0

@export_range(0.0, 10.0, 0.01, "or_greater") var speed_scale: float = 1.0

@export var autoplay: bool = false
@export var playing: bool = false
@export var loop: bool = false

@export_group("Offset")

## Tries to center the current sprite based on the size of the frame.
## This may not work on certain formats like texture atlases for now
## due to them not providing any bounding box.
@export var centered: bool = true:
	set(value):
		if centered != value:
			frame_dirty = true
			queue_redraw()

		centered = value

@export var offset: Vector2 = Vector2.ZERO:
	set(value):
		if offset != value:
			frame_dirty = true
			queue_redraw()

		offset = value

@export_group("Atlas")
@export var atlases: Array[AnimateAtlas] = []
@export var atlas_index: int = 0:
	set(value):
		if value < 0:
			value = absi(value)
		if not atlases.is_empty():
			value %= atlases.size()

		if atlas_index != value:
			notify_property_list_changed()

			frame_dirty = true
			queue_redraw()

		atlas_index = value

@export_tool_button("Cache Current", "Save") var atlas_cache: Callable = cache_current
@export_tool_button("Reparse Current", "Reload") var atlas_reload: Callable = reparse_current
@export_tool_button("Make AnimationLibrary", "AnimationLibrary") var atlas_make_player: Callable = make_player_from_current

var frame_timer: float = 0.0
var internal_canvas_items: Array[RID] = []
var last_atlases_size: int = 0
var adobe_atlas_material: ShaderMaterial = null
var adobe_additive_material: ShaderMaterial = null
var last_screen_transform: Transform2D = Transform2D()
var internal_setting_frame: bool = false
var frame_dirty: bool = false
var last_light_mask: int = 0
var last_visibilty_layer: int = 0


func _enter_tree() -> void:
	if autoplay and not Engine.is_editor_hint():
		playing = true

	last_screen_transform = get_backbuffer_transform()

	set_notify_local_transform(true)
	set_notify_transform(true)


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSFORM_CHANGED or what == NOTIFICATION_LOCAL_TRANSFORM_CHANGED:
		var atlas := get_atlas()
		if not atlas:
			return

		last_screen_transform = get_backbuffer_transform()

		if atlas is AdobeAtlas:
			atlas.use_backbuffer_cache = true

		queue_redraw()


func _validate_property(property: Dictionary) -> void:
	if property.name == "symbol":
		property.hint = PROPERTY_HINT_PLACEHOLDER_TEXT
		property.hint_string = "Name or Prefix"

		if atlases.is_empty():
			return
		var atlas: AnimateAtlas = atlases[atlas_index]
		if not is_instance_valid(atlas):
			return
		if atlas is AdobeAtlas:
			property.hint = PROPERTY_HINT_ENUM
			property.hint_string = atlas.get_symbols()
		elif atlas is SparrowAtlas:
			if atlas.symbols.is_empty():
				return

			property.hint = PROPERTY_HINT_ENUM
			property.hint_string = atlas.get_symbols()

	if property.name == "atlas_index":
		property.hint = PROPERTY_HINT_ENUM
		property.hint_string = ""

		for i: int in atlases.size():
			var atlas: AnimateAtlas = atlases[i]
			if not is_instance_valid(atlas):
				property.hint_string += "#%d - null" % [i]
				continue

			property.hint_string += "#%d - %s" % [i, atlas.get_filename()]

			if i != atlases.size() - 1:
				property.hint_string += ","


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
	if frame_timer >= 1.0 / fps:
		var amount: int = floori(frame_timer * fps)
		if frame == get_animation_length() - 1 and (not loop) and amount > 0:
			internal_setting_frame = false
			playing = false
			return

		frame += amount
		frame_timer = wrapf(frame_timer, 0.0, 1.0 / fps)

	internal_setting_frame = false


func _draw() -> void:
	var atlas: AnimateAtlas = get_atlas()
	if not is_instance_valid(atlas):
		return

	var draw_info: AnimateDrawInfo = AnimateDrawInfo.new(
		symbol,
		frame,
		offset,
		get_transform(),
		internal_canvas_items
	)

	draw_info.screen_transform = get_backbuffer_transform()
	draw_info.light_mask = light_mask
	draw_info.visibility_layer = visibility_layer

	if atlas is AdobeAtlas and frame_dirty:
		atlas.use_backbuffer_cache = false

	if atlas is AdobeAtlas and atlas.use_backbuffer_cache:
		_draw_adobe(atlas as AdobeAtlas, draw_info)
		return

	frame_dirty = false
	RenderingServer.canvas_item_clear(get_canvas_item())

	for rid: RID in internal_canvas_items:
		if not rid.is_valid():
			continue

		RenderingServer.free_rid(rid)

	internal_canvas_items.clear()
	match atlas.format:
		"sparrow":
			_draw_sparrow(atlas as SparrowAtlas, draw_info)
		"adobe":
			_draw_adobe(atlas as AdobeAtlas, draw_info)
		_:
			pass


func _draw_sparrow(atlas: SparrowAtlas, draw_info: AnimateDrawInfo) -> void:
	if not is_instance_valid(atlas.texture):
		return
	if get_animation_length() == 0:
		return

	var sparrow_frame: SparrowFrame = atlas.get_frame_filtered(frame, symbol)
	if not is_instance_valid(sparrow_frame):
		return

	if centered:
		if sparrow_frame.offset.size != Vector2i.ZERO:
			draw_info.offset -= sparrow_frame.offset.size / 2.0
		else:
			draw_info.offset -= sparrow_frame.region.size / 2.0
	atlas.draw_on(get_canvas_item(), draw_info)


func _draw_adobe(atlas: AdobeAtlas, draw_info: AnimateDrawInfo) -> void:
	if not is_instance_valid(adobe_atlas_material):
		adobe_atlas_material = load("res://addons/gdanimate-rewrite-main/atlas_material.tres")
	if not is_instance_valid(adobe_additive_material):
		adobe_additive_material = load("res://addons/gdanimate-rewrite-main/additive_material.tres")

	draw_info.material = adobe_atlas_material
	draw_info.additive_material = adobe_additive_material
	atlas.draw_on(get_canvas_item(), draw_info)


func get_animation_length(use_custom: bool = false, custom: String = "") -> int:
	var atlas: AnimateAtlas = get_atlas()
	if not is_instance_valid(atlas):
		return 0

	match atlas.format:
		"sparrow":
			return (atlas as SparrowAtlas).get_count_filtered(custom if use_custom else symbol)
		"adobe":
			return (atlas as AdobeAtlas).get_length_of(StringName(custom if use_custom else symbol))
		_:
			pass

	return 0


func validate_frame(value: int, length: int = -1) -> int:
	if length == -1:
		length = get_animation_length()

	if value < 0:
		value = 0
	if value > length - 1:
		if loop:
			value = wrapi(value, 0, length)
		else:
			value = clampi(value, 0, length - 1)
	if length == 0:
		value = 0

	return value


func make_player_from_current() -> void:
	var atlas := get_atlas()

	if not atlas:
		return

	var library := AnimationLibrary.new()

	var symbols: Array = []
	var fps := atlas.get_framerate()

	if atlas is AdobeAtlas:
		symbols = atlas.symbols.keys()
	elif atlas is SparrowAtlas:
		symbols = atlas.symbols

	for cur_symbol in symbols:
		var str := String(cur_symbol)
		var length := get_animation_length(true, str)

		var animation := Animation.new()
		animation.length = float(length) / fps

		animation.add_track(Animation.TYPE_VALUE)
		animation.track_set_interpolation_type(0, Animation.INTERPOLATION_NEAREST)
		animation.track_set_path(0, ^"./:symbol")
		animation.track_insert_key(0, 0.0, str)

		animation.add_track(Animation.TYPE_VALUE)
		animation.track_set_interpolation_type(1, Animation.INTERPOLATION_NEAREST)
		animation.track_set_path(1, ^"./:frame")

		for i: int in length:
			animation.track_insert_key(1, float(i) / fps, i)

		animation.add_track(Animation.TYPE_VALUE)
		animation.track_set_path(2, ^"./:offset")
		animation.track_insert_key(2, 0.0, Vector2.ZERO)

		library.add_animation(str.replace("/", ";"), animation)

	var path := "%s/%s_LIBRARY.res" % [atlas.get_base_dir(), atlas.get_filename()]
	if ResourceLoader.exists(path):
		library.take_over_path(path)

	ResourceSaver.save(library, path, ResourceSaver.FLAG_COMPRESS | ResourceSaver.FLAG_REPLACE_SUBRESOURCE_PATHS)


func cache_current() -> void:
	var atlas: AnimateAtlas = get_atlas()
	if is_instance_valid(atlas):
		atlas.cache()


func reparse_current() -> void:
	var atlas: AnimateAtlas = get_atlas()
	if is_instance_valid(atlas):
		atlas.parse()
		queue_redraw()


func get_atlas() -> AnimateAtlas:
	if atlases.is_empty():
		return null
	if atlas_index > atlases.size() - 1:
		atlas_index = atlases.size() - 1

	var atlas: AnimateAtlas = atlases[atlas_index]
	return atlas


func get_backbuffer_transform() -> Transform2D:
	return get_viewport().get_stretch_transform() * get_global_transform_with_canvas()
