extends "res://scenes/playstate/songs/basic_song.gd"

func _on_conductor_new_beat(current_beat, measure_relative):
	if measure_relative % 2 == 0:
		characters[0].play_animation("idle")
		if (characters[2].current_animation == characters[2].idle_animation):
			characters[2].can_idle = true
		characters[2].play_animation("idle", playstate_host.conductor.seconds_per_beat * 2)
	if measure_relative == 0:
		if (characters[1].current_animation == characters[1].idle_animation):
			characters[1].can_idle = true
		characters[1].play_animation("idle", playstate_host.conductor.seconds_per_beat * 4)

func _on_new_event(time, event_name, event_parameters):
	match event_name:
		"camera_position":
			if int(event_parameters[0]) == 0:
				%Metronome.get_node("AnimationPlayer").play("look_right")
			else:
				%Metronome.get_node("AnimationPlayer").play("look_left")
