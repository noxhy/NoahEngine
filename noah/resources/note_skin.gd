@icon ("uid://d0x87ek7hwhdm")
extends Resource
class_name NoteSkin

@export_subgroup("Textures")
## The textures of the strums. Strums animation are configured as [code]STATE_DIRECTION_strum[/code]
## [br][br]So a left note would be configed as [code]left_strum, glow_left_strum, press_left_strum[/code].
@export var strums_texture: SpriteFrames
## The textures of the incoming notes. Notes animations are configured as [code]TYPE_DIRECTION_TAILSTATE[/code]
## [br][br]So a left note would be configured as [code]left, left_tail, left_end[/code].
## [br][br]If a left note were to have a custom type the type would be added as a prefix as [code]notetype_left[/code]
@export var notes_texture: SpriteFrames
## The textures of the note splashes. Splash animations are configured as [code]DIRECTION_splash[/code]
## [br][br]So a left splash would be configured as [code]left_splash[/code]
@export var splashes_texture: SpriteFrames

## [color=khaki]OPTIONAL:[/color]
## The textures of strum hold covers. Cover animations are configured as [code]STATE_DIRECTION_cover[/code]
## [br][br]So a left cover would be configured as [code]left_cover, start_left_cover, end_left_cover[/code]
@export var hold_covers_texture: SpriteFrames

## Whether the notes filtering should be set to [code]NEAREST_NEIGHBOR[/code] to keep it crisp when scaled.
@export var pixel_texture: bool = false

@export_subgroup("Texture Config")

## The opacity/alpha/transparency set to all notes tails.
@export_range(0, 1) var sustain_opacity: float = 0.6 # shouldnt this be called tail_opacity ?

## Multiplicative scaling applied to the notes and strums.
@export var notes_scale: float = 1.0

## Multiplicative scaling applied to the note splashes.
@export var splash_scale: float = 1.0

## Multiplicative scaling applied to the strum hold covers.
@export var hold_covers_scale: float = 1.0

@export_subgroup("Offsets")
## [color=khaki]OPTIONAL:[/color]
## offset that gets applied to the notes animation
@export var offsets: Dictionary[StringName, Vector2] = {}

@export_subgroup("Audio")
## [color=khaki]OPTIONAL:[/color]
## Hit sound played whenever a note is hit. This only applies if the players preferences have [code]hit_sounds[/code] enabled.
@export var hit_sound: AudioStream
