extends Node
class_name CameraController 

@onready var noise = FastNoiseLite.new()
@onready var rand = RandomNumberGenerator.new()

@export_subgroup("Essentials")

@export var parent_2D:Camera2D
@export var parent_3D:Camera3D

@export_custom(PROPERTY_HINT_LINK, 'x') var target_zoom: Vector2 = Vector2(1, 1)
@export_range(1, 25) var lerp_weight: float = 5

@export var lerping = true

@export_subgroup("Shaking")

@export var shake_time: float = 0.0
@export var shaking: bool = false

var default_offset:Vector2

# How quickly to move through the noise
@export var shake_speed: float = 30.0
# Noise returns values in the range (-1, 1)
# So this is how much to multiply the returned value by
@export var shake_strength: float = 60.0
# The starting range of possible offsets using random values
@export var random_shake_strength: float = 30.0
# Multiplier for lerping the shake strength to zero
@export var shake_decay_rate: float = 3.0

var noise_i: float = 0.0

var position:Variant:
	set(value):
		set_position(value)
	get:
		return get_position()

var zoom:Variant :
	set(value):
		set_zoom(value)
	get:
		return get_zoom()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	 
	if not parent_2D and not parent_3D:
		assert(false,"Camera controller is missing a camera parent")
	
	if parent_2D:
		default_offset = parent_2D.offset
	elif parent_3D:
		default_offset = Vector2(parent_3D.h_offset,parent_3D.v_offset)

func get_direct():
	if parent_2D: 
		return parent_2D
	elif parent_3D:
		return parent_3D
	return null

func set_zoom(value:Variant):
	if value == null: return
	
	if parent_2D:
		if value is Vector2:
			parent_2D.zoom = value
		elif value is float:
			parent_2D.zoom = Vector2(value, value)
	elif parent_3D:
		if value is Vector2:
			parent_3D.fov = value.x
		if value is float:
			parent_3D.fov = value
			
			

func get_zoom() -> Variant:
	if parent_2D: return parent_2D.zoom
	
	return parent_3D.fov


func get_position() ->Variant:
	if parent_2D: return parent_2D.position
	
	return parent_3D.position
	

func set_position(value:Variant):
	if value == null: return
	
	if parent_2D:
		if value is Vector3:
			parent_2D.position = vec3_to_vec2(value)
		elif value is Vector2:
			parent_2D.position = value
		
	elif parent_3D:
		if value is Vector2:
			parent_3D.position.x = value.x
			parent_3D.position.y = value.y
		if value is Vector3:
			parent_3D.position = value

func _physics_process(delta):
	if parent_2D: update_2D(delta)
	if parent_3D: update_3D(delta)


func update_2D(delta):
	if lerping:
		parent_2D.zoom = Global.frame_independent_lerp(parent_2D.zoom, target_zoom, lerp_weight, delta)
	
	if shaking:
		
		shake_strength = lerpf(shake_strength, 0.0, shake_decay_rate * delta)
		
		var shake_offset: Vector2 = get_noise_offset(delta, shake_speed, shake_strength)
		parent_2D.offset = shake_offset
		
		shake_time -= delta
		if shake_time <= 0: end_shake()
		



func update_3D(delta):
	if lerping:
		parent_3D.fov = Global.frame_independent_lerp(parent_3D.fov, target_zoom.x * 75, lerp_weight, delta)
	
	if shaking:
		
		shake_strength = lerpf(shake_strength, 0.0, shake_decay_rate * delta)
		
		var shake_offset: Vector2 = get_noise_offset(delta, shake_speed, shake_strength)
		parent_3D.h_offset = shake_offset.x
		parent_3D.v_offset = shake_offset.y
		
		shake_time -= delta
		if shake_time <= 0: end_shake()


func shake(amount: int, time: float):
	shake_time = time
	shake_decay_rate = time
	shake_strength = amount
	shaking = true

func end_shake():
	shaking = false
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_IN_OUT)
	
	if parent_2D:
		tween.tween_property(self, "offset", default_offset, 0.1)
	elif parent_3D:
		tween.set_parallel()
		tween.tween_property(self, "h_offset", default_offset.x, 0.1)
		tween.tween_property(self, "v_offset", default_offset.y, 0.1)
		
	

func get_noise_offset(delta: float, speed: float, strength: float) -> Vector2:
	noise_i += delta * speed
	# Set the x values of each call to 'get_noise_2d' to a different value
	# so that our x and y vectors will be reading from unrelated areas of noise
	return Vector2(
		noise.get_noise_2d(1, noise_i) * strength,
		noise.get_noise_2d(100, noise_i) * strength
	)

func vec3_to_vec2(vec3:Vector3) -> Vector2:
	return Vector2(vec3.x,vec3.y)
