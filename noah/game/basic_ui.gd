extends CanvasLayer
class_name BasicUI
## Custom [CanvasLayer] with ui bumping support and and screen dimming (for [member NoahSettings.underlay_opacity])

@export_custom(PROPERTY_HINT_LINK, 'x') var target_zoom:Vector2 = Vector2.ONE

@export_group("Zoom Smoothing")
## If [code]true[/code], the camera's zoom smoothly zoom towards its target position at [member zoom_smoothing_speed].
@export_custom(PROPERTY_HINT_GROUP_ENABLE, '') var zoom_smoothing: bool = true
## The asymptotic speed of the camera's zoom smoothing effect when [member zoom_smoothing] is true.
@export_custom(PROPERTY_HINT_RANGE, '1, 64, suffix:weight') var zoom_smoothing_speed: float = 5

@onready var rating_marker: Node = $"Rating Marker"
@onready var combo_marker: Node = $"Combo Marker"

## How quickly to move through the noise
var shake_speed: float = 30.0
## Noise returns values in the range (-1, 1)
## [br][br]So this is how much to multiply the returned value by
var shake_strength: float = 60.0
## The starting range of possible offsets using random values
var random_shake_strength: float = 30.0
## Multiplier for lerping the shake strength to zero
var shake_decay_rate: float = 3.0

var default_offset: Vector2
var shake_time: float = 0.0
var shaking: bool = false

var noise = FastNoiseLite.new()
var rand = RandomNumberGenerator.new()
var noise_i: float = 0.0

func _ready() -> void:
	if SettingsManager.data.downscroll: ## TODO: this kinda makes no sense to be here anymore
		for strum_line in get_tree().get_nodes_in_group(&"strums"):
			strum_line.position.y *= -1
	
	default_offset = offset
	apply_underlay()


func _process(delta: float) -> void:
	if zoom_smoothing:
		scale = Global.frame_independent_lerp(scale, target_zoom, zoom_smoothing_speed, delta)
		
	if shaking:
		update_shake(delta)

func bump(strength: Vector2):
	scale += strength

func update_player(player: Character):
	pass

func update_enemy(enemy: Character):
	pass

func apply_underlay():
	var underlay: ColorRect = ColorRect.new()
	underlay.color = Color(0, 0, 0, SettingsManager.data.underlay_opacity)
	underlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	underlay.position -= self.offset
	underlay.z_index = -1000
	
	add_child(underlay)


func update_shake(delta: float) -> void:
	shake_strength = move_toward(shake_strength, 0, shake_decay_rate * delta)
	
	var shake_offset: Vector2 = get_noise_offset(delta, shake_speed, shake_strength)

	offset.x = shake_offset.x + default_offset.x
	offset.y = shake_offset.y + default_offset.y
	
	shake_time -= delta
	if shake_time <= 0:
		end_shake()


func shake(amount: float, time: float) -> void:
	noise.seed = randi()
	noise.frequency = 2
	
	shake_time = time
	shake_decay_rate = 1.0 / amount
	shake_strength = amount
	shaking = true
	print("WAAA")

func end_shake() -> void:
	shaking = false
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_IN_OUT)
	
	tween.tween_property(self, "offset", default_offset, 0.1)

func get_noise_offset(delta: float, speed: float, strength: float) -> Vector2:
	noise_i += delta * speed
	# Set the x values of each call to 'get_noise_2d' to a different value
	# so that our x and y vectors will be reading from unrelated areas of noise
	return Vector2(
		noise.get_noise_2d(1, noise_i),
		noise.get_noise_2d(100, noise_i)
	) * strength
