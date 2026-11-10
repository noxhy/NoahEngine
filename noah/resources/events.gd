@icon("res://addons/at-icons/node/file_plus.svg")
extends Resource
class_name ChartEvents

## All the events within the chart. Stored as [code][TIME, EVENT_NAME, [EVENT_PARAMETERS]][/code]
@export var data: Array = []

func _init(events: Array = []) -> void:
	data = []
