@icon("res://assets/sprites/nodes/character.png")
extends Node
class_name Character

#region export settings

##The actual sprite node that will be used to play the anims. If not assigned, it will fallback to "$AnimatedSprite2D" or "$AnimateSymbol"
@export var animation_player:Node = null

@export_group('Gameplay')
##The idle animations. Whenever the character "dance's" they will cycle through this list.
@export var idle_animations: Array[StringName] = [&"idle"]
@export var animation_prefix: StringName = &""
@export var sing_duration:float = 6.0
@export_range(1, 999) var dance_beats:int = 2 ## how many beats until the char should "dance"

@export_group("Animation")
@export var animation_names: Dictionary[StringName, StringName] = {}
@export var offsets: Dictionary[StringName, Vector2] = {}
@export var hold_frames: Dictionary[StringName, int] = {}
@export var forced_animations: Array[StringName] = []

@export_group("UI")
@export var icons: SpriteFrames = load("res://assets/sprites/playstate/icons/face.tres")
@export var color: Color = Color(0.168627, 0.121569, 0.203922) ##healthbar color
#endregion

#region internal refs
var sing_timer:float = 0 ## Time elapsed since the char has started singing
var holding: bool = false ## Used to hold anims on the final frame
var in_playstate:bool = false ## If true, tries to handle auto dancing behavior
var is_player:bool = false ## Whether to check if ur holding any inputs before returning to idle
#endregion



var current_animation: StringName = idle_animations[0]

var current_idle_tick:int = 0

var can_dance:bool = true

var anim_context:AnimContext = AnimContext.NONE

#UNIMPLEMENTED
enum AnimContext {
	SING,
	DANCE,
	LOCKED,
	SPECIAL,
	NONE
}

func _ready():
	if not animation_player:
		animation_player = $AnimatedSprite2D
		if not animation_player:
			animation_player = $AnimateSymbol
	
	if not animation_player:
		printerr("Character animation player was not set and could not be found.")
		return
	
	
	if animation_player is not AnimateSymbol:
		animation_player.play()

func play_animation(anim_to_play:StringName = &'', restart:bool = true, time_scale:float = 1.0) -> void:
	if process_mode == Node.PROCESS_MODE_DISABLED or anim_context == AnimContext.LOCKED and not animation_player: return
	
	anim_to_play = StringName(animation_prefix + anim_to_play)
	current_animation = anim_to_play
	
	var raw_anim_name = get_real_animation(anim_to_play)
	
	if raw_anim_name.length() == 0:
		printerr(anim_to_play, 'is missing')
	
	if is_singing(): # well they arent yet but they r going to so.
		sing_timer = 0
	
	if animation_player is AnimateSymbol:
		
		animation_player.symbol = raw_anim_name
		animation_player.playing = true
		
		animation_player.speed_scale = time_scale
		
		if restart: 
			animation_player.frame = 0
		
		#add the offsets
		animation_player.offset = offsets.get(raw_anim_name, animation_player.offset)
		
	else:
		
		animation_player.play(raw_anim_name, time_scale)
		
		if restart:
			animation_player.set_frame_and_progress(0, 0)
		
		#add the offsets
		if animation_player is AnimatedSprite3D:
			var new_offsets = offsets.get(raw_anim_name)
			if new_offsets:
				animation_player.offset.x = new_offsets.x
				animation_player.offset.y = -new_offsets.y
		else:
			animation_player.position = offsets.get(raw_anim_name, animation_player.position)


func dance(restart:bool = false, time_scale:float = 1.0) -> void:
	if not can_dance or anim_context == AnimContext.LOCKED: return
	
	anim_context = AnimContext.DANCE
	var dance_to_play = idle_animations[current_idle_tick]
	play_animation(dance_to_play, restart, time_scale)
	
	current_idle_tick = wrapi(current_idle_tick + 1, 0, idle_animations.size())

func on_beat_hit(current_beat:int, measure_relative:int): ##basic song hooks this to the conductor
	if dance_beats > 0 and not is_singing() and measure_relative % dance_beats == 0:
		dance()

func _process(delta: float) -> void:
	
	if in_playstate:
		playstate_process(delta)

func playstate_process(delta:float) -> void:
	if holding:
		hold_animation()
		
	if is_singing() and not holding:
		sing_timer += delta
		
	if sing_timer >= GameManager.seconds_per_step * sing_duration and not is_pressing_notes():
		sing_timer = 0
		dance()
		

func is_singing() -> bool:
	return current_animation.ends_with('left') \
	or current_animation.ends_with('down') \
	or current_animation.ends_with('up') \
	or current_animation.ends_with('right')

func is_pressing_notes() -> bool:
	if not is_player: return false
	
	return Input.is_action_pressed(&'note_left') \
	 and Input.is_action_pressed(&'note_down') \
	 and Input.is_action_pressed(&'note_up') \
	 and Input.is_action_pressed(&'note_right')
	

func get_real_animation(animation_name: StringName = &"") -> StringName:
	return animation_names.get(animation_name, &"")

func set_prefix(prefix: StringName):
	animation_prefix = prefix

func hold_animation():
	if not animation_player: return
	
	var hold_frame: int = 0
	var real_animation: StringName = get_real_animation(current_animation)
	var length: int
	
	if animation_player is AnimateSymbol:
		if animation_player.loop:
			return
		
		length = animation_player.get_animation_length()
		hold_frame = hold_frames.get(real_animation, length - 1)
		
		if (animation_player.frame == length - 1 and animation_player.frame_progress == 1):
			animation_player.frame = hold_frame
		
		animation_player.playing = true
		
	else:
		if animation_player.sprite_frames.get_animation_loop(real_animation):
			return
		
		length = animation_player.sprite_frames.get_frame_count(real_animation)
		hold_frame = hold_frames.get(real_animation, length - 1)
		
		if animation_player.frame == length - 1 and animation_player.frame_progress == 1:
			animation_player.frame = hold_frame
		
		animation_player.play()
