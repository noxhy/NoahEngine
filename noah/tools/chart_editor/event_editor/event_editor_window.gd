extends PopupPanel


var EVENT_PRELOAD: PackedScene = load("uid://ustf4vogtxy5")

var event_title: String = 'dummy'
var event_param_data: Array = ["um"]

func _ready() -> void:
	$"%Event Name".text = event_title
	%"Desc Label".text = Constants.EVENT_DATA[event_title].get('description', "")

func add_tab(ev: Array):
	var tab = EVENT_PRELOAD.instantiate()
	tab.name = str(%TabContainer.get_child_count() + 1)
	tab.construct_from_event(event_title, ev)
	
	%TabContainer.add_child(tab)

func _on_add_tab_pressed() -> void:
	add_tab([0, event_title, event_param_data])
