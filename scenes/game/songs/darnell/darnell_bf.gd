extends "res://scenes/game/songs/basic_song.gd"

func _on_conductor_new_beat(current_beat, measure_relative):
	if measure_relative % 2 == 0:
		
		for player in get_tree().get_nodes_in_group(&"player"):
			if not player.is_singing():
				player.dance()
		
		for enemy in get_tree().get_nodes_in_group(&"enemy"):
			if not enemy.is_singing():
				enemy.dance()
	
	
	get_tree().call_group(&"metronome", &"dance")
	
	playstate_host.ui.icon_bop(playstate_host.conductor.seconds_per_beat * 0.5 *
	(1 / playstate_host.instrumental.pitch_scale))
