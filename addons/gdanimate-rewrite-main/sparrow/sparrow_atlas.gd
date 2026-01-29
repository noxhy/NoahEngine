@tool
extends AnimateAtlas
class_name SparrowAtlas


@export var texture: Texture2D = null
@export_file_path("*.xml") var sparrow_path: String = "":
	set(v):
		sparrow_path = v
		parse()

@export var framerate: float = 24.0

@export_storage var frames: Array[SparrowFrame] = []
@export_storage var symbols: PackedStringArray = []


func parse() -> void:
	super()

	frames.clear()
	format = "sparrow"
	symbols = []

	var basename: String = sparrow_path.get_basename()
	var cache_path: String = "%s.res" % [basename]
	if ResourceLoader.exists(cache_path):
		var cached: SparrowAtlas = load(cache_path)
		framerate = cached.framerate
		frames = cached.frames
		texture = cached.texture
		symbols = cached.symbols
		return

	if not FileAccess.file_exists(sparrow_path):
		printerr("Failed to find sparrow at path \"%s\"!" % [sparrow_path])
		return

	var xml: XMLParser = XMLParser.new()
	var err: Error = OK
	err = xml.open(sparrow_path)
	if err != OK:
		printerr("Failed to open XML, error code: %s!" % [err])
		return

	while xml.read() != ERR_FILE_EOF:
		if xml.get_node_type() != XMLParser.NODE_ELEMENT:
			continue

		var node_name: String = xml.get_node_name().to_lower()
		if node_name == "textureatlas" and not is_instance_valid(texture):
			texture = load("%s/%s" % [
					sparrow_path.get_base_dir(),
					xml.get_named_attribute_value_safe("imagePath")
			])
		if node_name == "subtexture":
			var frame: SparrowFrame = SparrowFrame.new()
			frame.name = xml.get_named_attribute_value_safe("name")
			frame.region = Rect2i(
				Vector2i(
					int(xml.get_named_attribute_value_safe("x")),
					int(xml.get_named_attribute_value_safe("y"))
				),
				Vector2i(
					int(xml.get_named_attribute_value_safe("width")),
					int(xml.get_named_attribute_value_safe("height"))
				))
			if xml.has_attribute("frameX"):
				frame.offset = Rect2i(
					Vector2i(
						int(xml.get_named_attribute_value_safe("frameX")),
						int(xml.get_named_attribute_value_safe("frameY"))
					),
					Vector2i(
						int(xml.get_named_attribute_value_safe("frameWidth")),
						int(xml.get_named_attribute_value_safe("frameHeight"))
					)
				)

			frame.rotated = xml.get_named_attribute_value_safe("rotated") == "true"
			frames.push_back(frame)
	
	# Thank you Friday Night Funkin' Base Game Assets.
	frames.sort_custom(func(a: SparrowFrame, b: SparrowFrame) -> bool:
		if a.name.length() < 4:
			return false
		if b.name.length() < 4:
			return true
		
		var a_numbers: String = a.name.right(4)
		if not a_numbers.is_valid_int():
			return false
		
		var b_numbers: String = b.name.right(4)
		if not b_numbers.is_valid_int():
			return true
		
		return a_numbers.to_int() < b_numbers.to_int()
	)
	
	for frame: SparrowFrame in frames:
		if frame.name.length() < 4:
			continue
		var numbers: String = frame.name.right(4)
		var cutout: String = frame.name.left(-4)
		if (not symbols.has(cutout)) and numbers.is_valid_int():
			symbols.push_back(cutout)


func cache() -> void:
	super()

	var basename: String = sparrow_path.get_basename()
	take_over_path("%s.res" % [basename])
	ResourceSaver.save(self, "%s.res" % [basename], ResourceSaver.FLAG_COMPRESS + ResourceSaver.FLAG_REPLACE_SUBRESOURCE_PATHS)


func get_frame_filtered(frame: int, prefix: String) -> SparrowFrame:
	var sparrow_frame: SparrowFrame = null
	for i: int in frames.size():
		var cur_frame: SparrowFrame = frames[i]
		var skip_frame: bool = false
		if symbols.has(prefix):
			skip_frame = not (
				cur_frame.name.begins_with(prefix) and
				(cur_frame.name.length() - 4 == prefix.length()) and
				(cur_frame.name.right(4).is_valid_int())
			)
		else:
			skip_frame = not cur_frame.name.begins_with(prefix)
		
		if skip_frame:
			continue
		
		if frame <= 0:
			sparrow_frame = cur_frame
			break
		
		frame -= 1
	
	return sparrow_frame


func get_count_filtered(prefix: String) -> int:
	var count: int = 0
	for frame: SparrowFrame in frames:
		if symbols.has(prefix):
			count += int(
				frame.name.begins_with(prefix) and
				(frame.name.length() - 4 == prefix.length()) and
				(frame.name.right(4).is_valid_int())
			)
		else:
			count += int(frame.name.begins_with(prefix))
	
	return count


func draw_on(canvas_item: RID, draw_info: AnimateDrawInfo) -> void:
	super(canvas_item, draw_info)
	
	var sparrow_frame: SparrowFrame = get_frame_filtered(draw_info.frame, draw_info.symbol)
	if not is_instance_valid(sparrow_frame):
		push_warning("Drawing invalid frame!")
		return

	var offset: Vector2 = -sparrow_frame.offset.position
	offset += draw_info.offset
	if sparrow_frame.rotated:
		RenderingServer.canvas_item_add_set_transform(canvas_item,
			Transform2D(
				-PI / 2.0, #deg_to_rad(-90.0),
				Vector2(
					offset.x,
					sparrow_frame.region.size.x + offset.y
				)
			)
		)

	RenderingServer.canvas_item_add_texture_rect_region(canvas_item, 
		Rect2(
			offset if not sparrow_frame.rotated else Vector2.ZERO,
			sparrow_frame.region.size
		),
		texture, sparrow_frame.region
	)


func get_framerate() -> float:
	return framerate


func get_filename() -> String:
	return sparrow_path.get_file()


func get_symbols() -> String:
	var string: String = ""
	symbols.sort()
	for symbol_name: String in symbols:
		string += "%s," % [symbol_name.json_escape()]
	if not string.is_empty():
		string.remove_char(string.length() - 1)
	
	return string
