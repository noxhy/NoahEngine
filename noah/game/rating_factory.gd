extends Node2D
class_name RatingFactory
## Factory that creates Rating sprites and combo number sprites via the [RenderingServer]
## [br][br]Currently there is no support for animated sprites and atlas textures that have been rotated

#no rotated textures please aha...

## How long (in seconds) should the rating exist for
var lifetime: float = 1.0
## The gravity applied to the rating
var gravity: Vector2 = Vector2(0.0, 700.0)
## The starting velocity of the rating
var velocity: Vector2 = Vector2(0.0, -200.0)
## The fade out curve of the rating. The curves min max domain should be 0 to 1.
var alpha_curve: Curve = load("uid://5du3cb1qmpq8")

## The ui_skin. This must be set.
var ui_skin: UISkin

var ratings: Array[Rating] = []
var garbage: Array[Rating] = []

var rating_z: int

func spawn_rating(offset: Vector2 = Vector2.ZERO, anim: StringName = &"sick") -> void:
	var texture: Texture2D = ui_skin.rating_texture.get_frame_texture(anim, 0)
	
	offset.x -= (texture.get_size().x / 2.0) * ui_skin.rating_scale
	
	var rating = Rating.new(offset, ui_skin.rating_scale, alpha_curve, rating_z, get_canvas_item())
	rating.lifetime = lifetime
	rating.gravity = gravity
	rating.velocity = velocity
	rating.alpha_curve = alpha_curve
	ratings.append(rating)
	rating_z += 1
	
	set_texture_to_rid(rating.rid, texture)
	if ui_skin.pixel_texture:
		RenderingServer.canvas_item_set_default_texture_filter(rating.rid, RenderingServer.CANVAS_ITEM_TEXTURE_FILTER_NEAREST)

func spawn_combo(offset: Vector2 = Vector2.ZERO, combo: String = "0", use_fc: bool = false) -> void:
	var digit_count: int = combo.length()
	for digit in digit_count:
		var pos: Vector2 = offset
		
		pos.x += (digit - (digit_count) / 2.0) \
			* ui_skin.numbers_spacing \
			* ui_skin.numbers_scale
		
		var rating = Rating.new(pos, ui_skin.numbers_scale, alpha_curve, rating_z, get_canvas_item())
		rating.lifetime = lifetime
		rating.gravity = gravity
		rating.velocity = velocity
		rating.alpha_curve = alpha_curve
		ratings.append(rating)
		rating_z += 1
		
		var anim = combo[digit]
		if use_fc:
			anim = "fc_" + anim
		var texture: Texture2D = ui_skin.numbers_texture.get_frame_texture(anim, 0)
		
		set_texture_to_rid(rating.rid, texture)
		
		if ui_skin.pixel_texture:
			RenderingServer.canvas_item_set_default_texture_filter(rating.rid, RenderingServer.CANVAS_ITEM_TEXTURE_FILTER_NEAREST)

func set_texture_to_rid(rid: RID, texture: Texture2D) -> void:
	if texture is AtlasTexture:
		RenderingServer.canvas_item_add_texture_rect_region(rid, 
			Rect2(Vector2.ZERO, texture.get_size()), 
				texture.get_rid(),
				texture.region
		)
	else:
		RenderingServer.canvas_item_add_texture_rect(rid, Rect2(Vector2.ZERO, texture.get_size()), texture.get_rid())

func _process(delta: float) -> void:
	
	garbage.clear()
	for rating in ratings:
		
		rating.process(delta)
		
		if rating.elapsed_time >= 1.0:
			garbage.append(rating)
	
	for rating in garbage:
		ratings.erase(rating)
		RenderingServer.free_rid(rating.rid)

func _exit_tree() -> void:
	for rating in ratings:
		RenderingServer.free_rid(rating.rid)
	
	ratings.clear()

class Rating:
	var rid: RID
	
	
	var lifetime: float = 1.0
	var gravity: Vector2 = Vector2(0.0, 700.0)
	var velocity: Vector2 = Vector2(0.0, -200.0)
	var alpha_curve: Curve
	var position: Vector2 = Vector2.ZERO
	var scale: Vector2
	var is_rotated: bool = false
	
	var elapsed_time: float = 0.0
	
	func _init(_position: Vector2, _scale: float, _curve: Curve, z: int, parent: RID) -> void:
		position = _position
		scale = _scale * Vector2.ONE
		alpha_curve = _curve
		rid = RenderingServer.canvas_item_create()
		RenderingServer.canvas_item_set_parent(rid, parent)
		RenderingServer.canvas_item_set_z_index(rid, z)
		
		RenderingServer.canvas_item_set_transform(rid, Transform2D(0.0, scale, 0.0, position))
	
	func process(delta: float) -> void:
		elapsed_time += delta / lifetime
		
		position += velocity * delta
		velocity += gravity * delta
		
		if is_rotated:
			pass
		else:
			RenderingServer.canvas_item_set_transform(rid, Transform2D(0.0, scale, 0.0, position))
		
		RenderingServer.canvas_item_set_modulate(rid, Color(1.0, 1.0, 1.0, alpha_curve.sample(elapsed_time)))
