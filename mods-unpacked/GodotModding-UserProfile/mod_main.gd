extends Node


var GodotModding_User_Profile_MOD_DIR := "GodotModding-UserProfile"
var GodotModding_User_Profile_LOG_NAME := "GodotModding-UserProfile"

var mod_dir_path := ""
var extensions_dir_path := ""
var translations_dir_path := ""

@onready var user_profile_dialog = load("res://mods-unpacked/GodotModding-UserProfile/content/UserProfiles.tscn").instantiate()


func _init() -> void:
	ModLoaderLog.info("Init", GodotModding_User_Profile_LOG_NAME)
	mod_dir_path = ModLoaderMod.get_unpacked_dir().path_join(GodotModding_User_Profile_MOD_DIR)

	# Add extensions
	install_script_extensions()

	# Add translations
	add_translations()


func install_script_extensions() -> void:
	extensions_dir_path = mod_dir_path.path_join("extensions")


func add_translations() -> void:
	translations_dir_path = mod_dir_path.path_join("translations")


func _ready():
	get_tree().root.call_deferred("add_child", user_profile_dialog)
	handle_config()


func handle_config() -> void:
	# Get the mod config
	var config := ModLoaderConfig.get_current_config(GodotModding_User_Profile_MOD_DIR)
	ModLoader.connect("current_config_changed", Callable(self, "_on_current_config_changed"))
	apply_config(config)


func apply_config(config: ModConfig) -> void:
	user_profile_dialog.call_deferred("apply_config", config)


func _on_current_config_changed(config: ModConfig) -> void:
	if config.mod_id == GodotModding_User_Profile_MOD_DIR:
		apply_config(config)
