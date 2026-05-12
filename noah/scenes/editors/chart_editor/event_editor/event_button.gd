extends HBoxContainer

signal removed

var event: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%"Track Name".text = event


func _on_remove_track_pressed() -> void:
	emit_signal(&"removed")
