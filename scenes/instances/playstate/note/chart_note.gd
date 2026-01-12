extends BasicNote
class_name ChartNote

@onready var area = $Area2D
@onready var collision_shape = $Area2D/CollisionShape2D

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
	
	$Note.offsets = note_skin.offsets
	
	if note_skin.pixel_texture: 
		$Note.texture_filter = TEXTURE_FILTER_NEAREST
		tail.texture_filter = TEXTURE_FILTER_NEAREST
	
	scale = Vector2(1, 1)
	$Note.scale = grid_size / $Note.sprite_frames.get_frame_texture($Note.animation, 0).get_size()
	tail.scale = $Note.scale
	tail.position.x = tail.texture.get_height() / 2.0 * tail.scale.x
	collision_shape.shape = RectangleShape2D.new()
	$VisibleOnScreenEnabler2D.scale *= $Note.scale
	collision_shape.scale = $VisibleOnScreenEnabler2D.scale * Vector2(0.8, 1)
	collision_shape.shape.set_size($VisibleOnScreenEnabler2D.rect.size)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time_difference = (time - GameManager.offset) - GameManager.song_position
	
	if length > 0:
		var line_length = length * scroll_speed * grid_size.y
		tail.visible = true
		tail.scale.x = scroll
		tail.size.x = line_length
		# apparently godot is culling the notes regardless of what i do so idk a solution

	else:
		tail.visible = false

func _on_visible_on_screen_enabler_2d_screen_entered() -> void:
	on_screen = true
	$Note.visible = on_screen
	tail.visible = on_screen


func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	on_screen = false
	$Note.visible = on_screen
	tail.visible = on_screen
