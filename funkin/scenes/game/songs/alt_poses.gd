extends "uid://b0vmqp1rjpt6n"

func note_hit(time, lane, note_type, hit_time, strum_manager):
	get_tree().set_group(get_group(strum_manager), "animation_prefix",
	&"mom_" if str(note_type) == "mom" else &"")
	super(time, lane, note_type, hit_time, strum_manager)
