@icon("res://addons/at-icons/node/arrow_down_to_bracket.svg")
extends Resource
class_name Strumline

## Label for the strumline
@export var name: StringName
## Left-most lane.
@export var left_lane: int = -1
## Right-most lane.
@export var right_lane: int = -1
## Audio track index.
@export var audio_track: int = -1

@export_group("Edtior Values")
## Db volume of the strumline's audio track
@export var volume: float = 1
## Whether a sound should play upon a note hit in the Chart/Event edtior
@export var hit_sounds: bool = true
## Display toggle for waveforms in the Chart/Event editor
@export var waveform: bool = false

## Construtor function, 'L is the left-most lane while 'R' is the right-most.
func _init(label: StringName, L: int, R: int, track: int) -> void:
	name = label
	left_lane = L
	right_lane = R
	audio_track = track

## Resets the editor values
func reset() -> void:
	volume = 1
	hit_sounds = true
	waveform = false

## Checks if a lane is within [member left_lane] (inclusive) and [member right_lane] (inclusive).
func has_lane(lane: int) -> bool:
	return (lane >= left_lane and lane <= right_lane)
