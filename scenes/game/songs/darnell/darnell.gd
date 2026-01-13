extends "res://scenes/game/songs/basic_song.gd"

func _on_conductor_new_beat(current_beat, measure_relative):
	if measure_relative % 2 == 0:
		get_tree().call_group(&"player", &"play_animation", &"idle")
		
		for node in get_tree().get_nodes_in_group(&"metronome"):
			if (node.current_animation == node.idle_animation):
				node.can_idle = true
		
		get_tree().call_group(&"metronome", &"play_animation", &"idle", GameManager.seconds_per_beat * 2)
	
	if measure_relative == 0:
		get_tree().call_group(&"enemy", &"play_animation", &"idle", GameManager.seconds_per_beat * 4)

func _on_new_event(time, event_name, event_parameters):
	match event_name:
		"camera_position":
			if int(event_parameters[0]) == 0:
				%Metronome.get_node("AnimationPlayer").play("look_right")
			else:
				%Metronome.get_node("AnimationPlayer").play("look_left")
