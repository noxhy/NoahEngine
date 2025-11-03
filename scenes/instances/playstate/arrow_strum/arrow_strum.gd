@icon("res://tools/node_sprites/strum arrows.png")

extends Node2D
class_name ArrowStrum

const PIXELS_PER_SECOND = 450

@onready var note_preload = preload("res://scenes/instances/playstate/note/note.tscn")
@onready var splash_preload = preload("res://scenes/instances/playstate/note/note_splash.tscn")

signal created_note(time: float, strum_name: StringName, length: float, note_type: Variant)
signal note_hit(time: float, strum_name: StringName, note_type: Variant, hit_time: float)
signal note_holding(time: float, strum_name: StringName, note_type: Variant)
signal note_miss(time: float, strum_name: StringName, length: float, note_type: Variant, hit_time: float)

@export var note_skin: NoteSkin
@export var input: String = ""
@export var strum_name: String = ""

@export var can_press: bool  = true
@export var auto_play: bool  = false
@export var can_splash: bool  = false
@export var enemy_slot: bool = false
@export var ignored_note_types: Array = []

enum STATE {
	IDLE,
	PRESSED,
	GLOW,
}

var note_types = [""]

var scroll_speed: float = 1.0
var scroll: float = 1.0
var song_speed: float = 1.0
var offset: float = 0.0
var note_list: Array = []
var pressing: bool = false
var previous_note = null
var state = STATE.IDLE

var tempo: float = 60.0
var seconds_per_beat:float = 60.0 / tempo

var reset_timer: float = 0.0

@onready var sprite = $OffsetSprite
@onready var hold_cover_sprite = $"Hold Cover"

# Called when the node enters the scene tree for the first time.
func _ready():
	sprite.play_animation(strum_name)
	hold_cover_sprite.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	## Note movement
	for note in note_list:
		var time_difference = (note.time - offset) - GameManager.song_position
		
		# time_difference = snapped(time_difference, seconds_per_beat / 4)
		note.scroll_speed = scroll_speed
		note.scroll = scroll
		
		if time_difference <= GameManager.SHIT_RATING_WINDOW:
			note.can_press = true
			
			if !enemy_slot:
				if note == note_list[0]:
					if SettingsManager.get_setting("glow_notes"):
						note.modulate = Color(1.5, 1.5, 1.5)
		
		if auto_play:
			if time_difference <= 0:
				if !ignored_note_types.has(note.note_type):
					if note != previous_note:
						emit_signal("note_hit", note.time, self.get_name(), note.note_type, 0)
						previous_note = note
					
					if note.length > 0:
						hold_cover_sprite.play_animation("cover " + strum_name)
						note.position.y = 0
						var temp = note.length
						note.length = time_difference + (note.start_length * GameManager.seconds_per_beat)
						note.length /= GameManager.seconds_per_beat
						
						
						if note.get_node("Note").visible:
							hold_cover_sprite.play_animation("cover " + strum_name + " start")
							hold_cover_sprite.visible = true
						
						note.get_node("Note").visible = false
						
						emit_signal("note_holding", temp - note.length, self.get_name(), note.note_type)
						state = STATE.GLOW
					
					else:
						reset_timer = GameManager.seconds_per_beat / 4 # shh
						state = STATE.GLOW
						
						if can_splash:
								hold_cover_sprite.play_animation("cover " + strum_name + " end")
						else:
								hold_cover_sprite.visible = false
						
						note_list.erase(note)
						note.queue_free()
					
					
					continue
		
		if (time_difference + (note.start_length * GameManager.seconds_per_beat - offset - delta)) <= -GameManager.SHIT_RATING_WINDOW:
				note_list.erase(note)
				note.queue_free()
				
				emit_signal("note_miss", note.time - time_difference, self.get_name(), note.length, note.note_type, time_difference + (note.length * GameManager.seconds_per_beat))
	
	# Inputs
	
	if Input.is_action_just_pressed(input):
		if can_press:
			if note_list.size() > 0:
				var note = note_list[0]
	
				if note.can_press:
					if note.length <= 0:
						state = STATE.GLOW
	
						note_list.erase(note)
						note.queue_free()
						pressing = false
	
						var time_difference = (note.time - offset) - (GameManager.song_position)
						emit_signal("note_hit", note.time, self.get_name(), note.note_type, time_difference + (note.length * GameManager.seconds_per_beat))
	
					else:
						hold_cover_sprite.play_animation("cover " + strum_name)
	
						var time_difference = (note.time - offset) - (GameManager.song_position)
						emit_signal("note_hit", note.time, self.get_name(), note.note_type, time_difference)
	
						if !pressing:
							hold_cover_sprite.play_animation("cover " + strum_name + " start")
							hold_cover_sprite.visible = true
	
						pressing = true
	
				else:
					if !SettingsManager.get_setting("ghost_tapping"):
						emit_signal("note_miss", 0, self.get_name(), 0, -1, 0)
			else:
				if !SettingsManager.get_setting("ghost_tapping"):
					emit_signal("note_miss", 0, self.get_name(), 0, -1, 0)
	
	elif Input.is_action_pressed(input):
		if can_press:
			if pressing:
				if note_list.size() > 0:
					var note = note_list[0]
					
					if note.can_press:
						if note.length > 0:
							state = STATE.GLOW
						
							note.position.y = 0
							var temp = note.length
							note.length = ((note.time - offset) + (note.start_length * GameManager.seconds_per_beat)) - GameManager.song_position
							note.length /= GameManager.seconds_per_beat
							note.get_node("Note").visible = false
							emit_signal("note_holding", temp - note.length, self.get_name(), note.note_type)
							
							if !pressing:
								hold_cover_sprite.play_animation("cover " + strum_name + " start")
								hold_cover_sprite.visible = true
							
							pressing = true
							
							if note.length <= 0:
								pressing = false
								emit_signal("note_holding", temp - note.length, self.get_name(), note.note_type)
							
								if can_splash:
									hold_cover_sprite.play_animation("cover " + strum_name + " end")
								else:
									hold_cover_sprite.visible = false
								
								note_list.erase(note)
								note.queue_free()
			
			elif state != STATE.GLOW:
				state = STATE.PRESSED
	
	elif Input.is_action_just_released(input):
		if can_press:
			state = STATE.IDLE
			
			if hold_cover_sprite.animation != "cover " + strum_name + " end":
				hold_cover_sprite.visible = false
			
			if pressing:
				if note_list.size() > 0:
					var note = note_list[0]
					# Checks if you were holding a note before releasing
					if note.can_press:
						if note.length > 0:
							note.start_length = note.length
	
	if (reset_timer > 0):
		reset_timer -= delta
		if reset_timer <= 0:
			reset_timer = 0
			state = STATE.IDLE
	
	if state == STATE.IDLE:
		sprite.play_animation(strum_name)
	elif state == STATE.PRESSED:
		sprite.play_animation(strum_name + " press")
	elif state == STATE.GLOW: 
		sprite.play_animation(strum_name + " glow", false)

