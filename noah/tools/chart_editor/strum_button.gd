extends HFlowContainer

signal move_bound_left(strum_id: int)
signal move_bound_right(strum_id: int)
signal updated
signal opened
signal closed

@export var id: int
@export var muted: bool
@export var track: int

# Called when the node enters the scene tree for the first time.
func vanilla_174085874__ready() -> void:
	_on_window_about_to_popup()


func vanilla_174085874__on_button_pressed() -> void:
	$Window.popup()


func vanilla_174085874__on_save_button_pressed() -> void:
	ChartManager.strum_data[id]["name"] = %"Strum ID".text
	muted = $"Window/VBoxContainer/HBoxContainer4/Check Box".button_pressed
	ChartManager.strum_data[id]["muted"] = muted
	track = %"Vocal Track".value
	ChartManager.strum_data[id]["track"] = track
	
	$Window.hide()
	emit_signal("updated")


func vanilla_174085874__on_window_close_requested() -> void:
	$Window.hide()
	emit_signal("closed")


func vanilla_174085874__on_move_lane_left_pressed() -> void:
	emit_signal("move_bound_left", id)
func vanilla_174085874__on_move_lane_right_pressed() -> void:
	emit_signal("move_bound_right", id)


func vanilla_174085874__on_window_about_to_popup() -> void:
	$Button.text = ChartManager.strum_data[id].get("name", "")
	%"Vocal Track".min_value = 0
	if ChartManager.song != null:
		%"Vocal Track".max_value = ChartManager.song.vocals.size() - 1
	%"Vocal Track".value = ChartManager.strum_data[id]["track"]
	%"Strum ID".text = ChartManager.strum_data[id].get("name", "")
	$"Window/VBoxContainer/HBoxContainer4/Check Box".button_pressed = muted
	emit_signal("opened")

func vanilla_174085874_file_dailog_gui_focus_changed(node: Control) -> void:
	emit_signal(&"gui_focus_changed", node)


# ModLoader Hooks - The following code has been automatically added by the Godot Mod Loader.


func _ready():
	if _ModLoaderHooks.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_174085874__ready, [], 221793766)
	else:
		vanilla_174085874__ready()


func _on_button_pressed():
	if _ModLoaderHooks.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_174085874__on_button_pressed, [], 382393054)
	else:
		vanilla_174085874__on_button_pressed()


func _on_save_button_pressed():
	if _ModLoaderHooks.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_174085874__on_save_button_pressed, [], 2343927180)
	else:
		vanilla_174085874__on_save_button_pressed()


func _on_window_close_requested():
	if _ModLoaderHooks.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_174085874__on_window_close_requested, [], 3680245451)
	else:
		vanilla_174085874__on_window_close_requested()


func _on_move_lane_left_pressed():
	if _ModLoaderHooks.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_174085874__on_move_lane_left_pressed, [], 2166650978)
	else:
		vanilla_174085874__on_move_lane_left_pressed()


func _on_move_lane_right_pressed():
	if _ModLoaderHooks.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_174085874__on_move_lane_right_pressed, [], 4224759989)
	else:
		vanilla_174085874__on_move_lane_right_pressed()


func _on_window_about_to_popup():
	if _ModLoaderHooks.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_174085874__on_window_about_to_popup, [], 2491982164)
	else:
		vanilla_174085874__on_window_about_to_popup()


func file_dailog_gui_focus_changed(node: Control):
	if _ModLoaderHooks.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_174085874_file_dailog_gui_focus_changed, [node], 2142754317)
	else:
		vanilla_174085874_file_dailog_gui_focus_changed(node)
