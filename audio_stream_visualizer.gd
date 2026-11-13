@icon("res://addons/at-icons/control/signal_wave.svg")
extends Control
class_name AudioStreamVisualizer

## Main [AudioStream] source.
@export var audio_stream: AudioStream
## The maximum amount of points that will be shown.
@export var resolution: int = 1000
## Depth of the waveform at each frame at caching
@export var frames_per_point: int = 512
## Maximum frame count at caching
@export var chunk_size: int = 4096

## Color of the waveform
@export var waveform_color := Color.WHITE
## Color of the center line
@export var center_color := Color(1, 1, 1, 0.2)

var waveform_cache: PackedVector2Array = []
var visible_waveform: PackedVector2Array = []

var sample_rate: int
var start_time: float = 0.0
var duration: float = 5.0

var generation_id: int = 0


func _ready() -> void:
	if audio_stream != null and waveform_cache.is_empty():
		await generate_cache()


func generate_cache() -> void:
	generation_id += 1
	var current_id: int = generation_id
	
	waveform_cache.clear()
	visible_waveform.clear()
	
	if audio_stream == null:
		return
	
	sample_rate = int(AudioServer.get_mix_rate())
	
	var total_frames := int(audio_stream.get_length() * sample_rate)
	
	if total_frames <= 0:
		return
	
	var playback: AudioStreamPlayback = audio_stream.instantiate_playback()
	
	if playback == null:
		return
	
	playback.start(0.0)
	
	var bin_count: int = int(ceil(
		float(total_frames) / frames_per_point
	))
	
	var minimums: PackedFloat32Array = PackedFloat32Array()
	var maximums: PackedFloat32Array = PackedFloat32Array()
	
	minimums.resize(bin_count)
	maximums.resize(bin_count)
	
	minimums.fill(1.0)
	maximums.fill(-1.0)
	
	var processed_frames := 0
	
	while processed_frames < total_frames:
		if current_id != generation_id:
			playback.stop()
			return
		
		var amount: int = mini(
			chunk_size,
			total_frames - processed_frames
		)
		
		var samples: PackedVector2Array = playback.mix_audio(1.0, amount)
		
		if samples.is_empty():
			break
		
		for i in range(samples.size()):
			var frame_index := processed_frames + i
			var bin: int = int(frame_index / frames_per_point)
		
			var low := minf(samples[i].x, samples[i].y)
			var high := maxf(samples[i].x, samples[i].y)
		
			minimums[bin] = minf(minimums[bin], low)
			maximums[bin] = maxf(maximums[bin], high)
		
		processed_frames += samples.size()
		
		await get_tree().process_frame
	
	playback.stop()
	if current_id != generation_id:
		return
	
	var actual_bins: int = int(ceil(
		float(processed_frames) / frames_per_point
	))
	waveform_cache.resize(actual_bins)
	for i in range(actual_bins):
		waveform_cache[i] = Vector2(
			minimums[i],
			maximums[i]
		)
	
	set_section(start_time, duration)


func set_section(start: float, length: float) -> void:
	start_time = maxf(start, 0.0)
	duration = maxf(length, 0.0)
	
	visible_waveform.clear()
	
	if waveform_cache.is_empty() or duration <= 0.0:
		queue_redraw()
		return
	
	var bin_duration: float = float(frames_per_point) / sample_rate
	
	var first_bin: int = clampi(
		int(floor(start_time / bin_duration)),
		0,
		waveform_cache.size()
	)
	
	var last_bin: int = clampi(
		int(ceil((start_time + duration) / bin_duration)),
		first_bin,
		waveform_cache.size()
	)
	
	var section_bins: int = last_bin - first_bin
	
	if section_bins <= 0:
		queue_redraw()
		return
	
	var point_count: int = mini(resolution, section_bins)
	
	visible_waveform.resize(point_count)
	
	for i in range(point_count):
		var from_bin: int = first_bin + int(
			float(i) / point_count * section_bins
		)
		
		var to_bin: int = first_bin + int(
			float(i + 1) / point_count * section_bins
		)
		
		to_bin = maxi(to_bin, from_bin + 1)
		
		var minimum: float = 1.0
		var maximum: float = -1.0
		
		for j in range(from_bin, mini(to_bin, last_bin)):
			minimum = minf(minimum, waveform_cache[j].x)
			maximum = maxf(maximum, waveform_cache[j].y)
	
		visible_waveform[i] = Vector2(minimum, maximum)
	
	queue_redraw()


func _draw() -> void:
	var center: float= size.y * 0.5
	var half_height: float= size.y * 0.5
	
	draw_line(
		Vector2(0, center),
		Vector2(size.x, center),
		center_color
	)
	
	if visible_waveform.is_empty():
		return
	
	var bar_width: float = size.x / visible_waveform.size()
	
	var upper: PackedVector2Array = PackedVector2Array()
	var lower: PackedVector2Array = PackedVector2Array()
	
	upper.resize(visible_waveform.size())
	lower.resize(visible_waveform.size())
	
	# Line display for both the left and right channels
	#for i in range(visible_waveform.size()):
		#var x: float= (i + 0.5) * bar_width
		#
		#upper[i] = Vector2(
			#x,
			#center - visible_waveform[i].y * half_height
		#)
		#
		#lower[i] = Vector2(
			#x,
			#center - visible_waveform[i].x * half_height
		#)
	#
	#draw_polyline(upper, waveform_color, 1.5, true)
	#draw_polyline(lower, waveform_color, 1.5, true)
	
	var points: PackedVector2Array = PackedVector2Array()
	points.resize(visible_waveform.size() * 2)
	for i in range(0, visible_waveform.size(), 2):
		var x: float= (i + 0.5) * bar_width
		points[i] = Vector2(
			x,
			center - visible_waveform[i].y * half_height
		)
		
		points[i + 1] = Vector2(
			x,
			center - visible_waveform[i].x * half_height
		)
	
	draw_multiline(points, waveform_color, 1.5, true)
