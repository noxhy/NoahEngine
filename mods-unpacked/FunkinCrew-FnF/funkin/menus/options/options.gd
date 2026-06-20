extends OptionsMenu

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	OPTIONS_SUBMENU_PRELOAD = load("uid://bp581x6mu5f1w")
	MENU_OPTION_PRELOAD = load("uid://55odtbd2v2ql")
	Global.set_window_title("Options Menu")
	
	for i in pages.size():
		var page = pages.keys()[i]
		var menu_option_instance = MENU_OPTION_PRELOAD.instantiate()
		
		menu_option_instance.text = page.to_upper()
		menu_option_instance.icon = null
		
		$UI.add_child(menu_option_instance)
		menu_option_instance.label.forced_anim_suffix = &" bold"
		menu_option_instance.add_to_group(&"pages")
	
	update(selected)
	
	if not SoundManager.music.playing:
		SoundManager.music.play()
	
	$Conductor.stream_player = SoundManager.music
	
	await $Conductor.ready
	
	$Conductor.tempo = SoundManager.music.stream.get_bpm()
	print(SoundManager.music.stream.get_bpm())
