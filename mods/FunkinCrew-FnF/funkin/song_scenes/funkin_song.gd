extends BasicSong
class_name FunkinSong

@export var death_scene: PackedScene = load("uid://bd083xcqslcsd")
var current_death_scene = null

func _ready() -> void:
	super()
	current_death_scene = death_scene.instantiate()

func _process(delta: float) -> void:
	if player:
		current_death_scene.player_position = player.global_position
		current_death_scene.player_scale = Vector2(player.scale.x,player.scale.y)
	
	current_death_scene.camera_zoom = playstate_host.camera.get_zoom()


func note_hit(note: Note, lane: int, hit_time: float, strum_manager: StrumManager):
	get_tree().set_group(get_group_from_manager(strum_manager), "animation_prefix",
	&"mom_" if note.note_type == "mom" else &"")
	super(note, lane, hit_time, strum_manager)


func died():
	get_tree().change_scene_to_node(current_death_scene)
