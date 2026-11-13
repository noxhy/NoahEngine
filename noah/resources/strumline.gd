@icon("res://addons/at-icons/node/arrow_down_to_bracket.svg")
extends Resource
class_name Strumline

## Label for the strumline
@export var name: StringName
## Left-most lane.
@export var left_lane: int = -1
## The amount of lanes in the strumline
@export var lane_count: int = 4
## Right-most lane.
var right_lane: int:
	set(v):
		lane_count = v - left_lane + 1
	get():
		if left_lane == -1:
			return -1
		
		return left_lane + lane_count - 1

## Audio track index.
@export var audio_track: int = 0

@export_group("Edtior Values")
## Db volume of the strumline's audio track
@export var volume: float = 1
## Whether a sound should play upon a note hit in the Chart/Event edtior
@export var hit_sounds: bool = true
## Display toggle for waveforms in the Chart/Event editor
@export var waveform: bool = false

## Construtor function, 'L is the left-most lane while 'R' is the right-most.
func _init(label: StringName, L: int, count: int = 4, track: int = 0) -> void:
	name = label
	left_lane = L
	lane_count = count
	audio_track = track

static func from_dict(dict: Dictionary) -> Strumline:
	return Strumline.new(dict.name, dict.left_lane, dict.lane_count, dict.audio_track)

## Resets the editor values
func reset() -> void:
	volume = 1
	hit_sounds = true
	waveform = false

## Checks if a lane is within [member left_lane] (inclusive) and [member right_lane] (inclusive).
func has_lane(lane: int) -> bool:
	return (lane >= left_lane and lane <= right_lane)

## Converts the contents to a [Dictionary] for exports. This helps the Godot issue of exporting subresources.
func to_dict() -> Dictionary:
	return {"name": name, "left_lane": left_lane, "lane_count": lane_count, "audio_track": audio_track}

func _to_string() -> String:
	return str('Strumline(name: %s, left: %d, right: %d, track: %d)' % [name, left_lane, right_lane, audio_track]
	)
