extends Node2D

@export var option_name: String = "Menu Option"
@export var icon: Texture

# Called when the node enters the scene tree for the first time.
func _ready():
	$Label.text = option_name
	if icon != null:
		$Sprite2D.texture = icon
		
		await Engine.get_main_loop().process_frame
		
		$Sprite2D.position.x = $Label.size.x + $Sprite2D.texture.get_width() * 0.5 + 15
