@icon("res://addons/at-icons/node/arrow_down_to_bracket.svg")
extends Resource
class_name Strumline

@export var name: StringName
@export var left_lane: int = -1
@export var right_lane: int = -1
@export var audio_track: int = -1

@export_group("Edtior Values")
@export var volume: float = 1
@export var hit_sounds: bool = true

## Construtor function, 'L is the left-most lane while 'R' is the right-most.
func _init(label: StringName, L: int, R: int) -> void:
	name = label
	left_lane = L
	right_lane = R

## Resets the editor values
func reset() -> void:
	volume = 1
	hit_sounds = true

func has_lane(lane: int) -> bool:
	return (lane >= left_lane and lane <= right_lane)
