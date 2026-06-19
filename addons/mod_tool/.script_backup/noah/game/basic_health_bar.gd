extends TextureProgressBar
class_name BasicHealthBar

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.value = Global.frame_independent_lerp(self.value, GameManager.health, 25, delta)
	update_performance_text()

func update_performance_text():
	var perf_str: String = 'Botplay'
	
	if not SettingsManager.get_value(SettingsManager.SEC_GAMEPLAY, "botplay"):
		perf_str = "Score: " + Global.format_number(GameManager.score) \
		+ " • " + "Misses: " + str(GameManager.tallies.get("miss", 0))
	
	$Performance.text = perf_str
