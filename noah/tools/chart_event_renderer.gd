@icon("res://addons/at-icons/node2d/pencil.svg")
extends Node2D
class_name ChartEventRenderer
## Main RenderingServer manager for chart events.
## [br][b]Note:[/b] Does not support animated sprites.

const DEFAULT_TEXTURE: Texture = preload("res://addons/at-icons/node/help.svg")

@export var event_editor: bool = false

## Main reference for [ChartEdtior] scene
var chart_editor: ChartEditor
## Array of note packets.
var data: Array
## Array of [NoteRender] that are currently drawn
var drawn: Array[EventRender]
## Collected every frame, frees any [NoteRender]'s in the list
var garbage: Array[EventRender]

## Draws the notes in [member data] and clears everything else.
func refresh() -> void:
	garbage.append_array(drawn)
	drawn.clear()
	draw_events(data)

## Updates the position of each render in [member drawn].
func update_render_transforms() -> void:
	for render in drawn:
		render.update_transform()

## Draws a event packet and adds it to [member drawn].
func draw_event(packet: Array) -> void:
	var render: EventRender = EventRender.new(chart_editor, get_canvas_item())
	render.chart_editor = chart_editor
	render.time = packet[0]
	render.type = packet[1]
	render.track = NoahTools.array_get(packet, 3, 0)
	render.event_editor = event_editor
	
	# I am treating scroll speed as a multiplier that would've acted like the grid size for
	# sizing purposes
	render.numerator = int(chart_editor.conductor.get_time_change_at(render.time).y)
	drawn.append(render)

## Draws multiple event packets and adds them to [member drawn]. The size of 'tracks' and 'packets' need to be equal.
func draw_events(packets: Array) -> void:
	for packet in packets:
		draw_event(packet)

## Erases the first note with equal parameters.
func erase_note(packet: Array) -> void:
	if drawn.is_empty():
		return
	
	var i: int = drawn.find_custom(func(render: EventRender) -> bool:
		return (is_equal_approx(render.time, packet[0]) and render.type == packet[1] and render.track == NoahTools.array_get(packet, 3, 0)))
	
	if i != -1:
		erase_at(i)

## Erases the note at the given index in [member drawn]
func erase_at(index: int) -> void:
	if drawn.is_empty():
		return
	
	garbage.append(drawn.pop_at(index))

func _process(delta: float) -> void:
	for i in garbage.size():
		var trash: EventRender = garbage[i]
		trash.erase()
	
	garbage.clear()

class EventRender extends Node:
	var chart_editor: ChartEditor
	var symbol_rid: RID
	var label_rid: RID
	
	var symbol_texture: Texture2D
	var event_editor: bool = false
	var position: Vector2
	var time: float
	var type: String: set = set_event_type
	var track: int
	var length: float
	var numerator: int
	var grid_size: Vector2: get = get_grid_size
	var font: Font = load("uid://ddtgfc3a3xn5j")
	
	func _init(editor: ChartEditor, parent: RID) -> void:
		chart_editor = editor
		symbol_rid = RenderingServer.canvas_item_create()
		RenderingServer.canvas_item_set_parent(symbol_rid, parent)
		label_rid = RenderingServer.canvas_item_create()
		RenderingServer.canvas_item_set_parent(label_rid, symbol_rid)
		RenderingServer.canvas_item_set_z_index(label_rid, 10)
	
	func set_event_type(v: String) -> void:
		type = v
		if Constants.EVENT_DATA.has(v):
			if Constants.EVENT_DATA[v].has("texture"):
				symbol_texture = load(Constants.EVENT_DATA[v]["texture"])
			else:
				symbol_texture = DEFAULT_TEXTURE
		else:
			symbol_texture = DEFAULT_TEXTURE
		
		RenderingServer.canvas_item_clear(symbol_rid)
		NoahTools.set_texture_to_rid(symbol_rid, symbol_texture)
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
		if event_editor:
			var new_pos = Vector2(chart_editor.time_to_y_position(time) + grid_size.x / 2, chart_editor.grid.get_real_position(Vector2(0, track + 1.5)).y)
			new_pos += chart_editor.grid_layer.offset
			return new_pos
		else:
			var new_pos = Vector2(chart_editor.grid.get_real_position(Vector2(chart_editor.grid.columns - 0.5, 0)).x,
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
	
	## Erases all RIDS
	func erase() -> void:
		RenderingServer.free_rid(symbol_rid)
		RenderingServer.free_rid(label_rid)
