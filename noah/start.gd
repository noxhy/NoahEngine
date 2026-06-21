extends Node2D

const MODS_DIR: String = "mods"

# Meant to be replaced
func _ready() -> void:
	load_mods()


func load_mods() -> void:
	if DirAccess.dir_exists_absolute(MODS_DIR):
		print("Opening mods folder at: ", MODS_DIR)
		for mod_folder in DirAccess.get_directories_at(MODS_DIR):
			var mod_dir: String = MODS_DIR.path_join(mod_folder)
			if FileAccess.file_exists(mod_dir.path_join("meta.json")):
				print("found meta")
	else:
		printerr("No mods folder located at %s" % MODS_DIR)	
