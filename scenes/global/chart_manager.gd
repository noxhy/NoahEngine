extends Node

const EVENT_DATA: Dictionary = {
	"camera_position": {
		"parameters": ["Position Index"],
		"texture": "res://assets/sprites/menus/chart editor/events/camera_position.png",
	},
	"play_animation": {
		"parameters": ["Group Name", "Animation ID", "(Optional) Duration"],
		"texture": "res://assets/sprites/menus/chart editor/events/play_animation.png",
	},
	"bop_rate": {
		"parameters": ["Step Delay"]
	}
}

var song: Song
var chart: Chart
var difficulty: String = ""

var difficulties: Dictionary = {}
var strum_count: int = 8

## Settings per strum, each key is it's label
var strum_data: Array = [
	{
		"name": "Player",
		"strums": [0, 3],
		"muted": false,
		"track": 0,
	},
	{
		"name": "Enemy",
		"strums": [4, 7],
		"muted": false,
		"track": 1,
		
	},
	#{
		#"name": "Third",
		#"strums": [8, 11],
		#"muted": false,
		#"track": 2,
		#
	#},
]

var event_tracks: Array = []
