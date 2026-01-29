@tool
@icon("symbol.svg")
extends Node2D
class_name AnimateSymbol

signal looped
signal finished

@export_placeholder("Name or Prefix") var symbol: String = "":
	set(value):
		if symbol != value:
			queue_redraw()
		symbol = value

@export var frame: int = 0:
	set(value):
		if atlases.is_empty():
			queue_redraw()
			frame = value
			return
		
		var length: int = get_animation_length()
		value = validate_frame(value, length)
		if frame != value:
			queue_redraw()
			frame = value

@export_range(0.0, 10.0, 0.01, "or_greater") var speed_scale: float = 1.0

@export var autoplay: bool = false
@export var playing: bool = false
@export var loop: bool = false
@export var loop_frame: int = 0

@export_group("Offset")

## Tries to center the current sprite based on the size of the frame.
## This may not work on certain formats like texture atlases for now
## due to them not providing any bounding box.
@export var centered: bool = true:
	set(value):
		if centered != value:
			queue_redraw()

		centered = value

@export var offset: Vector2 = Vector2.ZERO:
	set(value):
		if offset != value:
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
			queue_redraw()
		atlas_index = value

@export_tool_button("Cache Current", "Save") var atlas_cache: Callable = cache_current
@export_tool_button("Reparse Current", "Reload") var atlas_reload: Callable = reparse_current

var frame_timer: float = 0.0
var internal_canvas_items: Array[RID] = []
var last_atlases_size: int = 0
var adobe_atlas_material: ShaderMaterial = null


func _enter_tree() -> void:
	if autoplay and not Engine.is_editor_hint():
		playing = true


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
	if atlas_index > atlases.size() - 1:
		atlas_index = atlases.size() - 1
	var atlas: AnimateAtlas = atlases[atlas_index]
	if not is_instance_valid(atlas):
		return
	if atlas.wants_redraw():
		frame = frame
		queue_redraw()
	if atlas.wants_reload_list():
		notify_property_list_changed()
	
	if not playing:
		return
	
	var fps: float = atlas.get_framerate()
	frame_timer += delta * speed_scale
	if frame_timer >= 1.0 / fps:
		frame += floori(frame_timer * fps)
		frame_timer = wrapf(frame_timer, 0.0, 1.0 / fps)


func _draw() -> void:
	RenderingServer.canvas_item_clear(get_canvas_item())
	for rid: RID in internal_canvas_items:
		RenderingServer.canvas_item_clear(rid)
		RenderingServer.free_rid(rid)
	internal_canvas_items.clear()
	
	if atlases.is_empty():
		return
	if atlas_index > atlases.size() - 1:
		atlas_index = 0

	var atlas: AnimateAtlas = atlases[atlas_index]
	if not is_instance_valid(atlas):
		return
	
	var draw_info: AnimateDrawInfo = AnimateDrawInfo.new(
		symbol,
		frame,
		offset,
		get_transform(),
		internal_canvas_items
	)
	
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
		adobe_atlas_material = load("uid://bxdjijj35wput")
	
	draw_info.material = adobe_atlas_material
	atlas.draw_on(get_canvas_item(), draw_info)


func get_animation_length() -> int:
	if atlases.is_empty():
		return 0
	if atlas_index > atlases.size() - 1:
		atlas_index = 0

	var atlas: AnimateAtlas = atlases[atlas_index]
	if not is_instance_valid(atlas):
		return 0

	match atlas.format:
		"sparrow":
			return (atlas as SparrowAtlas).get_count_filtered(symbol)
		"adobe":
			return (atlas as AdobeAtlas).get_length_of(StringName(symbol))
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
			value = wrapi(value, loop_frame, length)
			emit_signal(&"looped")
		else:
			value = clampi(value, 0, length - 1)
			emit_signal(&"finished")
	if length == 0:
		value = 0

	return value


func cache_current() -> void:
	if not atlases.is_empty():
		var atlas: AnimateAtlas = atlases[atlas_index]
		if is_instance_valid(atlas):
			atlas.cache()


func reparse_current() -> void:
	if not atlases.is_empty():
		var atlas: AnimateAtlas = atlases[atlas_index]
		if is_instance_valid(atlas):
			atlas.parse()
			queue_redraw()
