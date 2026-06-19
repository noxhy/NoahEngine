extends Node2D

@export var note_skin = NoteSkin.new()

# Called when the node enters the scene tree for the first time.
func vanilla_630116035__ready():
	
	$OffsetSprite.sprite_frames = note_skin.splashes_texture
	
	if note_skin.animation_names != null:
		$OffsetSprite.animation_names.merge(note_skin.animation_names, true)
	
	$OffsetSprite.offsets = note_skin.offsets
	
	if note_skin.pixel_texture:
		$OffsetSprite.texture_filter = TEXTURE_FILTER_NEAREST
	
	$OffsetSprite.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func vanilla_630116035__process(delta):
	pass


func vanilla_630116035__on_offset_sprite_animation_finished():
	queue_free()


# ModLoader Hooks - The following code has been automatically added by the Godot Mod Loader.


func _ready():
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_630116035__ready, [], 2104467063)
	else:
		return vanilla_630116035__ready()


func _process(delta):
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_630116035__process, [delta], 489436097)
	else:
		return vanilla_630116035__process(delta)


func _on_offset_sprite_animation_finished():
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_630116035__on_offset_sprite_animation_finished, [], 1088456163)
	else:
		return vanilla_630116035__on_offset_sprite_animation_finished()
