extends Node2D

const BOOL_PRELOAD = preload("res://scenes/instances/options/option_node_bool.tscn")
const NUMBER_PRELOAD = preload("res://scenes/instances/options/option_node_number.tscn")
const KEYBIND_PRELOAD = preload("res://scenes/instances/options/option_node_keybind.tscn")
const LABEL_PRELOAD = preload("res://scenes/instances/options/option_node_label.tscn")

@export var box_limit: float = 320

var selected: int = 0
var old_selected: int;
func _process(delta: float) -> void:
	if get_viewport().gui_get_focus_owner():
		if Input.is_action_just_pressed(&"ui_cancel") or Input.is_action_just_pressed(&'mouse_right'):
			get_viewport().gui_release_focus()
	
	if Input.is_action_just_pressed(&"ui_cancel"):
		SoundManager.cancel.play()
		get_tree().paused = false
		self.queue_free()
	
	if Input.is_action_just_pressed(&"ui_up"):
		if get_selected_node() is KeyBindOptionNode:
			old_selected = get_selected_node().selected
		update(selected - 1)
		if get_selected_node() is KeyBindOptionNode:
			get_selected_node().select_button(old_selected)
	
	if Input.is_action_just_pressed(&"ui_down"):
		if get_selected_node() is KeyBindOptionNode:
			old_selected = get_selected_node().selected
		update(selected + 1)
		if get_selected_node() is KeyBindOptionNode:
			get_selected_node().select_button(old_selected)
	
	if (Input.is_action_just_pressed(&"ui_accept")
	or Input.is_action_just_pressed(&"ui_left")
	or Input.is_action_just_pressed(&"ui_right")):
		if get_selected_node() is BoolOptionNode:
			var button: Button = get_selected_node().get_node("%Button")
			button.button_pressed = !button.button_pressed
	
	if Input.is_action_just_pressed(&"ui_accept"):
		if get_selected_node() is KeyBindOptionNode:
			get_selected_node().buttons[get_selected_node().selected]._on_toggled(true)
			get_selected_node().buttons[get_selected_node().selected].button_pressed = true
	
	if Input.is_action_just_pressed(&"ui_left"):
		if get_selected_node() is NumberOptionNode:
			var spin_box: SpinBox = get_selected_node().spin_box
			spin_box.value -= spin_box.step * 5 if Input.is_action_pressed("shift") else spin_box.step
		elif get_selected_node() is KeyBindOptionNode:
			get_selected_node().selected = get_selected_node().selected - 1
			get_selected_node().select_button(get_selected_node().selected)
			# get_tree().call_group("buttons", "normal")
	
	if Input.is_action_just_pressed(&"ui_right"):
		if get_selected_node() is NumberOptionNode:
			var spin_box: SpinBox = get_selected_node().spin_box
			spin_box.value += spin_box.step * 5 if Input.is_action_pressed("shift") else spin_box.step
		elif get_selected_node() is KeyBindOptionNode:
			get_selected_node().selected = get_selected_node().selected + 1
			get_selected_node().select_button(get_selected_node().selected)
	
	if Input.is_action_just_pressed(&"mouse_scroll_up"):
		if %Options.size.y > box_limit:
			var tween = create_tween()
			tween.set_parallel(true)
			tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
			tween.tween_property(%Options, "position",
			Vector2(%Options.position.x, min(64.0, %Options.position.y + 60)), 0.2)
	
	if Input.is_action_just_pressed(&"mouse_scroll_down"):
		if %Options.size.y > box_limit:
			var tween = create_tween()
			tween.set_parallel(true)
			tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
			tween.tween_property(%Options, "position",
			Vector2(%Options.position.x, max(64.0 - (%Options.size.y - box_limit), %Options.position.y - 60)), 0.2)

func load_category(category: String, options: Array):
	get_tree().call_group(&"options", &"queue_free")
	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	var instance;
	
	for i in options.size():
		var packet = options[i]
		var type: StringName = packet[0]
		var data = packet[1]
		var option_name: String;
		
		if type == &"option":
			option_name = data
			var option = SettingsManager._defaults.get(category).get(option_name)
			if (option is float) or (option is int):
				instance = NUMBER_PRELOAD.instantiate()
				var number_info: Array = SettingsManager.get_number_info(category, option_name)
				instance.minimum = number_info[0]
				instance.maximum = number_info[1]
				instance.step = number_info[2]
				if number_info.size() > 3:
					instance.value_name = number_info[3]
				if number_info.size() > 4:
					instance.value_scale = number_info[4]
			elif (option is bool):
				instance = BOOL_PRELOAD.instantiate()
			elif (category == "keybinds"):
				instance = KEYBIND_PRELOAD.instantiate()
			else:
				printerr("Not a valid option type: ", option.get_class())
			instance.display_name = option_name.replace("_", " ")
		elif type == &"label":
			instance = LABEL_PRELOAD.instantiate()
			instance.display_name = data
		else:
			printerr("Unknown type: ", type)
		
		instance.setting_category = category
		instance.setting_name = option_name
		
		%Options.add_child(instance)
		instance.add_to_group(&"options")
		instance.modulate.a = 0
		instance.connect("mouse_entered", self.update.bind(i, true))
		
		tween.tween_method(instance.set_offset_left, 200, 0, 1).set_delay(i * 0.05)
		tween.tween_property(instance, "modulate", Color.WHITE, 1).set_delay(i * 0.05)
	
	update(0)

func _exit_tree() -> void:
	SettingsManager.flush()

func update(i: int, mouse: bool = false):
	var options = get_tree().get_nodes_in_group(&"options")
	selected = wrapi(i, 0, options.size())
	get_tree().call_group(&"options", &"normal")
	get_selected_node().select()
	
	SoundManager.scroll.play()
	get_viewport().gui_release_focus()
	
	if !mouse:
		var tween = create_tween()
		tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		if get_selected_node().position.y >= box_limit:
			tween.tween_property(%Options, "position",
			Vector2(%Options.position.x, -(get_selected_node().position.y - box_limit) + 64), 0.2)
		else:
			tween.tween_property(%Options, "position", Vector2(%Options.position.x, 64), 0.2)

func get_selected_node() -> Node:
	var options = get_tree().get_nodes_in_group(&"options")
	return options[selected]
