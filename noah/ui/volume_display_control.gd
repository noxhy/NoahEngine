@abstract
extends Control
class_name VolumeDisplay

# The default time the tray should be on screen
const ON_SCREEN_TIME: float = 1.5

@abstract func show_volume(new_volume: float) -> void
