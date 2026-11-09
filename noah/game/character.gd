@tool
@abstract
extends Node
class_name Character2

@export var animation_player: Node

@export var dance_animations: Array[StringName] = []

var current_dance_animation: int = 0

var current_context: Character.AnimContext


#@abstract func play_animation()
#
#@abstract func sing()
#
#@abstract func miss()
#
#@abstract func dance()
#
#@abstract func hold_animation()

@abstract func get_animation_names() -> Array[StringName]

func _validate_property(property: Dictionary) -> void:
	match property.get("name"):
		"dance_animations":
			property.hint = PROPERTY_HINT_ENUM
			property.hint_string = "%d/%d:%s" % [TYPE_STRING_NAME, PROPERTY_HINT_ENUM, ",".join(get_animation_names())]
			
