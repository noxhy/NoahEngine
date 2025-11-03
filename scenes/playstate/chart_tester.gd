extends "res://scenes/playstate/songs/basic_song.gd"

# Called when the node enters the scene tree for the first time.
func _ready():
	characters = []
	playstate_host.ui.set_player_color(Color.GREEN)
	playstate_host.ui.set_enemy_color(Color.RED)
	
	await playstate_host.setup_finished
	
	if get_node_or_null("%Stage") != null:
		playstate_host.conductor.connect("new_beat", %Stage._on_conductor_new_beat)
	
	playstate_host.conductor.connect("new_beat", self._on_conductor_new_beat)
	%Background.modulate = Color(randf(), randf(), randf())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$"UI/Chart Stats".text = "Song: " + str(playstate_host.song_data.title)
	$"UI/Chart Stats".text += "\n" + "Artist: " + str(playstate_host.song_data.artist)
	$"UI/Chart Stats".text += "\n" + "Difficulty: " + str(GameManager.difficulty)
	$"UI/Chart Stats".text += "\n" + "Tempo: " + str(playstate_host.conductor.tempo)
	$"UI/Chart Stats".text += "\n" + "Scroll Speed: " + str(playstate_host.ui.strums[0].get_node(playstate_host.ui.strums[0].strums[0]).scroll_speed)
	$"UI/Chart Stats".text += "\n" + str(GameManager.tallies).replace("{", "").replace("}", "").replace(",", "\n")

func _on_conductor_new_beat(current_beat, measure_relative):
	pass

func _on_create_note(time, lane, note_length, note_type, tempo):
	if lane > 3: playstate_host.strums[1].create_note(time, lane % 4, note_length, note_type, tempo)
	else: playstate_host.strums[0].create_note(time, lane % 4, note_length, note_type, tempo)


func note_hit(time, lane, note_type, hit_time, strumhandler):
	playstate_host.note_hit(time, lane, note_type, hit_time, strumhandler)


func note_holding(time, lane, note_type, strumhandler):
	playstate_host.note_holding(time, lane, note_type, strumhandler)


func note_miss(time, lane, length, note_type, hit_time, strumhandler):
	if !strumhandler.enemy_slot: if note_type == -1:
		SoundManager.anti_spam.play()
	playstate_host.note_miss(time, lane, length, note_type, hit_time, strumhandler)


func _on_combo_break():
	SoundManager.miss.play()
