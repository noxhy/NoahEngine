extends Window

signal selected_type(type: String)

const BLACKLISTED: PackedStringArray = ["default"]

var noteskin : NoteSkin :
	get():
		return ChartEditor.note_skin

var tree: Tree
var chart_root: TreeItem
var add_custom_root: TreeItem

func _ready() -> void:
	tree = Tree.new()
	tree.hide_root = true
	tree.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(tree)
	
	tree.item_activated.connect(item_activated)
	tree.item_edited.connect(item_editted)
	tree.button_clicked.connect(button_clicked)
	tree.item_selected.connect(item_selected)
	
	about_to_popup.connect(display)
	
	close_requested.connect(hide_window)

func hide_window() -> void:
	hide()

func display() -> void:
	tree.clear()
	tree.create_item()
	
	var root = tree.create_item()
	root.set_text(0, "Defaults")
	
	var _item = tree.create_item(root)
	_item.set_text(0, "default")
	
	for i in Constants.NOTE_TYPES:
		add_tree_item(i, root)
		
	chart_root = tree.create_item()
	chart_root.set_text(0, "Chart")
	
	add_chart_types()
	
	chart_root.visible = chart_root.get_first_child() != null

	add_custom_root = tree.create_item()
	add_custom_root.set_icon_max_width(0, 16)
	add_custom_root.set_icon(0, load("res://addons/at-icons/node/arrow_up_to_line.svg"))
	
	add_custom_root.set_text(0, "Add new type")

func get_note_texture(type: String) -> Texture2D:
	
	var anim = str(Constants.NOTE_TYPES.get(type, ""), "right")
	if noteskin.notes_texture.has_animation(anim):
		return noteskin.notes_texture.get_frame_texture(anim, 0)
	
	return noteskin.notes_texture.get_frame_texture("right", 0)


func add_chart_types() -> void:
	
	if not EditorResources.chart:
		return
	
	var spotted_types: Array[String] = []
	
	for i in EditorResources.chart.notes:
		if i.size() > 3:
			var type = str(i[3])
			if not type.is_empty() and not Constants.NOTE_TYPES.has(type) and not BLACKLISTED.has(type) and not spotted_types.has(type):
				spotted_types.append(type)
			
		
	for type in spotted_types:
		add_tree_item(type, chart_root)

func add_tree_item(id: String, root: TreeItem) -> void:
	var item = tree.create_item(root)
	item.set_text(0, id)
	setup_item(item)

func setup_item(item: TreeItem) -> void:
	var id = item.get_text(0)
	item.set_icon(0, get_note_texture(id))
	item.set_icon_max_width(0, 16)
	item.set_custom_color(0, NoahTools.generate_colour_from_string(id))
	item.set_editable(0, false)

var TRASH_ICON: Texture2D

func create_custom_item() -> void:
	var item = tree.create_item(chart_root)
	item.set_text(0, 'New Type')
	item.set_editable(0, true)
	item.select(0)
	
	tree.call_deferred(&"edit_selected")
	
	if not TRASH_ICON:
		var texture: Image = load("res://addons/at-icons/node/shopping_basket.svg").get_image()
		var ratio = 16.0 / texture.get_width()
		texture.resize(16, int(texture.get_height() * ratio))
		TRASH_ICON = ImageTexture.create_from_image(texture)
	
	item.add_button(0, TRASH_ICON, -1, false, "Delete this type?")
	
	chart_root.visible = true
	
func item_activated() -> void:
	if tree.get_selected() == add_custom_root:
		create_custom_item()
		SoundManager.tool_open_window.play()
	
func item_editted() -> void:
	var new_item = tree.get_selected()
	var typed_text = new_item.get_text(0)
	if typed_text.is_empty():
		new_item.free()
		return
	
	for item in chart_root.get_children():
		if item != new_item and item.get_text(0) == typed_text:
			new_item.free()
			return
	
	setup_item(new_item)
	item_selected()

func button_clicked(item: TreeItem, column: int, id: int, mouse_button: int) -> void:
	item.free()
	SoundManager.tool_close_window.play()

func item_selected() -> void:
	var ret = tree.get_selected().get_text(0)
	if BLACKLISTED.has(ret):
		ret = ''
	selected_type.emit(ret)
