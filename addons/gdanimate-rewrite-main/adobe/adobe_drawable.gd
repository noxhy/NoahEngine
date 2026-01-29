@tool
@abstract
extends Resource
class_name AdobeDrawable


var bounding_box: Rect2 = Rect2():
	get:
		if bounding_box == Rect2():
			calculate_bounding_box()
		
		return bounding_box


func draw_on(parent: RID, frame: int, previous_transform: Transform2D, symbols: Dictionary[StringName, AdobeSymbol], stack: Array[String], id: int) -> void:
	pass


func calculate_bounding_box() -> void:
	bounding_box = Rect2()
