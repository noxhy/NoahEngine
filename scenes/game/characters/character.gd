@icon("res://assets/sprites/nodes/character.png")
extends Node
## The main class for characters in a song, such as the player, enemy, or metronome.
class_name Character

## When calling an animation, it is important to also call context with it:
enum AnimContext {
	## Sing poses (ex: left, down, up, right)
	SING,
	## Idle animations
	DANCE,
	## Will not play any other animations until the context is manually set otherwise.
	LOCKED,
	## Will not play any animation until the sing timer is over unless the context is special.
	SPECIAL,
	## Default context, no functionality
	NONE
}

@export_group("Animation Data")
@export var animation_names: Dictionary[StringName, StringName] = {}
@export var offsets: Dictionary[StringName, Vector2] = {}
@export var hold_frames: Dictionary[StringName, int] = {}

@export_group("Gameplay")
## The idle animations. Whenever the character "dance's" they will cycle through this list.
@export var dance_animations: Array[StringName] = [&"idle"]
## How often [b](in beats)[/b] the dance will be played.
@export_range(1, 1, 1, "suffix:beats", "or_greater") var dance_rate: int = 2
@export var animation_prefix: StringName = &""
## How many steps an animation can play before being able to revert to idle.
@export_custom(PROPERTY_HINT_NONE, 'suffix:steps') var sing_duration: float = 6

@export_group("UI")
@export var icons: SpriteFrames = load("res://assets/sprites/playstate/icons/face.tres")
@export var color: Color = Color(0.168627, 0.121569, 0.203922)

##The actual sprite node that will be used to play the anims. If not assigned, it will fallback to
##[AnimatedSprite2D] or [AnimateSymbol]
@export var animation_player: Node = null

var current_dance: int = 0
## The current animation ID.
var current_animation: StringName = dance_animations[0]
## The current [AnimContext]
var current_context: AnimContext = AnimContext.NONE
var can_dance: bool = true
## Used to make an animation loop at the given [code]hold_frame[/code] until given another animation.
var holding: bool = false
## Time elapsed since the char has started singing
var sing_time: float = 0

func _ready():
	if not animation_player:
		animation_player = $AnimatedSprite2D
		if not animation_player:
			animation_player = $AnimateSymbol
	
	if not animation_player:
		printerr("Character animation player was not set and could not be found.")
		return
	
	if animation_player is AnimateSymbol:
		animation_player.connect(&"finished", self._on_animation_finished)
	else:
		animation_player.play()
		animation_player.connect(&"animation_finished", self._on_animation_finished)


func _on_animation_finished():
	holding = true


func play_animation(anim_id: StringName = &"", context: AnimContext = AnimContext.NONE, restart: bool = true, time: float = -1.0):
	if process_mode == Node.PROCESS_MODE_DISABLED or current_context == AnimContext.LOCKED and !animation_player:
		return
	
	anim_id = StringName(animation_prefix + anim_id)
	current_animation = anim_id
	
	var animation_name: StringName = get_animation_name(anim_id)
	
	if animation_name.is_empty():
		printerr("(Character[", self.name, "]) ", animation_name, " does not exist")
		return
	
	if context != AnimContext.SPECIAL and current_context == AnimContext.SPECIAL and context != AnimContext.DANCE:
		return
	
	# Will not run idle animation if you can not run
	if animation_player is AnimateSymbol:
		if offsets.has(animation_name):
			animation_player.offset = offsets.get(animation_name, animation_player.offset)
		
		animation_player.symbol = animation_name
		if restart:
			animation_player.frame = 0
		
		animation_player.playing = true
		holding = false
		set_sing_timer(animation_player.get_animation_length() / animation_player.current_fps)
		return
	
	
	var animatiom_speed: float = animation_player.sprite_frames.get_animation_speed(animation_name)
	var frame_count: int = animation_player.sprite_frames.get_frame_count(animation_name)
	holding = false
	
	if (time >= 0):
		# Calculates the speed it would need to go at the time requested
		animation_player.play(animation_name, frame_count / (animatiom_speed * time))
		set_sing_timer(time)
	else:
		animation_player.play(animation_name, 1)
		set_sing_timer(frame_count / animatiom_speed)
	
	if restart:
		animation_player.set_frame_and_progress(0, 0)
	
	if offsets.has(animation_name):
		var offsets_to_use = offsets.get(animation_name)
		if offsets.get(animation_player.animation) is PackedVector2Array:
			offsets_to_use = offsets.get(animation_player.animation)[animation_player.frame - 1]
			
		if animation_player is AnimatedSprite3D:
			animation_player.offset.x = offsets_to_use.x
			animation_player.offset.y = -offsets_to_use.y
		else:
			animation_player.position.x = offsets_to_use.x
			animation_player.position.y = offsets_to_use.y


func _process(delta: float) -> void:
	if holding:
		hold_animation()
	
	sing_time -= delta
	if sing_time <= 0 and !can_dance:
		can_dance = true


func get_animation_name(anim_id: StringName = &""):
	return animation_names.get(anim_id, &"")


func set_prefix(prefix: StringName):
	animation_prefix = prefix


func get_current_frame_texture() -> Texture:
	if animation_player is AnimateSymbol:
		return null
	
	return animation_player.sprite_frames.get_frame_texture(animation_player.animation,
	animation_player.frame)

## Lets an animation loop at the given [code]hold_frame[/code] until given another animation.
func hold_animation():
	if !animation_player: return
	
	var hold_frame: int = 0
	var animation_name: StringName
	var length: int
	
	if animation_player is AnimateSymbol: 
		animation_name = get_animation_name(current_animation)
		length = animation_player.get_animation_length()
		hold_frame = hold_frames.get(animation_name, length - 1)
		
		if (animation_player.frame == length - 1 and animation_player.frame_progress == 1):
			animation_player.frame = hold_frame
		
		animation_player.playing = true
	else:
		animation_name = get_animation_name(current_animation)
		length = animation_player.sprite_frames.get_frame_count(animation_name)
		hold_frame = hold_frames.get(animation_name, length - 1)
		
		if animation_player.frame == length - 1 and animation_player.frame_progress == 1:
			animation_player.frame = hold_frame
		
		animation_player.play()

## Play the current idle animation.
func dance(restart: bool = true, time: float = -1) -> void:
	if !can_dance and !dance_animations.has(current_animation):
		return
	
	var dance_to_play: StringName = dance_animations[current_dance]
	play_animation(dance_to_play, AnimContext.DANCE, restart, time)
	
	current_dance = wrapi(current_dance + 1, 0, dance_animations.size())


func set_sing_timer(time: float = -1):
	if time == -1:
		time = sing_duration * GameManager.seconds_per_step
	
	sing_time = time
	can_dance = false


func on_beat_hit(current_beat: int, measure_relative: int): ##basic song hooks this to the conductor
	if dance_rate > 0 and measure_relative % dance_rate == 0:
		dance()
