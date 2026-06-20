extends BasicSong
class_name FunkinSong

@export_file('*.tscn') var death_scene: String = "uid://bd083xcqslcsd"

func _process(delta: float) -> void:
	if player:
		DeathScreen.player_position = player.global_position
		DeathScreen.player_scale = Vector2(player.scale.x,player.scale.y)
	
	DeathScreen.camera_zoom = playstate_host.camera.get_zoom()


func note_hit(note: Note, lane: int, hit_time: float, strum_manager: StrumManager):
	get_tree().set_group(get_group_from_manager(strum_manager), "animation_prefix",
	&"mom_" if note.note_type == "mom" else &"")
	super(note, lane, hit_time, strum_manager)


func died():
	get_tree().change_scene_to_file(death_scene)
