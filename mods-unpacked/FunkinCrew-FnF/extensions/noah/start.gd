extends "res://noah/start.gd"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Preload.character_data["boyfriend"] = load("uid://c73l5wk1k58mp")
	Preload.character_data["pico"] = load("uid://dxqhmrv2rrdkc")
	
	GameManager.current_character = "boyfriend"
	GameManager.character = Preload.character_data.get(GameManager.current_character)
	print(GameManager.current_character, ": ", Preload.character_data.get(GameManager.current_character))
	print("so this shouldn't be null: ", GameManager.character)
	
	get_tree().change_scene_to_file("uid://b1kmgjxpce1de")
