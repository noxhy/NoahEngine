@icon("res://assets/sprites/nodes/stage.png")
extends Node2D
class_name Stage

func _on_conductor_new_beat(current_beat, measure_relative):
	if current_beat % 2 == 0:
		for node in get_tree().get_nodes_in_group(&"slow_bop"):
			if node is OffsetSprite:
				node.play_animation(&"idle")
				node.set_frame_and_progress(0, 0)
				
				if node.is_in_group(&"tween_bop"):
					# Calculates the speed it would need to go at the time requested
					var time: float = GameManager.seconds_per_beat * 2
					var real_animation_name: String = node.get_real_animation(&"idle")
					
					var animatiom_speed: float = node.sprite_frames.get_animation_speed(real_animation_name)
					var frame_count: int = node.sprite_frames.get_frame_count(real_animation_name) 
					
					node.speed_scale = frame_count / (animatiom_speed * time)
			
			elif node is AnimatedSprite2D:
				
				node.play(node.animation)
				node.set_frame_and_progress(0, 0)
	
	for node in get_tree().get_nodes_in_group(&"fast_bop"):
		if node is OffsetSprite:
			node.play_animation("idle")
			node.set_frame_and_progress(0, 0)
		
		elif node is AnimatedSprite2D:
			node.play(node.animation)
			node.set_frame_and_progress(0, 0)
