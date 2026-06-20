extends Resource
class_name PlayableCharacter

@export_category("Songs")
@export_file("*.res", "*.tres") var album_path: String
@export_category("Menus")
@export_subgroup("Freeplay")
@export_file('*.tscn') var dj: String
@export_file("*.png", "*.jpg") var background_path: String
@export_category("Results")
@export var result_songs: Dictionary[String, String]
@export_file('*.ogg', '*.wav', '*.mp3') var normal_intro: String
@export_file('*.ogg', '*.wav', '*.mp3') var loss_intro: String
@export var result_nodes: Dictionary[String, String] = {"default": ""}
