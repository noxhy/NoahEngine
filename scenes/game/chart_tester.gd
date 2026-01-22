extends "res://scenes/game/songs/basic_song.gd"

# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	playstate_host.ui.set_player_color(Color.GREEN)
	playstate_host.ui.set_enemy_color(Color.RED)
	playstate_host.ui.player_icon.visible = false
	playstate_host.ui.enemy_icon.visible = false
	
	%Background.modulate = Color(randf(), randf(), randf())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$"UI/Chart Stats".text = "Song: " + str(playstate_host.song_data.title)
	$"UI/Chart Stats".text += "\n" + "Artist: " + str(playstate_host.song_data.artist)
	$"UI/Chart Stats".text += "\n" + "Difficulty: " + str(GameManager.difficulty)
	$"UI/Chart Stats".text += "\n" + "Tempo: " + str(playstate_host.conductor.tempo)
	$"UI/Chart Stats".text += "\n" + "Scroll Speed: " + str(playstate_host.ui.strums[0].get_node(playstate_host.ui.strums[0].strums[0]).scroll_speed)
	$"UI/Chart Stats".text += "\n" + str(GameManager.tallies).replace("{", "").replace("}", "").replace(",", "\n")


func _on_play_state_host_setup_finished() -> void:
	get_tree().call_group(&"strums", "set_skin", ChartEditor.note_skin)
	if SettingsManager.get_value(SettingsManager.SEC_CHART, "start_at_current_position"):
		playstate_host.play_song(ChartEditor.song_position)
