extends Note
## This note type is better for performance however the sustain isn't friendly
## for modcharts.
class_name BasicNote

@onready var tail = $Tail
@onready var end = $Tail/End

var start_length: float = 0.0

var can_press: bool = false

var time_difference: float = INF

var on_screen = false

# Applying Note Skin
func _ready(): 
	$Note.sprite_frames = note_skin.notes_texture
	if note_skin.animation_names != null: 
		if note_skin.animation_names.keys().size() > 0: 
			$Note.animation_names.merge(note_skin.animation_names, true)
	
	$Note.play_animation(animation)
	
	var tail_animation = $Note.get_real_animation(StringName(animation + " tail"))
	if tail_animation and tail:
		tail.texture = note_skin.notes_texture.get_frame_texture(tail_animation, 0)
	
	var end_animation = $Note.get_real_animation(StringName(animation + " end"))
	if end_animation and end:
		end.texture = note_skin.notes_texture.get_frame_texture(end_animation, 0)
		end.size = end.texture.get_size()
	
	$Note.offsets = note_skin.offsets
	
	if note_skin.pixel_texture: 
		$Note.texture_filter = TEXTURE_FILTER_NEAREST
		tail.texture_filter = TEXTURE_FILTER_NEAREST
	
	scale = Vector2(1, 1)
	$Note.scale = Vector2.ONE * note_skin.notes_scale
	
	if tail:
		tail.scale = Vector2.ONE * note_skin.notes_scale
		tail.position.x = tail.texture.get_height() / 2.0 * tail.scale.x
	
	if end:
		end.scale.x = note_skin.notes_scale


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time_difference = (time - GameManager.offset) - GameManager.song_position
	
	if length > 0:
		var line_length = length * scroll_speed * grid_size.y
		tail.visible = true
		tail.scale.x = scroll
		tail.size.x = line_length
		end.position.x = line_length
	else:
		tail.visible = false


func update_y():
	position.y = PIXELS_PER_SECOND * time_difference * scroll_speed * scroll
	var grid_scaler = PIXELS_PER_SECOND * GameManager.seconds_per_beat
	grid_size.y = grid_scaler
