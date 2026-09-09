@icon("res://addons/at-icons/node/star.svg")

extends Resource
class_name ModchartEffect

## Main class for modchart effects

const STRUM_WIDTH: float = 128

## ID name of the modchart effect.
var name: StringName

## Update function for a receptor or note called on loop
func update_general(node: Node2D) -> void:
	pass

## Update function for notes, returns a [Callabe]
func update_note(note: BasicNote) -> void:
	pass
