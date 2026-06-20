extends Node2D

# Meant to be replaced
func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if Input.is_action_just_pressed(&"chart_editor"):
		get_tree().change_scene_to_file(Constants.CHART_EDITOR_SCENE)


func _on_button_pressed() -> void:
	$FileDialog.popup()
