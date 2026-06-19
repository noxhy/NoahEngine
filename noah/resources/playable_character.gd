class_name PlayableCharacter

@export_category("Songs")
@export var album: Album
@export_category("Menus")
@export_subgroup("Freeplay")
@export_file('*.tscn') var dj: String
@export var background: Texture2D
@export_category("Results")
@export var result_songs: Dictionary[String, String]
@export_file('*.ogg', '*.wav', '*.mp3') var normal_intro: String
@export_file('*.ogg', '*.wav', '*.mp3') var loss_intro: String
@export var result_nodes: Dictionary[String, String] = {"default": ""}
