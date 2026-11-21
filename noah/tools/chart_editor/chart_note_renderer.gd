@icon("res://addons/at-icons/node2d/pencil.svg")
extends Node2D
class_name ChartNoteRenderer
## Main RenderingServer manager for chart notes.
## [br][b]Note:[/b] Does not support animated sprites.

var chart_editor: ChartEditor
var data: Array
var drawn: Array[NoteRender]
var garbage: Array[NoteRender]

## Draws the notes in [member data] and clears everything else.
func refresh() -> void:
	garbage.append_array(drawn)
	drawn.clear()
	draw_notes(data)

## Draws a note packet and adds it to [member drawn]
func draw_note(packet: Array) -> void:
	var render: NoteRender = NoteRender.new(chart_editor, get_canvas_item())
	render.chart_editor = chart_editor
	render.time = packet[0]
	render.length = packet[2]
	render.lane = packet[1]
	render.note_type = packet[3]
	# I am treating scroll speed as a multiplier that would've acted like the grid size for
	# sizing purposes
	render.scroll_speed = chart_editor.conductor.get_time_change_at(render.time).y
	render.direction = chart_editor.DIRECTIONS[render.lane % 4]
	render.animation = str(Constants.NOTE_TYPES.get(render.note_type, ""), render.direction)
	render.note_skin = chart_editor.note_skin
	drawn.append(render)

## Draws multiple note packet and adds them to [member drawn]
func draw_notes(packets: Array) -> void:
	for packet in packets:
		draw_note(packet)

func _process(delta: float) -> void:
	for i in garbage.size():
		var trash: NoteRender = garbage[i]
		trash.erase()
	
	garbage.clear()

class NoteRender extends Note:
	var chart_editor: ChartEditor
	var symbol_rid: RID
	var tail_rids: Array[RID]
	
	var symbol_texture: Texture2D
	var tail_texture: Texture2D
	
	func _init(editor: ChartEditor, parent: RID) -> void:
		chart_editor = editor
		grid_size = chart_editor.grid.get_gridspace_size()
		symbol_rid = RenderingServer.canvas_item_create()
		RenderingServer.canvas_item_set_parent(symbol_rid, parent)
	
	## Sets the skin to the given
	func set_note_skin(v: NoteSkin) -> void:
		note_skin = v
		symbol_texture = v.notes_texture.get_frame_texture(animation, 0)
		tail_texture = v.notes_texture.get_frame_texture(animation + &"_tail", 0)
		NoahTools.set_texture_to_rid(symbol_rid, symbol_texture)
		if note_skin.pixel_texture:
			RenderingServer.canvas_item_set_default_texture_filter(symbol_rid, RenderingServer.CANVAS_ITEM_TEXTURE_FILTER_NEAREST)
		else:
			RenderingServer.canvas_item_set_default_texture_filter(symbol_rid, RenderingServer.CANVAS_ITEM_TEXTURE_FILTER_DEFAULT)
		
		for rid in tail_rids:
			if note_skin.pixel_texture:
				RenderingServer.canvas_item_set_default_texture_filter(rid, RenderingServer.CANVAS_ITEM_TEXTURE_FILTER_NEAREST)
			else:
				RenderingServer.canvas_item_set_default_texture_filter(rid, RenderingServer.CANVAS_ITEM_TEXTURE_FILTER_DEFAULT)
		
		update_transform()
	
	func _process(delta: float) -> void:
		grid_size = chart_editor.grid.get_gridspace_size()
	
	func get_chart_position() -> Vector2:
		var new_pos = Vector2(chart_editor.grid.get_real_position(Vector2(1.5 + lane, 0)).x,
		chart_editor.time_to_y_position(time) + chart_editor.grid.get_gridspace_size().y / 2)
		new_pos += chart_editor.grid_layer.offset
		return new_pos
	
	## Updates the transform of all the RIDS.
	func update_transform() -> void:
		var symbol_scale: Vector2 = Vector2.ONE * grid_size.x / symbol_texture.get_width()
		var symbol_transform: Transform2D = Transform2D(0, symbol_scale, 0, get_chart_position() - grid_size / 2)
		RenderingServer.canvas_item_set_transform(symbol_rid, symbol_transform)
		# Tile tail rendering
		for rid in tail_rids:
			RenderingServer.free_rid(rid)
		
		tail_rids.clear()
		var total_length: float = grid_size.y * length * scroll_speed / symbol_scale.y
		var tail_height: int = tail_texture.get_width()
		var tail_transform: Transform2D = Transform2D(PI / -2, Vector2.ONE, 0,
		grid_size / 2 / symbol_scale - Vector2(tail_texture.get_height() / 2, 0))
		while total_length > 0:
			var chunk_height: float = min(total_length, tail_height)
			var rid: RID = RenderingServer.canvas_item_create()
			RenderingServer.canvas_item_set_parent(rid, symbol_rid)
			RenderingServer.canvas_item_set_draw_behind_parent(rid, true)
			RenderingServer.canvas_item_set_transform(rid, tail_transform)
			RenderingServer.canvas_item_add_texture_rect_region(rid, Rect2(Vector2.ZERO, tail_texture.get_size()),
			tail_texture.get_rid(), Rect2(Vector2.ZERO, Vector2(chunk_height, tail_texture.get_height())))
			if note_skin.pixel_texture:
				RenderingServer.canvas_item_set_default_texture_filter(rid, RenderingServer.CANVAS_ITEM_TEXTURE_FILTER_NEAREST)
			else:
				RenderingServer.canvas_item_set_default_texture_filter(rid, RenderingServer.CANVAS_ITEM_TEXTURE_FILTER_DEFAULT)
			
			tail_rids.append(rid)
			total_length -= chunk_height
			tail_transform.origin.y += chunk_height
	
	## Erases all RIDS
	func erase() -> void:
		RenderingServer.free_rid(symbol_rid)
		for rid in tail_rids:
			RenderingServer.free_rid(rid)
	
	func _exit_tree() -> void:
		erase()
