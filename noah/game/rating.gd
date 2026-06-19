extends Node2D


@export var ui_skin: UISkin
var rating: String = "sick"
var motion: Vector2
var gravity = 0.0

var elapsed: float = 0.0

# Called when the node enters the scene tree for the first time.
func vanilla_2120247715__ready():
	
	$OffsetSprite.sprite_frames = ui_skin.rating_texture
	
	if ui_skin.animation_names != null:
		
		$OffsetSprite.animation_names.merge(ui_skin.animation_names, true)
	
	$OffsetSprite.offsets = ui_skin.offsets
	$OffsetSprite.scale = Vector2(ui_skin.rating_scale, ui_skin.rating_scale) 
	
	if ui_skin.pixel_texture:
		$OffsetSprite.texture_filter = TEXTURE_FILTER_NEAREST
	
	$OffsetSprite.play()
	
	$OffsetSprite.play_animation(rating)
	
	motion = Vector2(randf_range(-0.1, 0.1), -2)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func vanilla_2120247715__physics_process(delta):
	if $Timer.time_left <= 0.7:
		self.modulate.a -= delta / 0.25
	
	self.position += motion * self.scale
	motion.y -= delta * gravity
	gravity += -40 * delta


func vanilla_2120247715__on_timer_timeout():
	queue_free()


# ModLoader Hooks - The following code has been automatically added by the Godot Mod Loader.


func _ready():
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_2120247715__ready, [], 1384243543)
	else:
		return vanilla_2120247715__ready()


func _physics_process(delta):
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_2120247715__physics_process, [delta], 2852440419)
	else:
		return vanilla_2120247715__physics_process(delta)


func _on_timer_timeout():
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_2120247715__on_timer_timeout, [], 2072076517)
	else:
		return vanilla_2120247715__on_timer_timeout()
