extends Node

@onready var music: AudioStreamPlayer = $MusicPlayer
@onready var scroll: AudioStreamPlayer = $UI/ScrollPlayer
@onready var cancel: AudioStreamPlayer = $UI/CancelPlayer
@onready var accept: AudioStreamPlayer = $UI/AcceptPlayer
@onready var miss: AudioStreamPlayer = $Game/MissPlayer
@onready var hit: AudioStreamPlayer = $Game/HitPlayer
@onready var anti_spam: AudioStreamPlayer = $Game/AntiSpamPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	AudioServer.set_bus_volume_linear(0, SettingsManager.get_setting("master_volume"))
	AudioServer.set_bus_volume_linear(1, SettingsManager.get_setting("music_volume"))
	AudioServer.set_bus_volume_linear(2, SettingsManager.get_setting("sfx_volume"))

## Plays a sfx once and frees it after its use
func play_sound_once(stream: Variant, volume_linear: float = 1) -> void:
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
func _get_stream(stream: Variant) -> AudioStream:
	if stream is AudioStream:
		return stream
	elif stream is String:
		assert(ResourceLoader.exists(stream), '%s could not be found and played.' % stream)
		
		var loaded_sound = load(stream)
		assert(loaded_sound is AudioStream, '%s was not a audio stream' % stream)
		
		return loaded_sound
	else:
		assert(false, '%s provided is not a valid stream' % stream)
		
	return null
