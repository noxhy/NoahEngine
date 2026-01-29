@tool
extends Resource
class_name AdobeSymbol


@export_storage var layers: Array[AdobeLayer] = []
@export_storage var length: int = 0

var bounding_box: Rect2 = Rect2():
	get:
		if bounding_box == Rect2():
			calculate_bounding_box()
		
		return bounding_box


func calculate_bounding_box() -> void:
	var rect: Rect2 = Rect2()
	for layer: AdobeLayer in layers:
		if layer.clipping:
			continue
		
		rect = rect.merge(layer.bounding_box)
	
	bounding_box = rect
