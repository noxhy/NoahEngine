@icon("res://addons/at-icons/node/road.svg")
extends Resource
class_name EventTrack
## Resource for event tracks.

## Name of the track
@export var name: StringName
## Color of the track
@export var color: Color

func _init(track_name: StringName, track_color: Color = Color.WHITE) -> void:
	name = track_name
	color = track_color

## Creates a new [EventTrack] from a [Dictionary].
static func from_dict(data: Dictionary) -> EventTrack:
	return EventTrack.new(data["name"], data["color"])

## Creates a new [Dictionary] from a [EventTrack].
func to_dict() -> Dictionary:
	return {"name": name, "color": color}

func _to_string() -> String:
	return str("EventTrack(%s)" % name)
