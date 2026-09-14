@icon ("uid://obbw51pf8bd0")
extends Resource
class_name UISkin

@export_subgroup("Textures")

## The textures of the rating popups.
## [br][br]The animations should be [code]miss, shit, bad, good, sick[/code].
## [br][br]They can also have a FC alternative named as [code]fc_RANK[/code]
@export var rating_texture: SpriteFrames

## The textures of the rating number popups.
## [br][br]The animations should be [code]0[/code] to [code]9[/code].
## [br][br]They can also have a FC alternative named as [code]fc_NUMBER[/code]
@export var numbers_texture: SpriteFrames

## Whether the notes filtering should be set to [code]NEAREST_NEIGHBOR[/code] to keep it crisp when scaled.
@export var pixel_texture: bool = false

@export_subgroup("Texture Scaling")

## Multiplicative scaling applied to the notes and strums.
@export var rating_scale: float = 1.0

## Multiplicative scaling applied to the notes and strums.
@export var numbers_scale: float = 1.0

## The distance between each number. Gets [member rating_scale] Automatically applied
@export var numbers_spacing: float = 64

@export_subgroup("Offsets")
@export var animation_names: Dictionary[StringName, StringName] = {}
@export var offsets: Dictionary[StringName, Vector2] = {}

@export_subgroup("Scenes")
## [color=khaki]OPTIONAL:[/color]
## The path to a countdown animation player scene.
@export_file var countdown: String
## The path to a scene to be loaded when paused.
@export_file var pause_scene: String = "uid://djhqiluiy02ao"
