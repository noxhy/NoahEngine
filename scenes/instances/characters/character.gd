@icon("res://assets/sprites/nodes/character.png")

extends Node2D
class_name Character

@export_group("Animation Offset")
@export var idle_animation = &"idle"
@export var animation_names: Dictionary[StringName, StringName] = {}
@export var offsets: Dictionary[StringName, Vector2] = {}

@export_group("Playstate")
@export var icons: SpriteFrames = preload("res://assets/sprites/playstate/icons/face.tres")
@export var color: Color = Color(0.168627, 0.121569, 0.203922)

var current_animation: StringName = idle_animation
var current_prefix: StringName = &""
var can_idle: bool = true

@onready var sprite = $AnimatedSprite2D

func _ready():
	sprite.play()

func play_animation(animation_name: StringName = &"", time: float = -1.0):
	# Will not run idle animation if you can not run
	if animation_names.has(animation_name):
		if animation_name == idle_animation:
			if !can_idle:
				return
		
		var real_animation_name: StringName = animation_names.get(current_prefix + animation_name, sprite.animation)
		can_idle = false
		
		if (time >= 0):
			# Calculates the speed it would need to go at the time requested
			var animatiom_speed: float = sprite.sprite_frames.get_animation_speed(real_animation_name)
			var frame_count: int = sprite.sprite_frames.get_frame_count(real_animation_name) 
			
			current_animation = animation_name
			sprite.play(real_animation_name, frame_count / (animatiom_speed * time))
		else:
			current_animation = animation_name
			sprite.play(real_animation_name, 1)
		
		sprite.frame = 0
		
		if offsets.has(real_animation_name):
			if offsets.get(sprite.animation) is PackedVector2Array:
				sprite.position = offsets.get(sprite.animation)[sprite.frame - 1]
			else:
				sprite.position = offsets.get(real_animation_name)
	else:
		
		sprite.frame = 0
		printerr("(Character) Animation \"", animation_name , "\" not found")


func get_real_animation(animation_name: String = ""):
	if animation_names.has(animation_name):
		var real_animation_name: String = animation_names.get(animation_name)
		return real_animation_name
	else:
		return null

func set_prefix(prefix: StringName):
	current_prefix = prefix

func _on_animated_sprite_2d_animation_finished():
	if self.is_in_group("back_to_idle"):
		if current_animation != idle_animation:
			can_idle = true
			play_animation(idle_animation)
			sprite.stop()
	can_idle = true


func _on_animated_sprite_2d_frame_changed():
	var duration = sprite.sprite_frames.get_frame_duration(sprite.animation, sprite.frame)
	sprite.rotation_degrees = 0 if duration == 1 else -90
	
	if offsets.get(sprite.animation) is PackedVector2Array:
		sprite.position = offsets.get(sprite.animation)[sprite.frame]
		print("Frame: ", sprite.frame, " Offset: ", offsets.get(sprite.animation)[sprite.frame])
