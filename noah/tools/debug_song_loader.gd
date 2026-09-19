@tool
extends Node
## Tool Node to make testing songs simpler. Allows loading a song scene directly from editor by setting the necessary backend variables

## The song to load
@export var song: Song : 
	set(v):
		song = v
		if not song.difficulties.keys().has(difficulty):
			for key in song.difficulties.keys():
				difficulty = key
				break
		notify_property_list_changed()
		

## The difficulty to load
@export_storage var difficulty: String = 'hard'
@export var mode: GameManager.PLAY_MODE = GameManager.PLAY_MODE.CHARTING

func _enter_tree() -> void:
	if not Engine.is_editor_hint():
		GameManager.load_songs([song], difficulty, mode)
	 # chart manager is a bit confusing it sounds like more important but its just a in between to hold some chart editor values
	#ChartManager.song = song



func _get_property_list() -> Array[Dictionary]:
	var props: Array[Dictionary] = []
	if song:
		props.append({
			"name": &"difficulty",
			"type": TYPE_STRING_NAME, 
			"usage": PROPERTY_USAGE_DEFAULT, 
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": ",".join( song.difficulties.keys())
		})
	return props
