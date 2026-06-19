@icon("uid://yl4giaklgpx0")
extends Node2D
class_name StrumManager

signal note_hit(note: Note, lane: int, hit_time_difference: float, manager: StrumManager)
signal note_holding(note: Note, lane: int, hold_difference: float, manager: StrumManager)
signal note_miss(note: Note, lane: int, manager: StrumManager)

@export var note_skin: NoteSkin = NoteSkin.new()
## List of Nodes of the strumlines.
@export var strums: Array[Strum] = []
## Vocal track ID.
@export var id: int = 0

## If [code]true[/code], the strumlines will read the player's input.
@export var can_press: bool = true
## If [code]true[/code], the strumlines will hit notes automatically. Typically used for botplay
## or the enemy strumlines.
@export var auto_play: bool = false
## If [code]true[/code], the strumlines will create a note splash effect when hitting or holding a
## note. Typically used for the player strumlines.
@export var can_splash: bool = false
## If [code]true[/code], the strumlines will count as a enemy strumline. Enemy strumlines do not
## affect player stats.
@export var enemy_slot: bool = false

# Called when the node enters the scene tree for the first time.
func vanilla_3202702520__ready():
	set_skin(note_skin)
	set_press(can_press)
	set_auto_play(auto_play)
	set_can_splash(can_splash)
	set_enemy_slot(enemy_slot)
	
	for strum in strums:
		strum.connect(&"note_hit", self._on_note_hit)
		strum.connect(&"note_holding", self._on_note_holding)
		strum.connect(&"note_miss", self._on_note_miss)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func vanilla_3202702520__process(delta):
	pass


func vanilla_3202702520_set_skin(new_skin: NoteSkin):
	for strum in strums:
		strum.set_skin(new_skin)


# PlayState Util


func vanilla_3202702520_set_scroll_speed(new_scroll_speed: float):
	for strum in strums:
		strum.scroll_speed = new_scroll_speed


func vanilla_3202702520_set_scroll(new_scroll: float):
	for strum in strums:
		strum.scroll = new_scroll


func vanilla_3202702520_set_press(toggle: bool):
	for strum in strums:
		strum.can_press = toggle


func vanilla_3202702520_set_auto_play(toggle: bool):
	for strum in strums:
		strum.auto_play = toggle


func vanilla_3202702520_set_offset(offset: float):
	for strum in strums:
		strum.offset = offset


func vanilla_3202702520_set_can_splash(toggle: bool):
	for strum in strums:
		strum.can_splash = toggle


func vanilla_3202702520_set_enemy_slot(toggle: bool):
	for strum in strums:
		strum.enemy_slot = toggle


func vanilla_3202702520_set_ignored_note_types(_note_types: Array):
	for strum in strums:
		strum.ignored_note_types = _note_types


func vanilla_3202702520_get_strumline(lane: int) -> Strum:
	return strums[lane]

func vanilla_3202702520_get_scroll_speed(lane: int) -> float:
	return get_strumline(lane).scroll_speed


func vanilla_3202702520_create_note(time: float, lane: int, length: float, note_type: String, tempo: float):
	strums[lane].create_note(time, length, note_type, tempo)

func vanilla_3202702520_create_splash(lane: int, animation_name: String):
	strums[lane].create_splash(animation_name) 

# Visual Util
func vanilla_3202702520_glow_strum(lane: int):
	strums[lane].glow_strum()


func vanilla_3202702520_press_strum(lane: int):
	strums[lane].press_strum()


func vanilla_3202702520__on_note_hit(note: Note, hit_time: float, strum: Strum):
	emit_signal(&"note_hit", note, strums.find(strum), hit_time, self)


func vanilla_3202702520__on_note_holding(note: Note, hold_difference: float, strum: Strum):
	emit_signal(&"note_holding", note, strums.find(strum), hold_difference, self)


