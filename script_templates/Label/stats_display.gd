extends Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Signals.play_stats_changed.connect(on_stats_change)
	
	text = "Botplay" if SettingsManager.data.botplay else "Score: " + str(0) + " • " + "Misses: " + str(0)


func on_stats_change(stats: NoahStats) -> void:
	if SettingsManager.data.botplay:
		text = 'Botplay'
		return
	
	text = "Score: " + Global.format_number(stats.score) + " • " + "Misses: " + str(stats.misses)
