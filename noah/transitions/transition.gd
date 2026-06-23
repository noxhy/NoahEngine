class_name Transition extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

signal paused
signal finished

func _ready() -> void:
	if animation_player:
		animation_player.connect("animation_finished", self.finish)


func play() -> void:
	animation_player.play()


func is_playing() -> bool:
	return animation_player.is_playing()


func pause() -> void:
	paused.emit()


func finish() -> void:
	finished.emit()
