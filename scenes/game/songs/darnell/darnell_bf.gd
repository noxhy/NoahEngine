extends "res://scenes/game/songs/basic_song.gd"

func _on_conductor_new_beat(current_beat, measure_relative):
	
	playstate_host.ui.icon_bop(playstate_host.conductor.seconds_per_beat * 0.5 *
	(1 / playstate_host.instrumental.pitch_scale))
