extends Node2D

signal waiting

func _ready():
	$AnimationPlayer.play(&"RESET")

func transition(transition_name: StringName):
	$AnimationPlayer.play(transition_name)
	$AnimationPlayer.seek(0)

func pause():
	
	if Global.transitioning:
		$AnimationPlayer.pause()
		emit_signal("waiting")

func resume():
	
	if !$AnimationPlayer.is_playing():
		$AnimationPlayer.play()


func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	if _anim_name != &"RESET":
		$AnimationPlayer.play(&"RESET")
