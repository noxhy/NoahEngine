extends Node2D

const MODS_DIR: String = "mods"

@export_dir var debug_mod_dirs: PackedStringArray

var mod_node = load("uid://dquulk3yl1u8e")
var mods: PackedStringArray
var mod_data: Dictionary = {}
var nodes: Array = []

var selected: int = -1

@onready var mod_container = %"Mod Container"
@onready var info_container = %"Information Container"
@onready var mod_icon = %Icon
@onready var mod_name = %Name
@onready var mod_description = %Description
@onready var credits = %Credits

# Meant to be replaced
func _ready() -> void:
	load_mods()
	display_mods()
	update(-1)
	
	var i: int = 0
	for node in get_tree().get_nodes_in_group(&"mods"):
		node.connect(&"mouse_entered", self.update.bind(i))
		node.connect(&"mouse_exited", self.update.bind(-1))
		node.connect(&"gui_input", self.mod_input.bind(node))
		i += 1


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"chart_editor"):
		Global.change_scene_to(Constants.CHART_EDITOR_SCENE, null)


func display_mods() -> void:
	for mod_dir in mods:
		var data = mod_data[mod_dir]
		
		var mod_instance = mod_node.instantiate()
		mod_container.add_child(mod_instance)
		mod_instance.image = load(data.get("image"))
		mod_instance.mod_name = data.get("name", "No name found.")
		mod_instance.description = data.get("credits", "No credits found.")
		mod_instance.dir = mod_dir


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
					mod_dir = "res://".path_join(mod_pack.get_basename())
					var meta_path: String = mod_dir.path_join("meta.json")
					print("Looking for meta at %s" % meta_path)
					if FileAccess.file_exists(meta_path):
						var data = JSON.parse_string(FileAccess.open(meta_path, FileAccess.READ).get_as_text())
						mod_data[mod_dir] = data
						mods.append(mod_dir)
						print("Found metadata for: ", data.get("name"))
				else:
					printerr("File is not a resource pack: ", mod_path)
	# Loading mods when testing
	else:
		print("Development Strategy")
		for mod_pack in debug_mod_dirs:
			if DirAccess.open(mod_pack):
				print("Opening mods folder at: ", mod_pack)
				
				var meta_path: String = mod_pack.path_join("meta.json")
				print("Looking for meta at %s" % meta_path)
				if FileAccess.file_exists(meta_path):
					var data = JSON.parse_string(FileAccess.open(meta_path, FileAccess.READ).get_as_text())
					mod_data[mod_pack] = data
					mods.append(mod_pack)
					print("Found metadata for: ", data.get("name"))


func update(i: int):
	var j: int = 0
	for node in get_tree().get_nodes_in_group(&"mods"):
		var mod: String = mods[j]
		var data = mod_data[mod]
		
		if j != selected:
			if !data.get("supported_versions", []).has(ProjectSettings.get_setting("application/config/version")):
				node.change_style(ModNode.ButtonStyle.WRONG)
			elif j == i:
				node.change_style(ModNode.ButtonStyle.HOVER)
			else:
				node.change_style(ModNode.ButtonStyle.IDLE)
		else:
			node.change_style(ModNode.ButtonStyle.ACTIVE)
		
		j += 1


func update_mod_info():
	var mod_dir: String = mods[selected]
	
	mod_icon.texture = load(mod_data[mod_dir].get("image"))
	mod_name.text = mod_data[mod_dir].get("name", "No name found.")
	credits.text = mod_data[mod_dir].get("credits", "No credits found.")
	mod_description.text = str("Version: ", mod_data[mod_dir].get("version", "0.0.0"))
	mod_description.text += str("\nDescription: ", mod_data[mod_dir].get("description", "No description found."))


func mod_input(event: InputEvent, node: Variant):
	if event is InputEventMouseButton:
		if event.is_released() and event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
			selected = mods.find(node.dir)
			info_container.visible = true
			update(selected)
			update_mod_info()


func _on_run_mod_pressed() -> void:
	var mod_dir: String = mods[selected]
	var init_path: String = mod_dir
	if OS.is_debug_build():
		init_path = init_path.path_join("init.gd")
	else:
		init_path = init_path.path_join("init.gdc")
	
	if FileAccess.file_exists(init_path):
		print("Running init at: ", init_path)
		var init_res = load(init_path)
		var init_instance = init_res.new()
