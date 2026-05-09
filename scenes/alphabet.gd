@tool
extends Node2D

@export_multiline() var text:String = "":
	set(value):
		text = value
		update_text(value)

@export var sprite_frames:SpriteFrames = preload("res://assets/fonts/alphabet.res"):
	set(value):
		sprite_frames = value
		update_text(text)

## ex. " bold"
@export var forced_anim_suffix:String = "":
	set(value):
		forced_anim_suffix = value
		update_text(text)

func get_suffix(symbol:String):
	if forced_anim_suffix != "" and sprite_frames.has_animation(symbol + forced_anim_suffix):
		return forced_anim_suffix
	if sprite_frames.has_animation(symbol):
		return ""
	if symbol == symbol.to_upper() and sprite_frames.has_animation(symbol + " capital"):
		return " capital"
	if symbol == symbol.to_lower() and sprite_frames.has_animation(symbol + " lowercase"):
		return " lowercase"
	return ""

@export var line_gap:float = 70.0:
	set(value):
		line_gap = value
		update_text(value)
		
@export var default_symbol_width:float = 0.0:
	set(value):
		default_symbol_width = value
		update_text(text)

@export var symbol_widths:Dictionary[String, float] = { " ": 40.0 }:
	set(value):
		symbol_widths = value
		update_text(text)
		
@export var symbol_offsets:Dictionary[String, Vector2] = {
	"g": Vector2(0, 15),
	"j": Vector2(0, 15),
	"p": Vector2(0, 15),
	"q": Vector2(0, 15),
	"y": Vector2(0, 15)
}:
	set(value):
		symbol_offsets = value
		update_text(text)

@export var symbol_name_overrides:Dictionary[String, String] = {
	"&": "amp",
	"😠": "angry faic",
	"'": "apostraphie",
	",": "comma",
	"$": "dollarsign",
	"↓": "down arrow",
	"”": "end parentheses",
	"!": "exclamation point",
	"/": "forward slash",
	"#": "hashtag ",
	"♥": "heart",
	"♡": "heart",
	"←": "left arrow",
	"*": "multiply x",
	".": "period",
	"?": "question mark",
	"→": "right arrow",
	"“": "start parentheses",
	"↑": "up arrow",
}:
	set(value):
		symbol_name_overrides = value
		update_text(text)

func get_symbol_sprite_frames_name(symbol:String):
	if symbol in symbol_name_overrides:
		symbol = symbol_name_overrides[symbol]
	return symbol + get_suffix(symbol)
	
func update_text(new_text):
	for letter in get_children():
		letter.queue_free()
	
	var letters = new_text.split()
	
	var next_x:float
	for i in letters.size():
		var symbol = letters[i]
		var letter:AnimatedSprite2D = AnimatedSprite2D.new()
		letter.sprite_frames = sprite_frames
		letter.centered = false
		
		var anim_name = get_symbol_sprite_frames_name(symbol)
		if letter.sprite_frames.has_animation(anim_name):
			letter.play(anim_name)
			letter.sprite_frames.set_animation_loop(anim_name, true)

		letter.set_meta("symbol", symbol)
		letter.set_meta("sprite_frames_anim", anim_name)
		letter.offset = symbol_offsets.get(symbol) if symbol in symbol_offsets.keys() else Vector2(0.0, 0.0)
		self.add_child(letter)
		
		if i > 0: # TODO: xPos and yPos this bitch bro we need multi line support.
			letter.position.x = next_x
		else:
			letter.position.x = i * 40
		
		next_x = letter.position.x
		if symbol in symbol_widths.keys():
			next_x += symbol_widths.get(symbol)
		else:
			next_x += default_symbol_width
		
		var frame_tex
		if letter.sprite_frames:
			frame_tex = letter.sprite_frames.get_frame_texture(letter.animation, 0)
		
		if frame_tex:
			var real_width = frame_tex.get_width()
			if real_width:
				next_x += real_width
			
			var real_height = frame_tex.get_height()
			if real_height:
				letter.position.y -= real_height
		
