@icon("res://addons/at-icons/node2d/pencil.svg")
extends Node2D
class_name ChartNoteRenderer
## Main RenderingServer manager for chart notes.
## [br][b]Note:[/b] Does not support animated sprites.

## Main reference for [ChartEdtior] scene
var chart_editor: ChartEditor
## Array of note packets.
var data: Array
## Array of [NoteRender] that are currently drawn
var drawn: Array[NoteRender]
## Collected every frame, frees any [NoteRender]'s in the list
var garbage: Array[NoteRender]

## Draws the notes in [member data] and clears everything else.
func refresh() -> void:
	garbage.append_array(drawn)
	drawn.clear()
	draw_notes(data)

## Sets the note skin of each render in [member drawn].
func set_render_skin(note_skin: NoteSkin) -> void:
	for render in drawn:
		render.note_skin = note_skin

## Updates the position of each render in [member drawn].
func update_render_transforms() -> void:
	for render in drawn:
		render.update_transform()

## Draws a note packet and adds it to [member drawn]
func draw_note(packet: Array) -> void:
	var render: NoteRender = NoteRender.new(chart_editor, get_canvas_item())
	render.chart_editor = chart_editor
	render.time = packet[0]
	render.length = packet[2]
	render.lane = packet[1]
	render.type = packet[3]
	# I am treating scroll speed as a multiplier that would've acted like the grid size for
	# sizing purposes
	render.numerator = int(chart_editor.conductor.get_time_change_at(render.time).y)
	render.direction = chart_editor.DIRECTIONS[render.lane % 4]
	render.animation = str(Constants.NOTE_TYPES.get(render.type, ""), render.direction)
	render.note_skin = chart_editor.note_skin
	drawn.append(render)

## Draws multiple note packet and adds them to [member drawn]
func draw_notes(packets: Array) -> void:
	for packet in packets:
		draw_note(packet)

## Erases the first note with equal parameters.
func erase_note(packet: Array) -> void:
	if drawn.is_empty():
		return
	
	var i: int = drawn.find_custom(func(render: NoteRender) -> bool:
		return (is_equal_approx(render.time, packet[0]) and render.lane == packet[1] and is_equal_approx(render.length, packet[2]) and render.type == packet[3]))
	
	if i != -1:
		erase_at(i)

## Erases the note at the given index in [member drawn]
func erase_at(index: int) -> void:
	if drawn.is_empty():
		return
	
	garbage.append(drawn.pop_at(index))

func _process(delta: float) -> void:
	for i in garbage.size():
		var trash: NoteRender = garbage[i]
		trash.erase()
	
	garbage.clear()

