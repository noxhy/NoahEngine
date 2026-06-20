class_name CurrentConfigSelect
extends OptionButton


signal current_config_selected(mod_id, config_name)

var mod_id: String
var config_names := {}


func add_mod_configs(mod_configs: Dictionary) -> void:
	var index := 0
	for config_name in mod_configs.keys():
		config_names[config_name] = index
		add_item(config_name)
		index = index + 1


func select_item(item_text: String) -> void:
	select(config_names[item_text])


func _on_CurrentConfigSelect_item_selected(index) -> void:
	emit_signal("current_config_selected", mod_id, get_item_text(index))
