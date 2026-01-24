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
	"camera_bop": {
		"parameters": ["Camera Bop Amount", "UI Bop Amount"],
	},
	"camera_zoom": {
		"parameters": ["Zoom", "Duration", "Easing Type"],
		"texture": "res://assets/sprites/menus/chart editor/events/camera_zoom.png",
	},
	"bop_rate": {
		"parameters": ["Step Delay"]
	},
	"bop_delay": {
		"parameters": ["Step Delay"],
	},
	"camera_bop_strength": {
		"parameters": ["Amount"],
	},
	"ui_bop_strength": {
		"parameters": ["Amount"],
	},
	"lerping": {
		"parameter": ["Toggled"],
	},
	"scroll_speed": {
		"parameter": ["Amount", "Ease Duration"],
		"texture": "res://assets/sprites/menus/chart editor/events/scroll_speed.png",
	},
	"camera_shake": {
		"parameter": ["Amount", "Duration"],
	},
}

var song: Song
var chart: Chart
var difficulty: String = ""

var difficulties: Dictionary = {}
var strum_count: int = 8
var event_editor: bool = false

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
