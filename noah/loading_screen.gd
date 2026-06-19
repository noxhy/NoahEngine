extends Node2D
class_name LoadingScreen

@onready var progress_bar = $Background/ProgressBar
static var scene = "uid://rc52vcn2m7ob"

var progress: Array = []
var scene_load_status: float = 0

# Called when the node enters the scene tree for the first time.
func vanilla_2061306194__ready():
	assert(ResourceLoader.exists(scene), '%s could not be loaded.' % scene)
	ResourceLoader.load_threaded_request(scene)
	get_window().content_scale_size = Vector2(
		ProjectSettings.get_setting("display/window/size/viewport_width"),
		ProjectSettings.get_setting("display/window/size/viewport_height")
	)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func vanilla_2061306194__process(_delta):
	scene_load_status = ResourceLoader.load_threaded_get_status(scene, progress)
	progress_bar.value = progress[0] * 100.0
	
	if scene_load_status == ResourceLoader.THREAD_LOAD_LOADED:
		get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get(scene))
		Global.transitioning = false
		Transitions.resume()


# ModLoader Hooks - The following code has been automatically added by the Godot Mod Loader.


func _ready():
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_2061306194__ready, [], 3335080006)
	else:
		return vanilla_2061306194__ready()


func _process(_delta):
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_2061306194__process, [_delta], 597134672)
	else:
		return vanilla_2061306194__process(_delta)
