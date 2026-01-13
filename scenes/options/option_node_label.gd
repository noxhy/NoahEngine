extends OptionNode

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%Label.text = display_name

func normal() -> void:
	if background:
		background.color = Color(0.0, 0.0, 0.0, 0.0)

func select() -> void:
	super()
