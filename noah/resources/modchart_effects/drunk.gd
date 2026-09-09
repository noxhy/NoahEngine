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

func _init() -> void:
	name = &'drunk'

func update_general(node: Node2D) -> void:
	var time: float = GameManager.song_position / 1000
	
	if !is_zero_approx(x_percentage):
		var visual_time: float = 0
		if node is BasicNote:
			visual_time = node.time - GameManager.visual_song_position
		
		var angle: float = time * (1 + x_speed) + node.lane * ((x_offset * 0.2) + 0.2) + visual_time * ((x_period * 10) + 10) / node.get_window().size.y
		node.position.x += x_percentage * (cos(angle) * STRUM_WIDTH * 0.5)
	
	if !is_zero_approx(y_percentage):
		node.position.y += y_percentage * (cos((time * ((y_speed * 1.2) + 1.2) + node.lane * ((y_offset * 1.8) + 1.8))) * STRUM_WIDTH * 0.4)
	
	if !is_zero_approx(z_percentage):
		node.z_index += floori(z_percentage * (cos(time * ((z_speed * 1.2) + 1.2) + node.lane * ((z_offset * 1.8)) + 3.2) * 0.15))
