@icon("uid://c1o5a7jg5bf85")
@abstract
class_name Note extends Node2D

const PIXELS_PER_SECOND = 450

var length: float = 0.0

var time: float = 0.0
var note_skin: NoteSkin
var lane: int = 0

var scroll_speed: float
var grid_size: Vector2 = Vector2(128, 128)

var scroll: float = 1.0

var direction: String = "left"
var animation: StringName = &"left"


#
var note_type: String
var no_animation: bool = false
var damage_mult: float = 1.0
var health_mult: float = 1.0
var anim_prefix: String = ''
var scoreable: bool = true
var bad_hit: bool = false

func load_basic_type():
	match note_type:
		"no_animation":
			no_animation = true
		"alt_prefix":
			anim_prefix = 'alt_'
