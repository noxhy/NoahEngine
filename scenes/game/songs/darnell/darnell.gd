extends "res://scenes/game/songs/basic_song.gd"

func _on_new_event(time, event_name, event_parameters):
	match event_name:
		"camera_position":
			if int(event_parameters[0]) == 0:
				%Metronome.get_node("AnimationPlayer").play("look_right")
			else:
				%Metronome.get_node("AnimationPlayer").play("look_left")
