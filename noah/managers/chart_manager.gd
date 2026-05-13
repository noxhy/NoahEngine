extends Node

const EVENT_DATA: Dictionary = {
	"camera_position": {
		"parameters": ["Position Index"],
		"texture": "uid://b4ve504nau36k",
	},
	"play_animation": {
		"parameters": ["Group Name", "Animation ID", "(Optional) Duration"],
		"texture": "uid://d0bn2mll0jrpd",
	},
	"camera_bop": {
		"parameters": ["Camera Bop Amount", "UI Bop Amount"],
	},
	"camera_zoom": {
		"parameters": ["Zoom", "Duration", "Easing Type"],
		"texture": "uid://bs2p6h6sokqf0",
	},
	"bop_rate": {
		"parameters": ["Step Rate"]
	},
	"camera_bop_strength": {
		"parameters": ["Amount"],
	},
	"ui_bop_strength": {
		"parameters": ["Amount"],
	},
	"lerping": {
		"parameters": ["Toggled"],
	},
	"scroll_speed": {
		"parameters": ["Amount", "Ease Duration"],
		"texture": "uid://cdyobnrt3rnml",
	},
	"camera_shake": {
		"parameters": ["Amount", "Duration"],
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
