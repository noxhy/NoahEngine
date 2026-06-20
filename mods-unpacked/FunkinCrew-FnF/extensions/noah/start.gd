extends "res://noah/start.gd"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Preload.character_data["boyfriend"] = load("res://mods-unpacked/FunkinCrew-FnF/funkin/playable_characters/boyfriend.tres")
	Preload.character_data["pico"] = load("res://mods-unpacked/FunkinCrew-FnF/funkin/playable_characters/pico.tres")
	
	GameManager.current_character = "boyfriend"
	GameManager.character = Preload.character_data.get(GameManager.current_character)
	print(GameManager.current_character, ": ", Preload.character_data.get(GameManager.current_character))
	print("so this shouldn't be null: ", GameManager.character)
	
	get_tree().change_scene_to_file("res://mods-unpacked/FunkinCrew-FnF/funkin/menus/start_menu/start_menu.tscn")
