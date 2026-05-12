extends Node2D
class_name DeathScreen

static var player_position: Variant = Vector2.ONE
static var player_scale: Vector2 = Vector2.ONE
static var camera_zoom: Variant = Vector2.ONE

var can_press = true

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.set_window_title("Dead")
	$AnimationPlayer.play(&"intro")
	 
	if %Player is Node2D:
		player_position = Vector2(player_position.x,player_position.y)
	
	%Player.position = player_position
	$CameraController.set_position(%Player.global_position)
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(%Player, "scale:x", player_scale.x, 2)
	tween.tween_property(%Player, "scale:y", player_scale.y, 2)
	
	tween.tween_property($CameraController, "zoom", camera_zoom, 2)
	tween.tween_property($CameraController, "target_zoom", camera_zoom, 2)
	
	$Conductor.tempo = $Audio/Music.stream.get_bpm()

func _on_conductor_new_beat(current_beat, measure_relative):
	if can_press:
		%Player.play_animation(&"idle")

func _input(event):
	if can_press:
		if event.is_action_pressed(&"ui_accept"):
			can_press = false
			%Player.play_animation(&"accept")
			$AnimationPlayer.play(&"end")
		
		if event.is_action_pressed(&"ui_cancel"):
			can_press = false
			
			GameManager.reset_stats()
			
			if GameManager.freeplay:
				match GameManager.play_mode:
					GameManager.PLAY_MODE.CHARTING:
						Global.change_scene_to("uid://c3lux2ajoe1g6")
					
					_:
						Global.change_scene_to("uid://gbra80y44814")
			else:
				Global.change_scene_to("uid://lh8hi5dk1sja")

func exit_scene():
	Transitions.transition(&"fade")
	Global.change_scene_to(GameManager.song_scene)

func _on_animation_player_animation_finished(anim_name):
	if anim_name == &"intro":
		$Audio/Music.play()
