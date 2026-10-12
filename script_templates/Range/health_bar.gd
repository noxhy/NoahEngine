extends Range

## Whether the bar should be smooth
var smooth: bool = true

## Used when smooth is true
var smooth_speed: float = 25.0

var intended_value: float = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Signals.play_health_changed.connect(on_health_change)
	intended_value = value

func on_health_change(v: float, d: float):
	if smooth:
		intended_value = v
	else:
		value = v

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if smooth:
		value = lerpf(value, intended_value, 1.0 - exp(-delta * smooth_speed))
