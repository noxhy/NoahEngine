extends Node2D

# Meant to be replaced
func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if Input.is_action_just_pressed(&"chart_editor"):
		get_tree().change_scene_to_file(Constants.CHART_EDITOR_SCENE)


func _on_button_pressed() -> void:
	var folder = ""
	if OS.has_feature("standalone"):
		# Gets the folder containing the executable when exported
		folder = OS.get_executable_path().get_base_dir()
	else:
		# Defaults to res:// when running in the Godot Editor
		folder = ProjectSettings.globalize_path("res://")
	
	var mod_folder = folder.path_join("mods")
	
	$FileDialog.root_subfolder = mod_folder
	$FileDialog.popup()
