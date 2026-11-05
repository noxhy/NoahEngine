extends CanvasLayer

signal waiting

var current_transition: Transition = null

func transition(trans_name: StringName) -> void:
	if current_transition:
		current_transition.queue_free()
	
	current_transition = load(Constants.TRANSITIONS.get(trans_name)).instantiate()
	
	current_transition.reached_middle.connect(pause)
	current_transition.finished.connect(transition_finished)
	
	add_child(current_transition)


func pause() -> void:
	if Global.transitioning:
		waiting.emit()


func resume() -> void:
	if !current_transition:
		return
	
	current_transition.resume_transition()


func transition_finished() -> void:
	current_transition.queue_free()
