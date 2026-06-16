extends Node2D

@export var text: String = "Menu Option"
@export var icon: Texture

@onready var label = $Alphabet
@onready var sprite = $Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	label.text = text
	if icon != null:
		sprite.texture = icon
		await Engine.get_main_loop().process_frame
		sprite.position.x = label.get_string_size(text).x + sprite.texture.get_width() * 0.5 + 15
