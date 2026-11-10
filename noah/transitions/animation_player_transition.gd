extends Transition

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func begin_transition() -> void:
	animation_player.play(&"transition")
	
	animation_player.animation_finished.connect(func(anim): finished_transition())

func transition_awaiting() -> void:
	animation_player.pause()
	super() 

func resume_transition() -> void:
	animation_player.play()
