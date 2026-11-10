@icon("uid://ij1ectsa31bd")
extends Node
class_name Conductor

signal new_beat(beat: int, measure_relative: int)
signal new_step(step: int, measure_relative: int)
signal new_tempo(_tempo: float)
signal new_numerator(_numerator: int)
signal new_denominator(_denominator: int)

## The time where the conductor will [b]start[/b].
var offset: float = 0
## Node Path to an [AudioStreamPlayer] that the Conductor will conduct.
## [br]If there is no [AudioStreamPlayer], or if it isn't playing, you can set [param time] manually.
@export var stream_player: AudioStreamPlayer
## Dictionary of time changes. Time changes are stored as a [Vector3] with the following format:
## [br]'x': Tempo, 'y': Numerator, 'z': Denominator
## [br][b]Note:[/b] The dictionary must be sorted by time to work properly.
@export var time_changes: Dictionary[float, Vector3] = {0.0: Vector3(60, 4, 4)}

## Getter for the current beats per minute.
var tempo: float = 60.0:
	set(v):
		var emit: bool = false
		if tempo != v:
			emit = true
		
		tempo = v
		if emit:
			emit_signal(&"new_tempo", v)

## Current numerator for the current time signature.
var numerator: int = 4:
	set(v):
		var emit: bool = false
		if numerator != v:
			emit = true
		
		numerator = v
		if emit:
			emit_signal(&"new_numerator", v)

## Current denominator for the current time signature.
var denominator: int = 4:
	set(v):
		var emit: bool = false
		if denominator != v:
			emit = true
		denominator = v
		
		if emit:
			emit_signal(&"new_denominator", v)

## How many seconds each beat is, scales based off numerator.
var seconds_per_beat: float:
	get():
		return (60.0 / tempo) * (4.0 / denominator)

var seconds_per_step: float:
	get():
		return seconds_per_beat / denominator

# Stored Statistics:
# These variables only exist for the purpose of grabbing info
var current_beat: int = -1:
	set(v):
		measure_relative_beat = v % numerator
		if current_beat != v:
			emit_signal(&"new_beat", v, measure_relative_beat)
		
		current_beat = v

var current_step: int = -1:
	set(v):
		measure_relative_step = v % (numerator * denominator)
		if current_step != v:
			emit_signal(&"new_step", v, measure_relative_step)
		
		current_step = v

var measure_relative_beat: int = 0
var measure_relative_step: int = 0
var time: float = 0
var latency: float = AudioServer.get_output_latency()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if stream_player and stream_player.playing:
		time = stream_player.get_playback_position()
		time -= latency
		# time += AudioServer.get_time_since_last_mix()
	
	var time_change: Vector3 = get_time_change_at(time)
	tempo = time_change.x
	numerator = int(time_change.y)
	denominator = int(time_change.z)
	current_beat = get_beat_at(time)
	current_step = get_step_at(time)

## Gets the beat counting previous time changes at the given time.
func get_beat_at(_time: float) -> int:
	_time -= offset
	var beat: int = 0
	var time_calc: Callable = func(t, bpm, d) -> int:
		var spb: float = (60.0 / bpm) * (4.0 / d)
		return floor(t / spb)
	
	if time_changes.size() > 1:
		for i in range(0, time_changes.size()):
			var cur_time: float = time_changes.keys()[i]
			var rel_time: float
			var next_time: float = _time if i == time_changes.size() - 1 else time_changes.keys()[i + 1]
			
			if next_time >= _time:
				rel_time = _time - cur_time
			else:
				rel_time = next_time - cur_time
			
			beat += time_calc.call(rel_time, time_changes[cur_time].x, time_changes[cur_time].z)
			
			if next_time >= _time:
				break
		
		return beat
	else:
		var time_change: Vector3 = time_changes[time_changes.keys().front()]
		return time_calc.call(_time, time_change.x, time_change.z)

## Gets the step counting previous time changes at the given time.
func get_step_at(_time: float) -> int:
	_time -= offset
	var beat: int = 0
	var time_calc: Callable = func(t, bpm, d) -> int:
		var spb: float = (60.0 / bpm) * (4.0 / d)
		return floor(t / (spb / d))
	
	if time_changes.size() > 1:
		for i in range(0, time_changes.size()):
			var cur_time: float = time_changes.keys()[i]
			var next_time: float = _time if i == time_changes.size() - 1 else time_changes.keys()[i + 1]
			
			var rel_time: float
			if next_time >= _time:
				rel_time = _time - cur_time
			else:
				rel_time = next_time - cur_time
			
			beat += time_calc.call(rel_time, time_changes[cur_time].x, time_changes[cur_time].z)
			
			if next_time >= _time:
				break
		
		return beat
	else:
		var time_change: Vector3 = time_changes[time_changes.keys().front()]
		return time_calc.call(_time, time_change.x, time_change.z)

## Returns the time change at a given time.
func get_time_change_at(_time: float) -> Vector3:
	_time = max(0, _time - offset)
	var output: Vector3
	for point in time_changes:
		if _time >= point:
			output = time_changes[point]
		else:
			break
	
	return output

## Gets the time of a time change.
func get_change_time_at(_time: float) -> float:
	_time = max(0, _time - offset)
	var output: float = -1
	for point in time_changes:
		if time >= point:
			output = point
		else:
			continue
	
	return output

## Returns the time after moving forward X beats. `_time` will be floored to the current beat.
func step_in_beats(_time: float, beats: int) -> float:
	_time -= offset
	var direction: int = 1 if beats > 0 else -1
	var bpm: float = get_time_change_at(_time).x
	var spb: float = 60.0 / bpm
	var output: float = floori((_time - get_change_time_at(_time)) / spb) * spb
	beats = abs(beats)
	while beats > 0:
		bpm = get_time_change_at(output).x
		spb = 60.0 / bpm
		output += spb * direction
		beats -= 1
	
	return output + offset

## Returns the time after moving forward X steps. `_time` will be floored to the current step.
func step_in_steps(_time: float, steps: int) -> float:
	_time -= offset
	var direction: int = 1 if steps > 0 else -1
	var bpm: float = get_time_change_at(_time).x
	var sps: float = 60.0 / (bpm / get_time_change_at(_time).z)
	var output: float = floori((_time - get_change_time_at(_time)) / sps) * sps
	steps = abs(steps)
	while steps > 0:
		bpm = get_time_change_at(output).x
		sps = 60.0 / (bpm / get_time_change_at(output).z)
		output += sps * direction
		steps -= 1
	
	return output + offset
