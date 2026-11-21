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
	
	var symbol_texture: Texture
	var tail_texture: Texture
	var end_texture: Texture
	
	func _init(editor: ChartEditor, parent: RID) -> void:
		chart_editor = editor
		grid_size = chart_editor.grid.get_gridspace_size()
		symbol_rid = RenderingServer.canvas_item_create()
		RenderingServer.canvas_item_set_parent(symbol_rid, parent)
	
	## Sets the skin to the given
	func set_note_skin(v: NoteSkin) -> void:
		note_skin = v
		symbol_texture = v.notes_texture.get_frame_texture(
			str(Constants.NOTE_TYPES.get(note_type, ""), direction), 0)
		NoahTools.set_texture_to_rid(symbol_rid, symbol_texture)
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
		var scaler: Vector2 = grid_size / symbol_texture.get_size()
		var symbol_scale: Vector2 = Vector2.ONE * minf(scaler.x, scaler.y)
		RenderingServer.canvas_item_set_transform(symbol_rid, Transform2D(0, symbol_scale, 0, get_chart_position() - grid_size / 2))
	
	## Erases all RIDS
	func erase() -> void:
		RenderingServer.free_rid(symbol_rid)
		for rid in tail_rids:
			RenderingServer.free_rid(rid)
	
	func _exit_tree() -> void:
		erase()
