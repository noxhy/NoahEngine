extends Node
class_name ChartEditorManifest

## Reference of the last song loaded in [ChartEditor].
static var song: Song
## Reference to the last chart loaded in the [ChartEditor]
static var chart: Chart
static var difficulty: String = ""

static var difficulties: Dictionary = {}
static var strum_count: int = 8
static var event_editor: bool = false

## Settings per strum, each key is it's label
static var strum_data: Array = [
	{
		"name": "Player",
		"strums": [0, 3],
		"track": 0,
		"volume": 1,
		"hit_sounds": true,
	},
	{
		"name": "Enemy",
		"strums": [4, 7],
		"track": 1,
		"volume": 1,
		"hit_sounds": true,
		
	},
	#{
		#"name": "Third",
		#"strums": [8, 11],
		#"muted": false,
		#"track": 2,
		#
	#},
]

static var event_tracks: Array = []
