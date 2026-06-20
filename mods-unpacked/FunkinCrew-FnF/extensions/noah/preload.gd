extends "res://noah/preload.gd"

func _ready() -> void:
	character_data["boyfriend"] = load("uid://c73l5wk1k58mp")
	character_data["pico"] = load("uid://dxqhmrv2rrdkc")
	
	GameManager.current_character = "boyfriend"
	GameManager.character = character_data.get(GameManager.current_character)
