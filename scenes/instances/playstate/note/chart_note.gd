extends BasicNote
class_name ChartNote

# Applying Note Skin
func _ready(): 
	$Note.sprite_frames = note_skin.notes_texture
	if note_skin.animation_names != null: 
		if note_skin.animation_names.keys().size() > 0: 
			$Note.animation_names.merge(note_skin.animation_names, true)
	
	$Note.play_animation(animation)
	
	var tail_animation = $Note.get_real_animation(StringName(animation + " tail"))
	if tail_animation:
		tail.texture = note_skin.notes_texture.get_frame_texture(tail_animation, 0)
	
	var end_animation = $Note.get_real_animation(StringName(animation + " end"))
	if end_animation:
		tail.end_texture = note_skin.notes_texture.get_frame_texture(end_animation, 0)
	
	$Note.offsets = note_skin.offsets
	
	if note_skin.pixel_texture: 
		$Note.texture_filter = TEXTURE_FILTER_NEAREST
		tail.texture_filter = TEXTURE_FILTER_NEAREST
	
	scale = Vector2(1, 1)
	$Note.scale = grid_size / (Vector2($Note.sprite_frames.get_frame_texture($Note.animation, 0).get_width(), $Note.sprite_frames.get_frame_texture($Note.animation, 0).get_height()))
	tail.width = note_skin.sustain_width * $Note.scale.x
	
	#if !chart_note: 
		#scale = Vector2(note_skin.notes_scale, note_skin.notes_scale)
		#tail.width = note_skin.sustain_width


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if length > 0:
		var line_length = length * scroll_speed  * grid_size.y
		line_length /= note_skin.notes_scale
		
		tail.visible = true
		tail.scale.y = scroll
		
		tail.points = [Vector2.ZERO, Vector2(0, line_length)]
	else: 
		tail.visible = false
		end.visible = false


func update_y():
	position.y = PIXELS_PER_SECOND * time_difference * scroll_speed * scroll
	var grid_scaler = PIXELS_PER_SECOND * GameManager.seconds_per_beat
	grid_size.y = grid_scaler

#func _on_visible_on_screen_notifier_2d_screen_entered() -> void: 
	#on_screen = true
	#$Note.visible = on_screen
	#tail.visible = on_screen
#
#func _on_visible_on_screen_notifier_2d_screen_exited() -> void: 
	#on_screen = false
	#$Note.visible = on_screen
	#tail.visible = on_screen
