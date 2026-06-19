extends BasicSong
class_name FunkinSong

@export_file('*.tscn') var death_scene: String = "uid://bd083xcqslcsd"

func note_hit(note: Note, lane: int, hit_time: float, strum_manager: StrumManager):
	get_tree().set_group(get_group_from_manager(strum_manager), "animation_prefix",
	&"mom_" if note.note_type == "mom" else &"")
	super(note, lane, hit_time, strum_manager)


func died():
	get_tree().change_scene_to_file(death_scene)