func vanilla_3202702520__on_note_miss(note:Note, strum: Strum):
	emit_signal(&"note_miss", note, strums.find(strum), self)


# ModLoader Hooks - The following code has been automatically added by the Godot Mod Loader.


func _ready():
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_3202702520__ready, [], 3191345196)
	else:
		return vanilla_3202702520__ready()


func _process(delta):
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_3202702520__process, [delta], 2983716534)
	else:
		return vanilla_3202702520__process(delta)


func set_skin(new_skin: NoteSkin):
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_3202702520_set_skin, [new_skin], 3687682936)
	else:
		return vanilla_3202702520_set_skin(new_skin)


func set_scroll_speed(new_scroll_speed: float):
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_3202702520_set_scroll_speed, [new_scroll_speed], 3779926050)
	else:
		return vanilla_3202702520_set_scroll_speed(new_scroll_speed)


func set_scroll(new_scroll: float):
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_3202702520_set_scroll, [new_scroll], 83136370)
	else:
		return vanilla_3202702520_set_scroll(new_scroll)


func set_press(toggle: bool):
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_3202702520_set_press, [toggle], 1431142320)
	else:
		return vanilla_3202702520_set_press(toggle)


func set_auto_play(toggle: bool):
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_3202702520_set_auto_play, [toggle], 2752183505)
	else:
		return vanilla_3202702520_set_auto_play(toggle)


func set_offset(offset: float):
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_3202702520_set_offset, [offset], 4224692746)
	else:
		return vanilla_3202702520_set_offset(offset)


func set_can_splash(toggle: bool):
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_3202702520_set_can_splash, [toggle], 3913238527)
	else:
		return vanilla_3202702520_set_can_splash(toggle)


func set_enemy_slot(toggle: bool):
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_3202702520_set_enemy_slot, [toggle], 3486799394)
	else:
		return vanilla_3202702520_set_enemy_slot(toggle)


func set_ignored_note_types(_note_types: Array):
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_3202702520_set_ignored_note_types, [_note_types], 3033134484)
	else:
		return vanilla_3202702520_set_ignored_note_types(_note_types)


func get_strumline(lane: int) -> Strum:
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_3202702520_get_strumline, [lane], 2769960090)
	else:
		return vanilla_3202702520_get_strumline(lane)


func get_scroll_speed(lane: int) -> float:
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_3202702520_get_scroll_speed, [lane], 1322209686)
	else:
		return vanilla_3202702520_get_scroll_speed(lane)


func create_note(time: float, lane: int, length: float, note_type: String, tempo: float):
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_3202702520_create_note, [time, lane, length, note_type, tempo], 3620327745)
	else:
		return vanilla_3202702520_create_note(time, lane, length, note_type, tempo)


func create_splash(lane: int, animation_name: String):
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_3202702520_create_splash, [lane, animation_name], 4248478806)
	else:
		return vanilla_3202702520_create_splash(lane, animation_name)


func glow_strum(lane: int):
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_3202702520_glow_strum, [lane], 1887757515)
	else:
		return vanilla_3202702520_glow_strum(lane)


func press_strum(lane: int):
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_3202702520_press_strum, [lane], 3767799327)
	else:
		return vanilla_3202702520_press_strum(lane)


func _on_note_hit(note: Note, hit_time: float, strum: Strum):
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_3202702520__on_note_hit, [note, hit_time, strum], 1628602125)
	else:
		return vanilla_3202702520__on_note_hit(note, hit_time, strum)


func _on_note_holding(note: Note, hold_difference: float, strum: Strum):
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_3202702520__on_note_holding, [note, hold_difference, strum], 2731282541)
	else:
		return vanilla_3202702520__on_note_holding(note, hold_difference, strum)


func _on_note_miss(note: Note, strum: Strum):
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_3202702520__on_note_miss, [note, strum], 2204442340)
	else:
		return vanilla_3202702520__on_note_miss(note, strum)
