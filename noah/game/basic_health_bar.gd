extends TextureProgressBar
class_name BasicHealthBar

# Called every frame. 'delta' is the elapsed time since the previous frame.
func vanilla_1709061161__process(delta: float) -> void:
	self.value = Global.frame_independent_lerp(self.value, GameManager.health, 25, delta)
	update_performance_text()

func vanilla_1709061161_update_performance_text():
	var perf_str: String = 'Botplay'
	
	if not SettingsManager.get_value(SettingsManager.SEC_GAMEPLAY, "botplay"):
		perf_str = "Score: " + Global.format_number(GameManager.score) \
		+ " • " + "Misses: " + str(GameManager.tallies.get("miss", 0))
	
	$Performance.text = perf_str


# ModLoader Hooks - The following code has been automatically added by the Godot Mod Loader.


func _process(delta: float):
	if _ModLoaderHooks.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_1709061161__process, [delta], 3198525223)
	else:
		vanilla_1709061161__process(delta)


func update_performance_text():
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_1709061161_update_performance_text, [], 620535297)
	else:
		return vanilla_1709061161_update_performance_text()
