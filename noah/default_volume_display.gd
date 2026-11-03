extends VolumeDisplay

## The display node for volume.

## Timer that is commonly connected to [method hide_volume] on [signal Timer.timeout].
@onready var hide_timer: Timer = $"Hide Timer"

func _ready() -> void:
	position.y -= 32
	hide_timer.wait_time = ON_SCREEN_TIME

## Called when the volume updates, plays the entering animation of the node.
func show_volume(new_master_volume: float) -> void:
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	position.x = get_window().content_scale_size.x / 2
	tween.tween_property(self, "position:y", 0, 0.5)
	SoundManager.scroll.play()
	
	if AudioServer.is_bus_mute(0):
		$Label.text = "Muted"
	else:
		$Label.text = "Master Volume: " + str(roundi(new_master_volume * 100)) + "%"
	
	hide_timer.start()

## Plays the exiting animation of the node.
func hide_volume() -> void:
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position:y", -32, 0.5)
