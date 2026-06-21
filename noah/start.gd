extends Node2D

const MODS_DIR: String = "mods"

@export_dir var mods: PackedStringArray

# Meant to be replaced
func _ready() -> void:
	load_mods()


func load_mods() -> void:
	# Loading mods when exported
	if !OS.is_debug_build():
		print("Exported Build Strategy")
		if DirAccess.dir_exists_absolute(MODS_DIR):
			var mod_dir: String = OS.get_executable_path().get_base_dir().path_join(MODS_DIR)
			print("Opening mods folder at: ", mod_dir)
			for mod_pack in DirAccess.get_files_at(mod_dir):
				var mod_path: String = mod_dir.path_join(mod_pack)
				print("Reading RSP at: ", mod_path)
				var rsp = ProjectSettings.load_resource_pack(mod_path)
				
				if rsp:
					var meta_path: String = "res://".path_join(mod_pack.get_basename()).path_join("meta.json")
					var init_path: String = "res://".path_join(mod_pack.get_basename()).path_join("init.gdc")
					print("Looking for meta at %s" % meta_path)
					if FileAccess.file_exists(meta_path):
						var data = JSON.parse_string(FileAccess.open(meta_path, FileAccess.READ).get_as_text())
						print("Found metadata for: ", data.get("name"))
						if FileAccess.file_exists(init_path):
							print("Running init at: ", init_path)
							var init_res = load(init_path)
							var init_instance = init_res.new()
							init_instance._ready()
				else:
					printerr("File is not a resource pack: ", mod_path)
	# Loading mods when testing
	else:
		print("Development Strategy")
		for mod_pack in mods:
			if DirAccess.open(mod_pack):
				print("Opening mods folder at: ", mod_pack)
				
				var meta_path: String = mod_pack.path_join("meta.json")
				var init_path: String = mod_pack.path_join("init.gd")
				print("Looking for meta at %s" % meta_path)
				if FileAccess.file_exists(meta_path):
					var data = JSON.parse_string(FileAccess.open(meta_path, FileAccess.READ).get_as_text())
					print("Found metadata for: ", data.get("name"))
					print("Running init at: ", init_path)
					
					if FileAccess.file_exists(init_path):
						var init_res = load(init_path)
						var init_instance = init_res.new()
						init_instance._ready()
