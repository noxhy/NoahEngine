extends TextureProgressBar
class_name BasicHealthBar

@onready var performance_text: Label = $Performance

var target_health: float = 50
var target_score: int = 0
var target_misses: int = 0

func _ready() -> void:
	Signals.play_health_changed.connect(health_changed)
	Signals.play_stats_changed.connect(stats_changed)
	update_performance_text()
	
	if SettingsManager.data.downscroll:
		position.y *= -1

func health_changed(v: float, delta: float) -> void:
	target_health = v

func stats_changed(stats: NoahStats) -> void:
	target_score = int(stats.score)
	target_misses = stats.misses
	update_performance_text()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	value = Global.frame_independent_lerp(value, target_health, 25, delta)

func update_performance_text() -> void:
	var perf_str: String = 'Botplay'
	
	if not SettingsManager.data.botplay:
		perf_str = "Score: " + Global.format_number(target_score) \
		+ " • " + "Misses: " + str(target_misses)
	
	if performance_text:
		performance_text.text = perf_str
