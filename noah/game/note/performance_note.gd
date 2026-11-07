extends BasicNote
class_name PerformanceNote
# UNUSED JUST A TEST CURRENTLY

var note_rid: RID
var tail_rid: RID
var end_rid: RID

# Applying Note Skin
func _ready() -> void:
	tail_rid = RenderingServer.canvas_item_create()
	end_rid = RenderingServer.canvas_item_create()
	note_rid = RenderingServer.canvas_item_create()
	
	RenderingServer.canvas_item_set_parent(tail_rid, get_canvas_item())
	RenderingServer.canvas_item_set_parent(end_rid, get_canvas_item())
	RenderingServer.canvas_item_set_parent(note_rid, get_canvas_item())

	
	var note_anim = note_skin.notes_texture.get_frame_texture(animation, 0)
	set_texture_to_rid(note_rid, note_anim)
	
	var tail_anim = note_skin.notes_texture.get_frame_texture(animation + &"_tail", 0)
	set_texture_to_rid(tail_rid, tail_anim)
	
	var end_anim = note_skin.notes_texture.get_frame_texture(animation + &"_end", 0)
	set_texture_to_rid(end_rid, end_anim)
	
	var vec2_scale = note_skin.notes_scale * Vector2.ONE
	RenderingServer.canvas_item_set_transform(note_rid, 
		Transform2D(rotation, vec2_scale, skew, (-note_anim.get_size() / 2.0) * vec2_scale))
	
	RenderingServer.canvas_item_set_modulate(tail_rid, Color(1.0, 1.0, 1.0, note_skin.sustain_opacity))
	RenderingServer.canvas_item_set_modulate(end_rid, Color(1.0, 1.0, 1.0, note_skin.sustain_opacity))
	
	load_basic_type()

func set_texture_to_rid(_rid: RID, texture: Texture2D):
	if texture is AtlasTexture:
		RenderingServer.canvas_item_add_texture_rect_region(_rid, 
			Rect2(Vector2.ZERO, texture.get_size()), 
				texture.get_rid(),
				texture.region
		)
	else:
		RenderingServer.canvas_item_add_texture_rect(_rid, Rect2(Vector2.ZERO, texture.get_size()), texture.get_rid())
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time_difference = time - GameManager.song_position
	update()


func update() -> void:
	default_update()


func default_update() -> void:
	
	if !holding:
		position.y = PIXELS_PER_SECOND * time_difference * scroll_speed * scroll
		var grid_scaler: float = PIXELS_PER_SECOND * GameManager.conductor.seconds_per_beat
		grid_size.y = grid_scaler
	else:
		position.y = 0
		RenderingServer.canvas_item_set_visible(note_rid, false)
		
	
	if length <= 0:
		RenderingServer.canvas_item_set_visible(tail_rid, false)
		RenderingServer.canvas_item_set_visible(end_rid, false)
		return
		
	var line_length: float = length * scroll_speed * grid_size.y
	
	var vec2_scale = note_skin.notes_scale * Vector2.ONE
	var tail_anim = note_skin.notes_texture.get_frame_texture(animation + &"_tail", 0)

	RenderingServer.canvas_item_set_transform(tail_rid, Transform2D(deg_to_rad(-90), 
		vec2_scale * Vector2(line_length, 1.0), 
		0.0, 
		Vector2(-tail_anim.get_size().y / 2.0, 0.0) * vec2_scale)
	)
	
	var end_anim = note_skin.notes_texture.get_frame_texture(animation + &"_end", 0)
	
	RenderingServer.canvas_item_set_transform(end_rid, Transform2D(deg_to_rad(-90), 
		vec2_scale, 
		0.0, 
		(Vector2(-end_anim.get_size().y / 2.0, 0.0) - Vector2(0.0, line_length))  * vec2_scale)
	)


func load_basic_type() -> void:
	match note_type:
		"no_animation":
			no_animation = true
		"alt_prefix":
			anim_prefix = 'alt_'


func apply_miss_effect() -> void:
	modulate *= 2
	modulate.a = min(modulate.a / 2, 0.5)

func _exit_tree() -> void:
	RenderingServer.free_rid(note_rid)
	RenderingServer.free_rid(tail_rid)
	RenderingServer.free_rid(end_rid)
