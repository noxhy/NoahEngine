extends BasicSong

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	
	playstate.ui.target_zoom = Vector2.ONE * (get_window().content_scale_size.x / 1280.0)
	playstate.ui.offset = get_window().content_scale_size / 2
	Signals.connect("play_setup_finished", self._on_setup_finished)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta) -> void:
	super(delta)
	var string_to_show = "Song: " + str(playstate.song_data.title)
	string_to_show += "\n" + "Artist: " + str(playstate.song_data.artist)
	string_to_show += "\n" + "Difficulty: " + str(GameManager.difficulty)
	string_to_show += "\n" + "Tempo: " + str(GameManager.conductor.tempo)
	string_to_show += "\n" + "Scroll Speed: " + str(playstate.strums[0].strums[0].scroll_speed)
	string_to_show += "\n" + str(playstate.song_stats)
	
	$"UI/Chart Stats".text = string_to_show


func _on_setup_finished() -> void:
	get_tree().call_group(&"strums", "set_skin", ChartEditor.note_skin)
	var drunk: ModchartEffect = DrunkModchartEffect.new()
	drunk.x_percentage = 3
	drunk.x_speed = 2
	drunk.x_period = 200 * PI
	
	#playstate.strums[0].strums[0].modchart_effects.add_effect(drunk)
	
	for strum in playstate.strums[0].strums:
		if strum is Strum:
			strum.node_type = 1
			strum.modchart_effects.add_effect(drunk)
