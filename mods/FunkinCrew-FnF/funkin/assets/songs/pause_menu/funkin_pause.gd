extends BasicPause

func _ready() -> void:
	super()
	%"Other Info".text = str(GameManager.deaths, " Blue balls")

func load_page(page: String):
	option_nodes = []
	get_tree().call_group(&"options", &"queue_free")
	options = pages.get(page)
	
	for i in options.keys():
		var menu_option_instance = load("uid://55odtbd2v2ql").instantiate()
		
		menu_option_instance.position.x = -640 + 45
		menu_option_instance.position.y = 0
		menu_option_instance.text = options.get(i).get("name").to_upper()
		menu_option_instance.icon = options.get(i).get("icon")
		
		$UI.add_child(menu_option_instance)
		menu_option_instance.label.forced_anim_suffix = &" bold"
		option_nodes.append(menu_option_instance)
		menu_option_instance.add_to_group(&"options")
