extends Node

# ! Comments prefixed with "!" mean they are extra info. Comments without them
# ! should be kept because they give your mod structure and make it easier to
# ! read by other modders
# ! Comments with "?" should be replaced by you with the appropriate information

# ! This template file is statically typed. You don't have to do that, but it can help avoid bugs
# ! You can learn more about static typing in the docs
# ! https://docs.godotengine.org/en/3.5/tutorials/scripting/gdscript/static_typing.html

# ? Brief overview of what your mod does...

const MOD_DIR := "FunkinCrew-FnF" # Name of the directory that this file is in
const LOG_NAME := "FunkinCrew-FnF:Main" # Full ID of the mod (AuthorName-ModName)

var mod_dir_path := ""
var extensions_dir_path := ""
var translations_dir_path := ""


# ! your _ready func.
func _init() -> void:
	ModLoaderLog.info("Init", LOG_NAME)
	mod_dir_path = ModLoaderMod.get_unpacked_dir().path_join(MOD_DIR)

	# Add extensions
	install_script_extensions()
	install_script_hook_files()


func install_script_extensions() -> void:
	# ! any script extensions should go in this directory, and should follow the same directory structure as vanilla
	extensions_dir_path = mod_dir_path.path_join("extensions")

	# ? Brief description/reason behind this edit of vanilla code...
	ModLoaderMod.install_script_extension(extensions_dir_path.path_join("main.gd"))
	ModLoaderMod.install_script_extension(extensions_dir_path + "/noah/start.gd")
	ModLoaderMod.install_script_extension(extensions_dir_path + "/noah/constants.gd")

	# ! Add extensions (longform version of the above)
	#ModLoaderMod.install_script_extension("res://mods-unpacked/AuthorName-ModName/extensions/main.gd")
	#ModLoaderMod.install_script_extension("res://mods-unpacked/AuthorName-ModName/extensions/entities/units/player/player.gd")


func install_script_hook_files() -> void:
	return
	extensions_dir_path = mod_dir_path.path_join("extensions")
	ModLoaderMod.install_script_hooks("res://main.gd", extensions_dir_path.path_join("main.gd"))


func _ready() -> void:
	ModLoaderLog.info("Ready", LOG_NAME)

	# ! This uses Godot's native `tr` func, which translates a string. You'll
	# ! find this particular string in the example CSV here: translations/modname.csv
	ModLoaderLog.info("Translation Demo: " + tr("MODNAME_READY_TEXT"), LOG_NAME)
