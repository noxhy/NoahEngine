extends Node

#scene ids
var CHART_EDITOR_SCENE: String = "uid://c3lux2ajoe1g6"
var EVENT_EDITOR_SCENE: String = "uid://cq6xqods6w7lw"

#region Event Data
var EVENT_DATA: Dictionary = {
	"camera_position": {
		"parameters": ["Position Index"],
		"texture": "uid://b4ve504nau36k"
	},
	"play_animation": {
		"parameters": ["Group Name", "Animation ID", "(Optional) Duration"],
		"texture": "uid://d0bn2mll0jrpd"
	},
	"camera_bop": {
		"parameters": ["Camera Bop Amount", "UI Bop Amount"],
		"texture": "uid://qe3r1k3apxbl"
	},
	"camera_zoom": {
		"parameters": ["Zoom", "Duration", "Easing Type"],
		"texture": "uid://bs2p6h6sokqf0"
	},
	"bop_rate": {
		"parameters": ["Step Rate"]
	},
	"bop_strength": {
		"parameters": ["Camera Amount", "UI Amount"],
	},
	"set_smoothing": {
		"parameters": ["Toggled"],
	},
	"scroll_speed": {
		"parameters": ["Amount", "Ease Duration"],
		"texture": "uid://cdyobnrt3rnml"
	},
	"camera_shake": {
		"parameters": ["Amount", "Duration"],
		"texture": "uid://da6pn1kq8iao0"
	},
	"set_prefix": {
		"parameters": ["Group Name", "Prefix"]
	},
	"comment": {
		"parameters": [""],
		"texture": "uid://bwp1pd1s3xmka"
	}
}
#endregion

#playstate constants
const SCORING_SLOPE: float = 0.08
const SCORING_OFFSET: float = 0.05499
const COMBO_SLOPE: float = 20.0

const HOLD_SCORE_GAIN_PER_SECOND: float = 250
const MIN_SCORE_GAIN: int = 9
const MAX_SCORE_GAIN: int = 500

const HOLD_HEALTH_GAIN_PER_SECOND: float = 6
const HEALTH_GAIN: float = 1

const MISS_BASE_HEALTH_PENALTY: float = 4
const MISS_MAX_HEALTH_PENALTY: float = 20.0

#region Note Types
## The note type and the corresponding animation prefix.
var NOTE_TYPES: Dictionary = {
	"mom": "",
	"no_animation": "",
	"alt_prefix": ""
}
#endregion