class NoteRender extends Node:
	var chart_editor: ChartEditor
	var symbol_rid: RID
	var tail_rid: RID
	var label_rid: RID
	
	var symbol_texture: Texture2D
	var tail_texture: Texture2D
	
	var position: Vector2
	var time: float
	var lane: int
	var length: float
	var type: String
	var numerator: int
	var grid_size: Vector2: get = get_grid_size
	var note_skin: NoteSkin: set = set_note_skin
	var animation: StringName
	var direction: String
	var font: Font = load("uid://ddtgfc3a3xn5j")
	
	func _init(editor: ChartEditor, parent: RID) -> void:
		chart_editor = editor
		symbol_rid = RenderingServer.canvas_item_create()
		RenderingServer.canvas_item_set_parent(symbol_rid, parent)
		tail_rid = RenderingServer.canvas_item_create()
		RenderingServer.canvas_item_set_parent(tail_rid, symbol_rid)
		RenderingServer.canvas_item_set_draw_behind_parent(tail_rid, true)
		label_rid = RenderingServer.canvas_item_create()
		RenderingServer.canvas_item_set_parent(label_rid, symbol_rid)
		RenderingServer.canvas_item_set_z_index(label_rid, 10)
	
	## Sets the skin to the given
	func set_note_skin(v: NoteSkin) -> void:
		note_skin = v
		symbol_texture = v.notes_texture.get_frame_texture(animation, 0)
		tail_texture = v.notes_texture.get_frame_texture(animation + &"_tail", 0)
		RenderingServer.canvas_item_clear(symbol_rid)
		NoahTools.set_texture_to_rid(symbol_rid, symbol_texture)
		if note_skin.pixel_texture:
			RenderingServer.canvas_item_set_default_texture_filter(symbol_rid, RenderingServer.CANVAS_ITEM_TEXTURE_FILTER_NEAREST)
			RenderingServer.canvas_item_set_default_texture_filter(tail_rid, RenderingServer.CANVAS_ITEM_TEXTURE_FILTER_NEAREST)
		else:
			RenderingServer.canvas_item_set_default_texture_filter(symbol_rid, RenderingServer.CANVAS_ITEM_TEXTURE_FILTER_DEFAULT)
			RenderingServer.canvas_item_set_default_texture_filter(tail_rid, RenderingServer.CANVAS_ITEM_TEXTURE_FILTER_DEFAULT)
		
		update_transform()
	
	## Returns the initals of the [member type].
	func abbreviate_type() -> String:
		if type.is_empty():
			return ''
		
		var split: PackedStringArray = type.capitalize().split(" ")
		var output: String = ''
		for i in range(0, min(2, split.size())):
			output += split[i][0]
		
		return output
	
	## Returns the gridspace size from the chart editor
	func get_grid_size() -> Vector2:
		return chart_editor.grid.get_gridspace_size()
	
	## Returns the proper position of the note in the gridspace.
	func get_chart_position() -> Vector2:
		var new_pos = Vector2(chart_editor.grid.get_real_position(Vector2(1.5 + lane, 0)).x,
		chart_editor.time_to_y_position(time) + grid_size.y / 2)
		new_pos += chart_editor.grid_layer.offset
		return new_pos
	
	## Updates the transform of all the RIDS.
	func update_transform() -> void:
		var symbol_scale: Vector2 = grid_size.x / symbol_texture.get_width() * Vector2.ONE
		var symbol_transform: Transform2D = Transform2D(0, symbol_scale, 0, get_chart_position() - grid_size / 2)
		RenderingServer.canvas_item_set_transform(symbol_rid, symbol_transform)
		position = symbol_transform.origin
		
		RenderingServer.canvas_item_clear(label_rid)
		var text_pos: Vector2 = Vector2(0, (grid_size.y / 2 + (font.get_ascent() - font.get_descent()) / 2) / symbol_scale.y)
		var width: float = grid_size.x / symbol_scale.x
		var font_size: int = floori(16 / symbol_scale.x)
		font.draw_string_outline(label_rid, text_pos, abbreviate_type(), HORIZONTAL_ALIGNMENT_CENTER, width, font_size, int(4 / symbol_scale.x), Color.BLACK)
		font.draw_string(label_rid, text_pos, abbreviate_type(), HORIZONTAL_ALIGNMENT_CENTER, width, font_size, NoahTools.generate_colour_from_string(type))
		
		var total_length: float = grid_size.y * length * numerator / symbol_scale.y
		var tail_height: int = tail_texture.get_width()
		var tail_transform: Transform2D = Transform2D(PI / -2, Vector2.ONE, 0,
		grid_size / (2 * symbol_scale) - Vector2(tail_texture.get_height() / 2, 0))
		RenderingServer.canvas_item_clear(tail_rid)
		RenderingServer.canvas_item_set_transform(tail_rid, tail_transform)
		
		var segment_rect: Rect2 = Rect2(Vector2.ZERO, tail_texture.get_size())
		while total_length > 0:
			var chunk_height: float = min(total_length, tail_height)
			RenderingServer.canvas_item_add_texture_rect_region(tail_rid, segment_rect,
			tail_texture.get_rid(), Rect2(Vector2.ZERO, Vector2(tail_height - chunk_height, tail_texture.get_height())))
			
			total_length -= chunk_height
			segment_rect.position.x -= chunk_height
	
	## Erases all RIDS
	func erase() -> void:
		RenderingServer.free_rid(symbol_rid)
		RenderingServer.free_rid(tail_rid)
		RenderingServer.free_rid(label_rid)
