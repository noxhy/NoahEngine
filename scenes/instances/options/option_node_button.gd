extends OptionNode
class_name ButtonOptionNode

@onready var button = $HBoxContainer/Button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button.text = display_name

func select():
	var hover_style = button.get_theme_stylebox("hover", "Button")
	button.add_theme_stylebox_override("normal", hover_style)

func normal():
	button.remove_theme_stylebox_override("normal")
