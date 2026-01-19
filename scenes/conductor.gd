@icon("res://assets/sprites/nodes/conductor.png")

extends Node
class_name Conductor

signal new_beat(beat: int, measure_relative: int)
signal new_step(step: int, measure_relative: int)
signal new_tempo(_tempo: float)

## The time where the conductor will [b]start[/b].
@export_range(-1000, 1000, 1) var offset = 0
## Node Path to an [AudioStreamPlayer] that the Conductor will conduct.
## [br]If there is no [AudioStreamPlayer], or if it isn't playing, you can set [param time] manually.
@export var stream_player: AudioStreamPlayer
## Beats per minute.
@export var tempo: float:
	set(v):
		tempo = v
		seconds_per_beat = 60.0 / tempo
		seconds_per_step = seconds_per_beat / (steps_per_measure / beats_per_measure)
		emit_signal(&"new_tempo", v)
	get():
		return tempo

## Time Singatures
## Key:
## 4/16 = (♬♬ ♬♬ ♬♬ ♬♬) - Default
## 4/12 = (♪♪♪ ♪♪♪ ♪♪♪ ♪♪♪) - Triplets
var beats_per_measure: int = 4  	# The amount of beats in a measure (Default: 4)
var steps_per_measure: int = 4 * beats_per_measure  	# The amount of notes in a measure (Default: 16)

var seconds_per_beat: float = 1.0
var seconds_per_step: float = 0.25

# Stored Statistics:
# These variables only exist for the purpose of grabbing info

var current_beat: int:
	set(v):
		current_beat = v
		measure_relative_beat = current_beat % beats_per_measure
		emit_signal(&"new_beat", v, measure_relative_beat)
	get():
		return current_beat

var current_step: int:
	set(v):
		current_step = v
		measure_relative_step = current_step % steps_per_measure
		emit_signal(&"new_step", v, measure_relative_step)
	get():
		return current_step

var measure_relative_beat: int = 0
var measure_relative_step: int = 0
var time: float = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if stream_player and stream_player.playing:
		time = stream_player.get_playback_position()
		time -= AudioServer.get_output_latency()
	
	current_beat = get_beat_at(time)
	current_step = get_step_at(time)


func get_beat_at(_time: float) -> int:
	return int((_time - self.offset) / seconds_per_beat)


func get_step_at(_time: float) -> int:
	return int((_time - self.offset) / (seconds_per_beat / (steps_per_measure / beats_per_measure)))


func get_measure_at(_time: float) -> int:
	return int((_time - self.offset) / (seconds_per_beat * beats_per_measure))
