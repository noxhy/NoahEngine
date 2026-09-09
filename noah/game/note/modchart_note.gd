extends BasicNote
## This note type is worse for performance
class_name ModChartNote

# Applying Note Skin
func _ready() -> void: 
	note.sprite_frames = note_skin.notes_texture
	if note_skin.animation_names != null: 
		if note_skin.animation_names.keys().size() > 0: 
			note.animation_names.merge(note_skin.animation_names, true)
	
	var tail_animation: StringName = animation + &"_tail"
	if tail_animation and tail:
		tail.texture = note_skin.notes_texture.get_frame_texture(tail_animation, 0)
		if !tail.texture:
			tail.texture = BACKUP_HOLD_TEXTURE
	
	var end_animation: StringName = animation + &"_end"
	if end_animation and tail:
		tail.end_texture = note_skin.notes_texture.get_frame_texture(end_animation, 0)
	
	note.offsets = note_skin.offsets
	note.play(animation)
	
	if note_skin.pixel_texture: 
		note.texture_filter = TEXTURE_FILTER_NEAREST
		tail.texture_filter = TEXTURE_FILTER_NEAREST
	
	note.scale = Vector2.ONE * note_skin.notes_scale
	
	if tail:
		tail.modulate.a = note_skin.sustain_opacity
		if tail.texture:
			tail.width = tail.texture.get_height()
		
		tail.scale = Vector2.ONE * note_skin.notes_scale
	
	load_basic_type()


func update():
	position.x = 0
	if !holding:
		position.y = PIXELS_PER_SECOND * time_difference * scroll_speed * scroll
		var grid_scaler: float = PIXELS_PER_SECOND * GameManager.conductor.seconds_per_beat
		grid_size.y = grid_scaler
	else:
		position.y = 0
	
	if length > 0:
		var line_length: float = length * scroll_speed * grid_size.y / tail.scale.y
		tail.visible = true
		tail.points = [Vector2.ZERO, Vector2(0, line_length)]
	else:
		tail.visible = false
	
	if modchart_effects and !modchart_effects.effects.is_empty():
		for e in modchart_effects.effects:
			var effect: ModchartEffect = modchart_effects.get_effect(e)
			effect.update_note(self)
