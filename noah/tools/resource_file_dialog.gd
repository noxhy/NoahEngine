@icon("res://addons/at-icons/node/window_terminal.svg")
extends Window
class_name ResourceFileDialog

signal file_selected(path: String)

## The [Resource] being searched for.
@export var resource_type: Variant:
	set(v):
		resource_type = v
		_search()
## Starting directory to search in.
@export_dir var starting_directory: String = "res://":
	set(v):
		starting_directory = v
		_search()

var tree: Tree
var found_files: Dictionary[String, PackedStringArray]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tree = Tree.new()
	tree.hide_root = true
	tree.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(tree)
	connect(&'about_to_popup', display)
	tree.connect(&"item_activated", item_activated)

## Removes all children of [member vbox_container].
func _clear_files() -> void:
	found_files.clear()
	display()

## Searches and caches the files
func _search() -> void:
	var files: PackedStringArray = NoahTools.get_resource_files(resource_type, starting_directory)
	for file in files:
		var dir: String = file.get_base_dir()
		if !found_files.has(dir):
			found_files[dir] = []
		
		found_files[dir].append(file)

## Displays all the found files on the tree
func display() -> void:
	tree.clear()
	var root: TreeItem = tree.create_item()
	for dir in found_files:
		var dir_item: TreeItem = root.create_child()
		dir_item.set_text(0, dir)
		
		for file in found_files[dir]:
			var file_item: TreeItem = dir_item.create_child()
			file_item.set_text(0, file.get_file())
			file_item.set_metadata(0, file)
			var resource: Resource = load(file)
			if resource is NoteSkin:
				file_item.set_icon(0, resource.notes_texture.get_frame_texture(&"up", 0))
			else:
				file_item.set_icon(0, load("res://addons/at-icons/node/file.svg"))
			
			file_item.set_icon_max_width(0, 16)


func item_activated() -> void:
	var item: TreeItem = tree.get_selected()
	if item.get_metadata(0) == null:
		return
	if item:
		var path: String = item.get_metadata(0)
		emit_signal(&"file_selected", path)
	
	hide()
