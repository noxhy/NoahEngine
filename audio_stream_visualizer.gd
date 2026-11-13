@icon("res://addons/at-icons/control/signal_wave.svg")
extends Control
class_name AudioStreamVisualizer

## The [AudioStream] that the visualizer will use.
@export var audio_stream: AudioStream
## The start time of the visualizer
@export var start_time: float = 0.0:
	set(v):
		start_time = v
		generate_waveform()
## Length of the section the visualizer will use
@export var duration: float = 5.0:
	set(v):
		duration = v
		generate_waveform()

@export_range(100, 4000) var resolution: int = 1200

@export var waveform_color: Color = Color.WHITE
@export var center_color: Color = Color(1, 1, 1, 0.2)

var waveform: PackedVector2Array = []
var display_vertices: PackedVector2Array


func _ready() -> void:
	generate_waveform()
	connect(&"resized", cache_lines)

func generate_waveform() -> void:
	waveform.clear()
	
	if audio_stream == null or duration <= 0.0:
		queue_redraw()
		return
	
	var playback := audio_stream.instantiate_playback()
	
	if playback == null:
		return
	
	playback.start(start_time)
	
	var sample_rate: float = AudioServer.get_mix_rate()
	var frame_count: int = int(duration * sample_rate)
	
	# Mix the requested section only once.
	var samples: PackedVector2Array = playback.mix_audio(1.0, frame_count)
	
	playback.stop()
	
	if samples.is_empty():
		queue_redraw()
		return
	
	var bar_count: int = mini(resolution, samples.size())
	
	var minimums: PackedFloat32Array = PackedFloat32Array()
	var maximums: PackedFloat32Array = PackedFloat32Array()
	
	minimums.resize(bar_count)
	maximums.resize(bar_count)
	
	for i in range(bar_count):
		minimums[i] = 1.0
		maximums[i] = -1.0
	
	for i in range(samples.size()):
		var bar := mini(
			int(float(i) / samples.size() * bar_count),
			bar_count - 1
		)
		
		var left: float = samples[i].x
		var right: float = samples[i].y
		
		var low: float = minf(left, right)
		var high: float = maxf(left, right)
		
		minimums[bar] = minf(minimums[bar], low)
		maximums[bar] = maxf(maximums[bar], high)
	
	waveform.resize(bar_count)
	
	for i in range(bar_count):
		waveform[i] = Vector2(minimums[i], maximums[i])
	
	cache_lines()
	queue_redraw()

func cache_lines() -> void:
	var center := size.y * 0.5
	var half_height := size.y * 0.5
	var bar_width := size.x / waveform.size()
	display_vertices = []
	
	for i in range(waveform.size()):
		var x := (i + 0.5) * bar_width
		
		var top: float = center - waveform[i].y * half_height
		var bottom: float = center - waveform[i].x * half_height
		
		display_vertices.append(Vector2(x, top))
		display_vertices.append(Vector2(x, bottom))

func _draw() -> void:
	var center := size.y * 0.5
	draw_line(
		Vector2(0, center),
		Vector2(size.x, center),
		center_color
	)
	
	if waveform.is_empty():
		return
	
	var bar_width := size.x / waveform.size()
	draw_multiline(display_vertices, waveform_color, maxf(1.0, bar_width * 0.7))
