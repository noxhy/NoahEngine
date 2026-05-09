extends Node2D

@export var option_name: String = "Menu Option"
@export var icon: Texture

@onready var label = $Alphabet
@onready var sprite = $Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	label.text = option_name
	if icon != null:
		sprite.texture = icon
		
		await Engine.get_main_loop().process_frame
		
		sprite.position.x = label.get_string_size(option_name).x + sprite.texture.get_width() * 0.5 + 15
