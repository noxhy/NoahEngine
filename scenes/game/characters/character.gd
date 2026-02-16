@icon("res://assets/sprites/nodes/character.png")
extends Node2D
class_name Character

@export_group("Animation Offset")
@export var idle_animation: String = "idle"
@export var animation_names: Dictionary[StringName, StringName] = {}
@export var offsets: Dictionary[StringName, Vector2] = {}
@export var hold_frames: Dictionary[StringName, int] = {}
@export var forced_animations: Array[StringName]
@export var animation_prefix: StringName = &""

@export_group("Playstate")
@export var icons: SpriteFrames = load("res://assets/sprites/playstate/icons/face.tres")
@export var color: Color = Color(0.168627, 0.121569, 0.203922)

@onready var animation_player = $AnimatedSprite2D

var current_animation: StringName = idle_animation
var can_idle: bool = true
var holding: bool = false

func _ready():
	if animation_player:
		animation_player.play()
		animation_player.connect(&"animation_finished", self._on_animated_sprite_2d_animation_finished)
	else:
		animation_player = $AnimateSymbol
		animation_player.connect(&"finished", self._on_animate_symbol_finished)

func play_animation(animation_name: StringName = &"", time: float = -1.0):
	if process_mode == Node.PROCESS_MODE_DISABLED:
		return
	
	animation_name = StringName(animation_prefix + animation_name)
	var real_animation_name: StringName = get_real_animation(animation_name)
	# Will not run idle animation if you can not run
	if animation_player is AnimateSymbol:
		if animation_name == animation_prefix + idle_animation:
			if !can_idle:
				return
		
		if forced_animations.has(current_animation) and !forced_animations.has(animation_name) and animation_name != (animation_prefix + idle_animation):
			return
		
		if offsets.has(real_animation_name):
			animation_player.offset = offsets.get(real_animation_name, animation_player.offset)
		
		current_animation = animation_name
		animation_player.symbol = real_animation_name
		animation_player.frame = 0
		animation_player.playing = true
		can_idle = false
		return
	
	if animation_names.has(animation_name):
		if animation_name == (animation_prefix + idle_animation):
			if !can_idle:
				return
		
		# Forced animations blocking other ones
		if forced_animations.has(current_animation) and !forced_animations.has(animation_name) and animation_name != (animation_prefix + idle_animation):
			return
		
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
			if offsets.get(animation_player.animation) is PackedVector2Array: animation_player.position = offsets.get(animation_player.animation)[animation_player.frame - 1]
			else: animation_player.position = offsets.get(real_animation_name)
	else:
		animation_player.set_frame_and_progress(0, 0)
		printerr("Animation ", animation_name, " not found")

func _process(delta: float) -> void:
	if holding:
		hold_animation()

func get_real_animation(animation_name: StringName = &""):
	return animation_names.get(animation_name, &"")


func set_prefix(prefix: StringName):
	animation_prefix = prefix


func get_current_frame_texture() -> Texture:
	return animation_player.sprite_frames.get_frame_texture(animation_player.animation,
	animation_player.frame)


func _on_animated_sprite_2d_animation_finished():
	can_idle = true


func hold_animation():
	var hold_frame: int = 0
	var real_animation: StringName
	var length: int
	if animation_player is AnimatedSprite2D:
		real_animation = get_real_animation(current_animation)
		length = animation_player.sprite_frames.get_frame_count(real_animation)
		hold_frame = hold_frames.get(real_animation, length - 1)
		
		if animation_player.frame == length - 1 and animation_player.frame_progress == 1:
			animation_player.frame = hold_frame
		
		animation_player.play()
	else:
		real_animation = get_real_animation(current_animation)
		length = animation_player.get_animation_length()
		hold_frame = hold_frames.get(real_animation, length - 1)
		
		if (animation_player.frame == length - 1
		and animation_player.frame_timer >= 1.0 / animation_player.fps):
			animation_player.frame = hold_frame
		
		animation_player.playing = true
	
	can_idle = false


func set_holding(toggled: bool):
	holding = toggled


func _on_animate_symbol_finished() -> void:
	can_idle = true


func _on_animated_sprite_2d_frame_changed():
	if offsets.get(animation_player.animation) is PackedVector2Array:
		animation_player.position = offsets.get(animation_player.animation)[animation_player.frame]
		print("Frame: ", animation_player.frame, " Offset: ", offsets.get(animation_player.animation)[animation_player.frame])
