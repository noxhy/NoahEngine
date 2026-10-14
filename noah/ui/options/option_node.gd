extends Control
class_name OptionNode

@export var setting_category:String = ''
@export var setting_name: String = ""
@export var display_name = ""
@export var description: String

@onready var background = %Background

func set_offset_left(offset: float):
	offset_left = offset

func select() -> void:
	if background:
		background.color = Color(1.0, 1.0, 1.0, 0.5)

func normal() -> void:
	if background:
		background.color = Color(0.0, 0.0, 0.0, 0.5)
