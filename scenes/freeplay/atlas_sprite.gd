class_name AtlasSprite extends Node2D

## [code]start_frame[/code] - Starting frame
## [code]end_frame[/code] - Ending frame
@export var animation_data: Dictionary[String, String]:
	set(v):
		animation_data = v
		
		for a_name in animation_data:
			if a_name == animation:
				animation = a_name
				animated_symbol.position = offset_data.get(animation, Vector2.ZERO)

@export var offset_data: Dictionary[String, Vector2]

@export var animation: String:
	set(v):
		if animated_symbol != null:
			animation = v
			animated_symbol.symbol = animation_data.get(v, "")

@onready var animated_symbol = $AnimateSymbol

signal finished
signal looped

func play(id: String):
	animation = id
	animated_symbol.frame = 0
	animated_symbol.playing = true
	animated_symbol.position = offset_data.get(animation, Vector2.ZERO)

func pause():
	animated_symbol.playing = false

func done():
	self.finished.emit()

func loop():
	self.looped.emit()
