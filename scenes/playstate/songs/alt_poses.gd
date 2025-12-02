extends "res://scenes/playstate/songs/basic_song.gd"


func note_hit(time, lane, note_type, hit_time, strumhandler):
	var animations = ["left", "down", "up", "right"]
	
	if !strumhandler.enemy_slot:
		characters[0].play_animation(animations[lane])
	else:
		if note_type == 1:
			characters[1].current_prefix = &"mom_"
		else:
			characters[1].current_prefix = &""
		characters[1].play_animation(animations[lane])
	
	playstate_host.note_hit(time, lane, note_type, hit_time, strumhandler)


func note_holding(time, lane, note_type, strumhandler):
	var animations = ["left", "down", "up", "right"]
	
	if !strumhandler.enemy_slot:
		characters[0].play_animation(animations[lane])
	else:
		if note_type == 1:
			characters[1].play_animation(str("mom_", animations[lane]))
		else:
			characters[1].play_animation(animations[lane])
	
	playstate_host.note_holding(time, lane, note_type, strumhandler)
