@tool
extends Resource
class_name AdobeLayer


@export_storage var name: StringName = &""
@export_storage var frames: Array[AdobeLayerFrame] = []
@export_storage var clipping: bool = false
@export_storage var clipped_by: String = ""

var bounding_box: Rect2 = Rect2():
	get:
		if bounding_box == Rect2():
			calculate_bounding_box()
		
		return bounding_box


func calculate_bounding_box() -> void:
	if clipping:
		return
	
	var rect: Rect2 = Rect2()
	for frame: AdobeLayerFrame in frames:
		for element: AdobeDrawable in frame.elements:
			rect = rect.merge(element.bounding_box)
	
	bounding_box = rect
