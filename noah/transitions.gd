extends Node2D

signal waiting

@onready var anim_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	anim_player.play(&"RESET")

func transition(transition_name: StringName):
	anim_player.play(&"RESET")
	anim_player.seek(0) # reset all other transitions
	anim_player.play(transition_name)
	anim_player.seek(0)

func pause():
	if Global.transitioning:
		anim_player.pause()
		emit_signal(&"waiting")

func resume():
	if !anim_player.is_playing():
		anim_player.play()


func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	if _anim_name != &"RESET":
		anim_player.play(&"RESET")
