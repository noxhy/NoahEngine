extends Node

@onready var music: AudioStreamPlayer = $MusicPlayer ## global music player
@onready var scroll: AudioStreamPlayer = $UI/ScrollPlayer ## global menu scroll sfx
@onready var cancel: AudioStreamPlayer = $UI/CancelPlayer ## global menu cancel sfx
@onready var accept: AudioStreamPlayer = $UI/AcceptPlayer ## global menu accept sfx

@onready var miss: AudioStreamPlayer = $Game/MissPlayer ## note miss sfx
@onready var hit: AudioStreamPlayer = $Game/HitPlayer ## note hit sfx
@onready var anti_spam: AudioStreamPlayer = $Game/AntiSpamPlayer ## anti spam sfx

func vanilla_2652612725__ready() -> void:
	AudioServer.set_bus_mute(0, SettingsManager.get_value(SettingsManager.SEC_AUDIO, 'is_muted', false))
	AudioServer.set_bus_volume_linear(0, SettingsManager.get_value('audio', "master_volume", 1.0))
	AudioServer.set_bus_volume_linear(1, SettingsManager.get_value('audio', "music_volume", 1.0))
	AudioServer.set_bus_volume_linear(2, SettingsManager.get_value('audio', "sfx_volume", 1.0))

func vanilla_2652612725__process(delta: float) -> void:
	AudioServer.set_bus_volume_linear(0, SettingsManager.get_value('audio', "master_volume", 1.0))
	AudioServer.set_bus_volume_linear(1, SettingsManager.get_value('audio', "music_volume", 1.0))
	AudioServer.set_bus_volume_linear(2, SettingsManager.get_value('audio', "sfx_volume", 1.0))

func vanilla_2652612725__input(event: InputEvent) -> void:
	if not event.is_pressed():
		return
	if event.is_echo():
		return
	if event is not InputEventKey:
		return
	#if Global.lock_keybinds:
		#return
	var ev:InputEventKey = event
	
	if event.shift_pressed or event.ctrl_pressed:
		return
	
	if ev.pressed:
		if ev.is_action(&'mute'):
			SettingsManager.set_value(SettingsManager.SEC_AUDIO, 'is_muted', !SettingsManager.get_value(SettingsManager.SEC_AUDIO, 'is_muted', false))
			
			_updated_volume()
		elif ev.is_action(&'volume_up'):
			SettingsManager.set_value(SettingsManager.SEC_AUDIO, 'is_muted', false)
			
			var new_vol = clampf(SettingsManager.get_value(SettingsManager.SEC_AUDIO,'master_volume') + 0.05, 0.0, 1.0)
			SettingsManager.set_value(SettingsManager.SEC_AUDIO, 'master_volume', new_vol)
			
			_updated_volume()
		elif ev.is_action(&'volume_down'):
			SettingsManager.set_value(SettingsManager.SEC_AUDIO, 'is_muted', false)
			
			var new_vol = clampf(SettingsManager.get_value(SettingsManager.SEC_AUDIO,'master_volume') - 0.05, 0.0, 1.0)
			SettingsManager.set_value(SettingsManager.SEC_AUDIO, 'master_volume', new_vol)
			
			_updated_volume()

func vanilla_2652612725__updated_volume():
	AudioServer.set_bus_mute(0, SettingsManager.get_value(SettingsManager.SEC_AUDIO, 'is_muted', false))
	AudioServer.set_bus_volume_linear(0, SettingsManager.get_value('audio', "master_volume", 1.0))
	
	SettingsManager.flush()
	Global.show_volume()


## plays the global audio track from stream or path
func vanilla_2652612725_play_music(stream: Variant, start_time: float = 0) -> void:
	
	stream = _get_stream(stream)
	music.stream = stream
	
	music.play(start_time)

## Plays a sfx once and frees it after its use
func vanilla_2652612725_play_sound_once(stream: Variant, volume_linear: float = 1) -> void:
	var player = AudioStreamPlayer.new()
	add_child(player)
	player.stream = _get_stream(stream)
	player.volume_linear = volume_linear
	player.play()
	player.bus = &'SFX'
	
	await player.finished
	
	remove_child(player)
	player.queue_free()

## asserts a given stream IS a AudioStream
func vanilla_2652612725__get_stream(stream: Variant) -> AudioStream:
	if stream is AudioStream or stream is AudioStreamOggVorbis:
		return stream
	elif stream is String:
		assert(ResourceLoader.exists(stream), '%s could not be found and played.' % stream)
		
		var loaded_sound = load(stream)
		assert((loaded_sound is AudioStream or stream is AudioStreamOggVorbis), '%s was not a audio stream' % stream)
		
		return loaded_sound
	else:
		assert(false, '%s provided is not a valid stream' % stream)
	
	return null


# ModLoader Hooks - The following code has been automatically added by the Godot Mod Loader.


func _ready():
	if _ModLoaderHooks.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_2652612725__ready, [], 3531175337)
	else:
		vanilla_2652612725__ready()


func _process(delta: float):
	if _ModLoaderHooks.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_2652612725__process, [delta], 3691552627)
	else:
		vanilla_2652612725__process(delta)


func _input(event: InputEvent):
	if _ModLoaderHooks.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_2652612725__input, [event], 3520842372)
	else:
		vanilla_2652612725__input(event)


func _updated_volume():
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_2652612725__updated_volume, [], 508491794)
	else:
		return vanilla_2652612725__updated_volume()


func play_music(stream: Variant, start_time: float=0):
	if _ModLoaderHooks.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_2652612725_play_music, [stream, start_time], 3155471403)
	else:
		vanilla_2652612725_play_music(stream, start_time)


func play_sound_once(stream: Variant, volume_linear: float=1):
	if _ModLoaderHooks.any_mod_hooked:
		await _ModLoaderHooks.call_hooks_async(vanilla_2652612725_play_sound_once, [stream, volume_linear], 3291781367)
	else:
		await vanilla_2652612725_play_sound_once(stream, volume_linear)


func _get_stream(stream: Variant) -> AudioStream:
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_2652612725__get_stream, [stream], 2447518783)
	else:
		return vanilla_2652612725__get_stream(stream)
