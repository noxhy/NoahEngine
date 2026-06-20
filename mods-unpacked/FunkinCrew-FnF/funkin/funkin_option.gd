extends MenuOption

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label = $Alphabet
	label.text = text
	if icon:
		sprite.texture = icon
		await Engine.get_main_loop().process_frame
		sprite.position.x = label.get_string_size(text).x + sprite.texture.get_width() * 0.5 + 15
