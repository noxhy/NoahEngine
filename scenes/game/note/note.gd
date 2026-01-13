@icon("res://assets/sprites/nodes/note.png")
@abstract
class_name Note extends Node2D

const PIXELS_PER_SECOND = 450

var length: float = 0.0
var note_type: Variant
var time: float = 0.0
var note_skin: NoteSkin
var lane: int = 0

var scroll_speed: float
var grid_size: Vector2 = Vector2(128, 128)

var scroll: float = 1.0

var direction: String = "left"
var animation: StringName = &"left"
