extends Node2D
class_name AtlasSprite

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

func _ready() -> void:
	animated_symbol.connect(&"animation_finished", self.emit_signal.bind(&"finished"))
	animated_symbol.connect(&"animation_looped", self.emit_signal.bind(&"looped"))

func play(id: String):
	animation = id
	animated_symbol.frame = 0
	animated_symbol.playing = true
	animated_symbol.offset = offset_data.get(id, Vector2.ZERO)

func pause():
	animated_symbol.playing = false


func _on_animate_symbol_animation_finished() -> void:
	finished.emit()


func _on_animate_symbol_animation_looped() -> void:
	looped.emit()
