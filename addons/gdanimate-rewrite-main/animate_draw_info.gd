extends RefCounted
class_name AnimateDrawInfo


@export var symbol: String = ""
@export var frame: int = 0
@export var offset: Vector2 = Vector2.ZERO
@export var transform: Transform2D = Transform2D.IDENTITY
@export var material: Material = null
@export var additive_material: Material = null
@export var screen_transform: Transform2D = Transform2D.IDENTITY
@export var light_mask: int = 1
@export var visibility_layer: int = 1

var items: Array[RID]


func _init(_symbol: String, _frame: int,
		_offset: Vector2, _transform: Transform2D,
		_items: Array[RID] = []) -> void:
	symbol = _symbol
	frame = _frame
	offset = _offset
	transform = _transform
	items = _items
