@icon("res://assets/sprites/nodes/character.png")
extends Node
class_name Character

#region export settings
@export_group("Animation Settings")

@export var sing_duration:float = 6.0

##The idle animations. Whenever the character "dance's" they will cycle through this list.
@export var idle_animations: Array[StringName] = [&"idle"]
@export var animation_names: Dictionary[StringName, StringName] = {}
@export var offsets: Dictionary[StringName, Vector2] = {}
@export var hold_frames: Dictionary[StringName, int] = {}
@export var forced_animations: Array[StringName]
@export var animation_prefix: StringName = &""

@export_group("Playstate")
@export var icons: SpriteFrames = load("res://assets/sprites/playstate/icons/face.tres")
@export var color: Color = Color(0.168627, 0.121569, 0.203922)

@export var animation_player:Node = null
#endregion

#region internal refs
var sing_timer:float = 0 ## Time elapsed since the char has started singing
var holding: bool = false ## Used to hold anims on the final frame
var in_playstate:bool = false ## If true, tries to handle auto dancing behavior
var is_player:bool = false ## Whether to check if ur holding any inputs before returning to idle
#endregion

var current_animation: StringName = idle_animations[0]

var current_idle_tick:int = 0

var can_idle: bool = true #kill

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
	if process_mode == Node.PROCESS_MODE_DISABLED or not animation_player: return
	
	anim_to_play = StringName(animation_prefix + anim_to_play)
	current_animation = anim_to_play
	
	if is_singing():
		sing_timer = 0
	
	var raw_anim_name = get_real_animation(anim_to_play)
	
	if animation_player is AnimateSymbol:
		
		animation_player.symbol = raw_anim_name
		animation_player.playing = true
		
		animation_player.speed_scale = time_scale
		
		if restart: 
			animation_player.frame = 0
		
		#add the offsets
		animation_player.offset = offsets.get(raw_anim_name, animation_player.offset)
		
	elif animation_player is AnimatedSprite2D or animation_player is AnimatedSprite3D:
		
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
	
	var dance_to_play = idle_animations[current_idle_tick]
	play_animation(dance_to_play, restart, time_scale)
	
	current_idle_tick = wrapi(current_idle_tick + 1,0,idle_animations.size())

func is_singing() -> bool:
	return current_animation.begins_with('left') \
	or current_animation.begins_with('down') \
	or current_animation.begins_with('up') \
	or current_animation.begins_with('right')

func _process(delta: float) -> void:
	
	if in_playstate:
		process_playstate_behavior(delta)

func process_playstate_behavior(delta:float) -> void:
	if holding:
		hold_animation()
		
	if is_singing() and not holding:
		sing_timer += delta
		
	if sing_timer >= GameManager.seconds_per_step * sing_duration and released_input():
		dance()
		sing_timer = 0

func released_input() -> bool:
	if not is_player: return true
	
	return not Input.is_action_pressed(&'note_left') \
	 and not Input.is_action_pressed(&'note_down') \
	 and not Input.is_action_pressed(&'note_up') \
	 and not Input.is_action_pressed(&'note_right')
	

func get_real_animation(animation_name: StringName = &""):
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

func play_animation_old(animation_name: StringName = &"", time: float = -1.0):
	if process_mode == Node.PROCESS_MODE_DISABLED or not animation_player:
		return
	
	
	animation_name = StringName(animation_prefix + animation_name)
	var real_animation_name: StringName = get_real_animation(animation_name)
	
	
	# Will not run idle animation if you can not run
	if animation_player is AnimateSymbol:
		#if animation_name == animation_prefix + idle_animation:
			#if !can_idle:
				#return
		
		#if forced_animations.has(current_animation) and !forced_animations.has(animation_name) and animation_name != (animation_prefix + idle_animation):
			#return
		
		if offsets.has(real_animation_name):
			animation_player.offset = offsets.get(real_animation_name, animation_player.offset)
		
		current_animation = animation_name
		animation_player.symbol = real_animation_name
		animation_player.frame = 0
		animation_player.playing = true
		can_idle = false
		return
	
	if animation_names.has(animation_name):
		#if animation_name == (animation_prefix + idle_animation):
			#if !can_idle:
				#return
		
		# Forced animations blocking other ones
		#if forced_animations.has(current_animation) and !forced_animations.has(animation_name) and animation_name != (animation_prefix + idle_animation):
			#return
		
		can_idle = false
		
		if (time >= 0):
			# Calculates the speed it would need to go at the time requested
			var animatiom_speed: float = animation_player.sprite_frames.get_animation_speed(real_animation_name)
			var frame_count: int = animation_player.sprite_frames.get_frame_count(real_animation_name)
			
			current_animation = animation_name
			animation_player.play(real_animation_name, frame_count / (animatiom_speed * time))
		else:
			current_animation = animation_name
			animation_player.play(real_animation_name, 1)
		
		animation_player.set_frame_and_progress(0, 0)
		
		if offsets.has(real_animation_name):
			var offsets_to_use = offsets.get(real_animation_name)
			if offsets.get(animation_player.animation) is PackedVector2Array:
				offsets_to_use = offsets.get(animation_player.animation)[animation_player.frame - 1]
				
			if animation_player is AnimatedSprite3D:
				animation_player.offset.x = offsets_to_use.x
				animation_player.offset.y = -offsets_to_use.y
			else:
				animation_player.position.x = offsets_to_use.x
				animation_player.position.y = offsets_to_use.y
	else:
		animation_player.set_frame_and_progress(0, 0)
		printerr("Animation ", animation_name, " not found")
