extends Node2D

signal waiting

var current_transition: Transition

func transition(trans_name: StringName):
	if current_transition:
		current_transition.queue_free()
	
	var instance = load(Constants.TRANSITIONS.get(trans_name))
	$Transitions.add_child(instance)

func pause():
	if Global.transitioning:
		emit_signal(&"waiting")


func resume():
	if !current_transition.is_playing():
		current_transition.play()


func transition_finished(trans_name: StringName) -> void:
	current_transition.queue_free()
