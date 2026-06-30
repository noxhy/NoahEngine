extends BasicSong

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	
	playstate_host.ui.target_zoom = Vector2.ONE * (get_window().content_scale_size.x / 1280.0)
	playstate_host.ui.offset = get_window().content_scale_size / 2
	Signals.connect("play_setup_finished", self._on_setup_finished)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta) -> void:
	$"UI/Chart Stats".text = "Song: " + str(playstate_host.song_data.title)
	$"UI/Chart Stats".text += "\n" + "Artist: " + str(playstate_host.song_data.artist)
	$"UI/Chart Stats".text += "\n" + "Difficulty: " + str(GameManager.difficulty)
	$"UI/Chart Stats".text += "\n" + "Tempo: " + str(GameManager.conductor.tempo)
	$"UI/Chart Stats".text += "\n" + "Scroll Speed: " + str(playstate_host.ui.strums[0].strums[0].scroll_speed)
	$"UI/Chart Stats".text += "\n" + str(GameManager.tallies).replace("{", "").replace("}", "").replace(",", "\n")


func _on_setup_finished() -> void:
	get_tree().call_group(&"strums", "set_skin", ChartEditor.note_skin)
