@abstract
extends Node2D
class_name Transition
## Base Node for creating a transition between scenes

## Starts the transition. Called by the [code]TransitionManager[/code]
@abstract func begin_transition() -> void

## Transition IN is finished. This is when the state change occurs.
func transition_awaiting() -> void:
	reached_middle.emit()

## The state has changed so NOW we can continue the transition
@abstract func resume_transition() -> void

func finished_transition() -> void:
	finished.emit()

@warning_ignore_start('unused_signal')
signal reached_middle
signal finished
