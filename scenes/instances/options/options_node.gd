extends Control
class_name OptionNode

@export var setting_category:String = ''
@export var setting_name: String = ""
@export_multiline var display_name = ""

@onready var background = %Background

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_offset_left(offset: float):
	offset_left = offset

func select():
	if background:
		background.color = Color(1, 1, 1, 0.5)

func normal():
	if background:
		background.color = Color(0.0, 0.0, 0.0, 0.5)
