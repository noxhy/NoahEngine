extends MarginContainer


signal mod_is_active_changed(mod_id, is_active)
signal mod_current_config_changed(mod_id, current_config)

@export var mod_id_label_scene: PackedScene
@export var is_active_toggle_scene: PackedScene
@export var current_config_select_scene: PackedScene

var grid_placeholder := Control

@onready var grid = $"%Grid"


func generate_grid(user_profile: ModUserProfile) -> void:
	for mod_id in user_profile.mod_list.keys():
		_generate_mod_name(mod_id)
		_generate_mod_active_state(mod_id, user_profile)
		if ModLoaderStore.mod_data.has(mod_id) and not ModLoaderStore.mod_data[mod_id].configs.is_empty():
			_generate_mod_current_config(mod_id, user_profile)
		else:
			grid.add_child(grid_placeholder.new())


func _generate_mod_name(mod_id: String) -> void:
	var label_mod_id: ModIdLabel = mod_id_label_scene.instantiate()
	grid.add_child(label_mod_id)
	label_mod_id.text = mod_id

	if ModLoaderStore.mod_data.has(mod_id):
		var mod: ModData = ModLoaderStore.mod_data[mod_id]

		# Check if mod is locked
		if mod.is_locked:
			label_mod_id.set_mandatory_color()

		# Check if the mod is loadable
		if not mod.is_loadable:
			label_mod_id.set_error_color()


func _generate_mod_active_state(mod_id: String, user_profile: ModUserProfile) -> void:
	var is_active_toggle: IsActiveToggle = is_active_toggle_scene.instantiate()
	grid.add_child(is_active_toggle)
	is_active_toggle.mod_id = mod_id
	is_active_toggle.is_active = user_profile.mod_list[mod_id].is_active
	is_active_toggle.connect("is_active_toggled", Callable(self, "_on_mod_is_active_toggled"))

	if ModLoaderStore.mod_data.has(mod_id):
		var mod: ModData = ModLoaderStore.mod_data[mod_id]
		# Check if mod is locked
		if mod.is_locked:
			# Disable the checkbox if it is
			is_active_toggle.disabled = true


func _generate_mod_current_config(mod_id: String, user_profile: ModUserProfile) -> void:
	var current_config_select: CurrentConfigSelect = current_config_select_scene.instantiate()
	grid.add_child(current_config_select)
	current_config_select.mod_id = mod_id
	current_config_select.add_mod_configs(ModLoaderStore.mod_data[mod_id].configs)
	current_config_select.select_item(user_profile.mod_list[mod_id].current_config)
	current_config_select.connect("current_config_selected", Callable(self, "_on_current_config_selected"))


func clear_grid() -> void:
	for child in grid.get_children():
		if not child is Label or child is ModIdLabel:
			grid.remove_child(child)
			child.queue_free()


func _on_mod_is_active_toggled(mod_id: String, is_active: bool) -> void:
	emit_signal("mod_is_active_changed", mod_id, is_active)


func _on_current_config_selected(mod_id: String, config_name: String) -> void:
	emit_signal("mod_current_config_changed", mod_id, config_name)
