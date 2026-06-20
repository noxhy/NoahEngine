extends "res://noah/constants.gd"

#region Scene UIDs
var START_MENU_SCENE: String = "res://mods-unpacked/FunkinCrew-FnF/funkin/menus/start_menu/start_menu.tscn"
var MAIN_MENU_SCENE: String = "res://mods-unpacked/FunkinCrew-FnF/funkin/menus/main_menu/main_menu.tscn"
var STORY_MODE_MENU_SCENE: String = "res://mods-unpacked/FunkinCrew-FnF/funkin/menus/story_mode/story_mode.tscn"
var FREEPLAY_MENU_SCENE: String = "res://mods-unpacked/FunkinCrew-FnF/funkin/menus/freeplay/freeplay.tscn"
var CHARACTER_SELECT_SCENE: String = "res://mods-unpacked/FunkinCrew-FnF/funkin/menus/character_select/character_selection.tscn"
var OPTIONS_MENU_SCENE: String = "res://mods-unpacked/FunkinCrew-FnF/funkin/menus/options/options.tscn"
var OPTIONS_SUBMENU_SCENE: String = "res://mods-unpacked/FunkinCrew-FnF/funkin/menus/options/options_submenu.tscn"
var CREDITS_MENU_SCENE: String = "res://mods-unpacked/FunkinCrew-FnF/funkin/menus/credits/credits.tscn"
var RESULTS_MENU_SCENE: String = "res://mods-unpacked/FunkinCrew-FnF/funkin/menus/results/results.tscn"
#endregion

func _init() -> void:
	NOTE_TYPES["mom"] = ""
