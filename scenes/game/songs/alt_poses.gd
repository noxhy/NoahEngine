extends "res://scenes/game/songs/basic_song.gd"

func note_hit(time, lane, note_type, hit_time, strum_manager):
	get_tree().call_group(
		&"enemy" if strum_manager.enemy_slot else &"player", &"set_prefix",
		&"mom_" if note_type == 1 else &"")
	super(time, lane, note_type, hit_time, strum_manager)

func note_holding(time, lane, note_type, strum_manager):
	get_tree().call_group(
		&"enemy" if strum_manager.enemy_slot else &"player", &"set_prefix",
		&"mom_" if note_type == 1 else &"")
	super(time, lane, note_type, strum_manager)
