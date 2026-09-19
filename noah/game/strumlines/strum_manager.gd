@icon("uid://yl4giaklgpx0")
@tool
extends Node2D
class_name StrumManager

@export_tool_button("Refresh Skin", "ArrowUp") var _force_skin_update = _refresh_skin
## skin
@export var note_skin: NoteSkin: set = set_skin
## List of Nodes of the strumlines.
@export var strums: Array[Strum] : set = set_strums
## Vocal track ID.
@export var id: int = 0

## If [code]true[/code], the strumlines will read the player's input.
@export var can_press: bool: set = set_press
## If [code]true[/code], the strumlines will hit notes automatically. Typically used for botplay
## or the enemy strumlines.
@export var auto_play: bool: set = set_auto_play
## If [code]true[/code], the strumlines will create a note splash effect when hitting or holding a
## note. Typically used for the player strumlines.
@export var can_splash: bool: set = set_can_splash
## If [code]true[/code], the strumlines will count as a enemy strumline. Enemy strumlines do not
## affect player stats.
@export var enemy_slot: bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	can_press = can_press
	auto_play = auto_play
	can_splash = can_splash
	note_skin = note_skin
	
	if not Engine.is_editor_hint():
		var i: int = 0
		for strum in strums:
			strum.lane = i
			i += 1

func _refresh_skin():
	note_skin = note_skin

#region Setters
func set_strums(v: Array[Strum]) -> void:
	strums = v
	if Engine.is_editor_hint():
		note_skin = note_skin

func set_skin_editor(v: NoteSkin) -> void:
	if not v:
		v = load("uid://buly8rgmgrrnm")
	
	for strum in strums:
		var spr = strum.get_node("OffsetSprite") #this isnt ideal but i do not want to make strums themselves tool . . . 
		if not spr:
			return
		
		var anim = strum.strum_name + '_strum'
		if not v.strums_texture.has_animation(anim):
			anim = 'left_strum'
		
		spr.sprite_frames = v.strums_texture
		spr.animation = anim
		spr.scale = Vector2.ONE * v.notes_scale
		spr.offsets = v.offsets
		
		if v.pixel_texture:
			spr.texture_filter = TEXTURE_FILTER_NEAREST
		

func set_skin(v: NoteSkin) -> void:
	if not is_node_ready():
		note_skin = v
		return
	
	note_skin = v
	if Engine.is_editor_hint():
		set_skin_editor(v)
	else:
		for strum in strums:
			strum.set_skin(v)
		

func set_press(v: bool) -> void:
	if not is_node_ready() or Engine.is_editor_hint():
		can_press = v
		return
	
	can_press = v
	for strum in strums:
		strum.can_press = v

func set_auto_play(v: bool) -> void:
	if not is_node_ready() or Engine.is_editor_hint():
		auto_play = v
		return
	
	auto_play = v
	for strum in strums:
		strum.auto_play = v

func set_can_splash(v: bool) -> void:
	if not is_node_ready() or Engine.is_editor_hint():
		can_splash = v
		return
	
	can_splash = v
	for strum in strums:
		strum.can_splash = v
#region

func set_offset(v: float) -> void:
	for strum in strums:
		strum.offset = v

func set_ignored_note_types(v: Array) -> void:
	for strum in strums:
		strum.ignored_note_types = v

func set_scroll_speed(v: float) -> void:
	for strum in strums:
		strum.scroll_speed = v

func set_scroll(v: float) -> void:
	for strum in strums:
		strum.scroll = v

## @deprecated: Use [member get_strum] instead.
func get_strumline(lane: int) -> Strum:
	return get_strum(lane)

## Gets a strum from lane
func get_strum(lane: int) -> Strum:
	return strums[lane]

## Gets the scroll speed of a specific strum by lane
func get_scroll_speed(lane: int) -> float:
	return get_strum(lane).scroll_speed
	
## Creates a new [BasicNote] for a lane
func create_note(time: float, lane: int, length: float, note_type: String, tempo: float) -> BasicNote:
	return get_strum(lane).create_note(time, length, note_type, tempo)

## Spawns a notes splash onto a strum
func create_splash(lane: int, animation_name: StringName) -> void:
	var anim_to_play: StringName = animation_name + &"_splash"
	if animation_name.is_empty():
		anim_to_play = get_strum(lane).strum_name + &"_splash"
	
	get_strum(lane).create_splash(anim_to_play)
