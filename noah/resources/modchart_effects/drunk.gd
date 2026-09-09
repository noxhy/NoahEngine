extends ModchartEffect
class_name DrunkModchartEffect

var x_percentage: float
var y_percentage: float
var z_percentage: float

var x_speed: float
var x_offset: float
var x_period: float

var y_speed: float
var y_offset: float

var z_speed: float
var z_offset: float 

var tail_precision: int = 6

func _init() -> void:
	name = &'drunk'

func update_strum(strum: Strum) -> void:
	var time: float = GameManager.song_position
	
	if !is_zero_approx(x_percentage):
		var angle: float = time * (1 + x_speed) + strum.lane * ((x_offset * 0.2) + 0.2)
		strum.position.x += x_percentage * (cos(angle) * STRUM_WIDTH * 0.5)
	
	if !is_zero_approx(y_percentage):
		strum.position.y += y_percentage * (cos((time * ((y_speed * 1.2) + 1.2) + strum.lane * ((y_offset * 1.8) + 1.8))) * STRUM_WIDTH * 0.4)
	
	if !is_zero_approx(z_percentage):
		strum.scale += Vector2.ONE * z_percentage * (cos(time * ((z_speed * 1.2) + 1.2) + strum.lane * ((z_offset * 1.8)) + 3.2) * 0.15)
		#strum.z_index += floori(z_percentage * (cos(time * ((z_speed * 1.2) + 1.2) + strum.lane * ((z_offset * 1.8)) + 3.2) * 0.15))


func update_note(note: ModChartNote) -> void:
	var time: float = GameManager.song_position
	
	var get_x_offset: Callable = func(visual_diff: float) -> float:
		var angle: float = time * (1 + x_speed) + note.lane * ((x_offset * 0.2) + 0.2) + visual_diff * ((x_period * 10) + 10) / note.get_window().size.y
		return x_percentage * (cos(angle) * STRUM_WIDTH * 0.5)
	var get_y_offset = func(visual_diff: float) -> float:
		return y_percentage * (cos(((time + visual_diff) * ((y_speed * 1.2) + 1.2) + note.lane * ((y_offset * 1.8) + 1.8))) * STRUM_WIDTH * 0.4)
	
	if !is_zero_approx(x_percentage):
		note.position.x += get_x_offset.call(max(0, note.visual_time_difference))
	
	if !is_zero_approx(y_percentage):
		note.position.y += get_y_offset.call(0)
	
	note.position += (note.get_parent().base_position - note.get_parent().position)
	if note.tail and note.length > 0:
		var line_length: float = note.length * note.scroll_speed * note.grid_size.y / note.tail.scale.y
		var step: float = line_length / tail_precision
		note.tail.clear_points()
		var visual_diff: float = 0
		if !note.holding:
			visual_diff = note.visual_time_difference
		
		for i in range(tail_precision + 1):
			var pos: Vector2 = Vector2(get_x_offset.call(max(0, visual_diff) + ((GameManager.conductor.seconds_per_beat * note.length / tail_precision) * i)),
			step * i)
			
			pos.x -= note.position.x
			note.tail.add_point(pos)
