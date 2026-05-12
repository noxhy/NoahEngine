extends "res://scenes/stage.gd"

var CAR_PRELOAD = load("res://scenes/game/stages/philly/car.tscn")
var red_light: bool = true
var car_list: Array[Node2D] = []

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var index = 0
	
	# This is janky don't do this
	for car in car_list:
		if car == null:
			car_list.remove_at(index)
			index -= 1
			continue
		
		index += 1


func _on_conductor_new_beat(current_beat, measure_relative):
	if (current_beat % 32 == 0):
		
		red_light = !red_light
		
		var animation = "greentored" if red_light else "redtogreen"
		%"Traffic Light".play(animation, -1, true)
	
	if (current_beat % 4 == 0):
		if !red_light:
			
			if car_list.size() < 2:
				
				print("car spawned")
				var car_instance = CAR_PRELOAD.instantiate()
				
				var rng = randi_range(1, 2)
				car_instance.direction = 1 if rng == 1 else -1
				
				%"Cars Layer".add_child(car_instance)
				car_list.append(car_instance)
