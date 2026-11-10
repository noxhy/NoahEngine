extends Node
class_name EditorResources
## Class containing data used within [ChartEditor] and [EventEditor]

## Reference of the last song loaded in [ChartEditor].
static var song: Song
## Reference to the last chart loaded in the [ChartEditor]
static var chart: Chart
static var difficulty: StringName

static var difficulties: Dictionary = {}
static var strum_count: int:
	get():
		var sum: int = 0
		for strumline in strumlines:
			if strumline.left_lane == -1:
				continue
			
			if strumline.right_lane == -1:
				continue
			
			sum += strumline.right_lane - strumline.left_lane + 1
		
		return sum

static var event_editor: bool = false

## Settings per strum, each key is it's label
static var strumlines: Array[Strumline] = []

static var event_tracks: Array = []
