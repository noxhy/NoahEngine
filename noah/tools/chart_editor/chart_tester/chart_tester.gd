extends BasicSong

@onready var stats_label: Label = $"UI/Chart Stats"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	
	playstate.ui.target_zoom = Vector2.ONE * (get_window().content_scale_size.x / 1280.0)
	playstate.ui.offset = get_window().content_scale_size / 2
	Signals.stats_changed.connect(update_stats)
	get_tree().call_group(&"strums", &"set_skin", ChartEditor.note_skin)

func update_stats(stats: NoahStats):
	var string_to_show: String = "Song: " + str(playstate.song.title)
	string_to_show += "\n" + "Artist: " + str(playstate.song.artist)
	string_to_show += "\n" + "Difficulty: " + str(GameManager.difficulty)
	string_to_show += "\n" + "Tempo: " + str(GameManager.conductor.tempo)
	string_to_show += "\n" + "Scroll Speed: " + str(playstate.scroll_speed)
	string_to_show += "\n" + str(playstate.song_stats)
	
	stats_label.text = string_to_show