# Util

func set_skin(new_skin: NoteSkin):
	note_skin = new_skin
	
	sprite.frames = note_skin.strums_texture
	sprite.scale = Vector2(note_skin.notes_scale, note_skin.notes_scale)
	
	hold_cover_sprite.frames = note_skin.hold_covers_texture
	hold_cover_sprite.scale = Vector2(note_skin.hold_covers_scale, note_skin.hold_covers_scale)
	
	if note_skin.animation_names != null:
		sprite.animation_names.merge(note_skin.animation_names, true)
		hold_cover_sprite.animation_names.merge(note_skin.animation_names, true)
	
	sprite.offsets.merge(note_skin.offsets, true)
	hold_cover_sprite.offsets.merge(note_skin.offsets, true)
	
	if note_skin.pixel_texture:
		sprite.texture_filter = TEXTURE_FILTER_NEAREST
		hold_cover_sprite.texture_filter = TEXTURE_FILTER_NEAREST


func set_ignored_note_types(types: Array):
	ignored_note_types = types

func set_note_types(types: Array):
	note_types = types


func create_note(time: float, length: float, note_type: Variant, _tempo: float):
	self.tempo = tempo
	
	var note_instance = note_preload.instantiate()
	
	note_instance.time = time
	note_instance.length = length
	note_instance.start_length = length
	note_instance.note_type = note_type
	note_instance.position.y = 1000
	note_instance.scroll = scroll
	
	note_instance.direction = strum_name
	if note_type is int:
		note_type = clamp(note_type, 0, note_types.size() - 1)
		note_instance.animation = note_types[note_type] + strum_name
	else:
		note_instance.animation = note_type + strum_name
	
	note_instance.note_skin = note_skin
	
	add_child(note_instance)
	note_list.append(note_instance)
	
	emit_signal("created_note", time, self.get_name(), length, note_type)


# Visuals


func _on_offset_sprite_animation_finished():
	if !can_press:
		state = STATE.IDLE


func _on_hold_cover_frame_changed():
	# Ugly fix for that rotates sprite bullshit
	if hold_cover_sprite.animation.contains("idle"):
		if (hold_cover_sprite.frame == 0) or (hold_cover_sprite.frame == 3):
			hold_cover_sprite.rotation_degrees = 90
		else:
			hold_cover_sprite.rotation_degrees = 0
	else:
		hold_cover_sprite.rotation_degrees = 0


func _on_hold_cover_animation_finished():
	if hold_cover_sprite.animation == "cover " + strum_name + " start":
		hold_cover_sprite.play_animation("cover " + strum_name)

	if hold_cover_sprite.animation == "cover " + strum_name + " end": hold_cover_sprite.visible = false


func create_splash(animation_name: String = strum_name + " splash"):
	if can_splash:
		if SettingsManager.get_setting("note_splashes"):
			var splash_instance = splash_preload.instantiate()
			
			splash_instance.note_skin = note_skin
			splash_instance.scale = Vector2.ONE * note_skin.splash_scale
			
			add_child(splash_instance)
			splash_instance.get_node("OffsetSprite").play_animation(animation_name)
