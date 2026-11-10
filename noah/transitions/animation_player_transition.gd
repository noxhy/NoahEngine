extends Transition

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func begin_transition() -> void:
	animation_player.play()
	
	animation_player.animation_finished.connect(_on_animation_player_animation_finished)

func transition_awaiting() -> void:
	animation_player.pause()
	super() 

func resume_transition() -> void:
	animation_player.play()


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	finished_transition()
