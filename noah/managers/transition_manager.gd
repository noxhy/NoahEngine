extends CanvasLayer

## Signal called when waiting for the scene to load before transitioning out
signal waiting

## [Transition] singleton.
var current_transition: Transition = null

## Instantiates the transition [AnimationPlayer] if failing, will instantly emit [signal waiting].
func transition(trans_name: StringName) -> void:
	if current_transition:
		current_transition.queue_free()
	
	if not Constants.TRANSITIONS.has(trans_name):
		printerr('TransitionManager: transition "%s" does not exist' % trans_name)
		call_deferred(&"emit_signal", &"waiting")
		return
	
	current_transition = load(Constants.TRANSITIONS.get(trans_name)).instantiate()
	
	current_transition.reached_middle.connect(pause)
	current_transition.finished.connect(transition_finished)
	
	add_child(current_transition)

## Emits [signal waiting].
func pause() -> void:
	waiting.emit()

## Resumes [member current_transition].
func resume() -> void:
	if !current_transition:
		return
	
	current_transition.resume_transition()

## Frees [member current_transition].
func transition_finished() -> void:
	current_transition.queue_free()
