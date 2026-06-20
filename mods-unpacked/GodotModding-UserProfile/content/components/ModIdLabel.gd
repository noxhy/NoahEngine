class_name ModIdLabel
extends Label


@export var color_error: Color = Color.INDIAN_RED
@export var color_mandatory: Color = Color.DARK_GRAY

var mod_id: String


func set_error_color() -> void:
	_set_label_color(color_error)


func set_mandatory_color() -> void:
	_set_label_color(color_mandatory)


func _set_label_color(color: Color) -> void:
	self.add_theme_color_override("font_color", color)
