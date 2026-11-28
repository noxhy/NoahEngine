@icon("res://addons/at-icons/node/file_plus.svg")
extends Resource
class_name ChartEvents

## All the events within the chart. Stored as [code][TIME, EVENT_NAME, [EVENT_PARAMETERS]][/code]
@export var data: Array = []
@export var tracks: Array = []

func _init(events: Array = []) -> void:
	data = events

## Gets the track number of an index. If the track is a valid index but not in [member tracks] assume it's in the fallback track [code]0[/code].
func get_track(index: int) -> int:
	if data.is_empty():
		return -1
	
	if index < 0 or index >= data.size():
		return -1
	
	for i in tracks.size():
		if tracks[i].has(index):
			return (i + 1)
	
	return 0
