extends GPUParticles2D

@export var numbers: bool = false

var ui_skin: UISkin
var animation: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not ui_skin:
		queue_free()
	emitting = true
	
	if numbers and ui_skin.numbers_texture:
		texture = ui_skin.numbers_texture.get_frame_texture(animation, 0)
		scale = Vector2.ONE * ui_skin.numbers_scale
	elif ui_skin.rating_texture:
		texture = ui_skin.rating_texture.get_frame_texture(animation, 0)
		scale = Vector2.ONE * ui_skin.rating_scale
	else:
		queue_free()
	
	#offset = ui_skin.offsets.get(animation, Vector2.ZERO)
	
	if ui_skin.pixel_texture:
		texture_filter = TEXTURE_FILTER_NEAREST


func _on_finished() -> void:
	queue_free()
