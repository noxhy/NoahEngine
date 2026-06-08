@icon("uid://kdr1a765du27")
extends Node
class_name CameraController


## A camera2D node that this will control.
@export var parent_2D: Camera2D

## A camera3D node that this will control.
@export var parent_3D: Camera3D

#can we change these var names some time
@export_category('Camera Config')
## The intended camera zoom. The camera will automatically attempt to lerp to this zoom.
var target_zoom: Vector2 = Vector2(1, 1)

@export_group("Zoom Smoothing")
## If [code]true[/code], the camera's zoom smoothly zoom towards its target position at [member zoom_smoothing_speed].
@export_custom(PROPERTY_HINT_GROUP_ENABLE, '') var zoom_smoothing: bool = true
## The asymptotic speed of the camera's zoom smoothing effect when [member zoom_smoothing] is true.
@export_custom(PROPERTY_HINT_RANGE, '1,64,suffix:weight') var zoom_smoothing_speed: float = 5


@export_group("Position Smoothing")
## If [code]true[/code], the camera's view smoothly moves towards its target position at [member position_smoothing_speed].
@export_custom(PROPERTY_HINT_GROUP_ENABLE, '') var position_smoothing: bool = true : 
	set(v):
		if parent_2D:
			parent_2D.position_smoothing_enabled = v
		position_smoothing = v
## Speed in pixels per second of the camera's smoothing effect when [member position_smoothing_enabled] is true.
@export_custom(PROPERTY_HINT_NONE, 'suffix:px/s') var position_smoothing_speed: float = 3.0 : 
	set(v):
		if parent_2D:
			parent_2D.position_smoothing_speed = v
		position_smoothing_speed = v


@export_group("Rotation Smoothing")
## If [code]true[/code], the camera's view smoothly rotates, via asymptotic smoothing, to align with its target rotation at [member rotation_smoothing_speed].
@export_custom(PROPERTY_HINT_GROUP_ENABLE, '') var rotation_smoothing: bool = true : 
	set(v):
		if parent_2D:
			parent_2D.rotation_smoothing_enabled = v
		rotation_smoothing = v
## The angular, asymptotic speed of the camera's rotation smoothing effect when [member rotation_smoothing_enabled] is true.
@export var rotation_smoothing_speed: float = 5.0 : 
	set(v):
		if parent_2D:
			parent_2D.rotation_smoothing_speed = v
		rotation_smoothing_speed = v

@export_group("Shake Settings")

## How quickly to move through the noise
@export var shake_speed: float = 30.0
## Noise returns values in the range (-1, 1)
## So this is how much to multiply the returned value by
@export var shake_strength: float = 60.0
## The starting range of possible offsets using random values
@export var random_shake_strength: float = 30.0
## Multiplier for lerping the shake strength to zero
@export var shake_decay_rate: float = 3.0

var default_offset: Vector2
var shake_time: float = 0.0
var shaking: bool = false

var noise = FastNoiseLite.new()
var rand = RandomNumberGenerator.new()
var noise_i: float = 0.0

var _position_3d: Vector3 = Vector3.ZERO # needed for parity with camera 2d
var _rotation_3d: Vector3 = Vector3.ZERO # needed for parity with camera 2d

var rotation: Variant : set = set_rotation, get = get_rotation
var position: Variant : set = set_position, get = get_position
var zoom: Variant : set = set_zoom, get = get_zoom

func _ready() -> void:
	if not parent_2D and not parent_3D:
		printerr('(Camera Controller): No parent was assigned.')
	
	if parent_2D:
		default_offset = parent_2D.offset
		parent_2D.position_smoothing_enabled = position_smoothing
		parent_2D.position_smoothing_speed = position_smoothing_speed
		parent_2D.rotation_smoothing_enabled = rotation_smoothing
		parent_2D.rotation_smoothing_speed = rotation_smoothing_speed
		
		target_zoom = parent_2D.zoom
	elif parent_3D:
		default_offset = Vector2(parent_3D.h_offset, parent_3D.v_offset)
		_position_3d = parent_3D.position
		target_zoom = Vector2(parent_3D.fov, parent_3D.fov)

func get_direct() -> Variant:
	if parent_2D: 
		return parent_2D
	elif parent_3D:
		return parent_3D
	return null

func set_zoom(value: Variant):
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
	elif parent_3D: return parent_3D.fov
	return Vector2.ZERO

func set_position(value: Variant) -> void:
	if value == null: return
	
	if parent_2D:
		if value is Vector3:
			value = Vector2(value.x, value.y)
		parent_2D.position = value
	
	elif parent_3D:
		if value is Vector2:
			if position_smoothing:
				_position_3d.x = value.x
				_position_3d.y = value.y
				return
			
			parent_3D.position.x = value.x
			parent_3D.position.y = value.y
		if value is Vector3:
			if position_smoothing:
				_position_3d = value
				return
			parent_3D.position = value

func get_position() -> Variant:
	if parent_2D: return parent_2D.position
	elif parent_3D: return parent_3D.position
	return Vector2.ZERO

func set_rotation(value: Variant) -> void:
	if value == null: return
	
	if parent_2D:
		if value is Vector3:
			value = Vector2(value.x, value.y)
		parent_2D.rotation = value
	
	elif parent_3D:
		if value is Vector2:
			if position_smoothing:
				_rotation_3d.x = value.x
				_rotation_3d.y = value.y
				return
			
			parent_3D.rotation.x = value.x
			parent_3D.rotation.y = value.y
		if value is Vector3:
			if rotation_smoothing:
				_rotation_3d = value
				return
			parent_3D.rotation = value

func get_rotation() -> Variant:
	if parent_2D: return parent_2D.rotation
	elif parent_3D: return parent_3D.rotation
	return Vector2.ZERO

func _process(delta):
	if parent_2D: update_2d(delta)
	if parent_3D: update_3d(delta)

func update_2d(delta: float):
	if zoom_smoothing:
		parent_2D.zoom = Global.frame_independent_lerp(parent_2D.zoom, target_zoom, zoom_smoothing_speed, delta)
	
	if shaking:
		
		shake_strength = lerpf(shake_strength, 0.0, shake_decay_rate * delta)
		
		var shake_offset: Vector2 = get_noise_offset(delta, shake_speed, shake_strength)
		parent_2D.offset = shake_offset
		
		shake_time -= delta
		if shake_time <= 0: end_shake()

func update_3d(delta: float):
	if zoom_smoothing:
		parent_3D.fov = Global.frame_independent_lerp(parent_3D.fov, target_zoom.x, zoom_smoothing_speed, delta)
	
	if position_smoothing:
		parent_3D.position = lerp_position(parent_3D.position, _position_3d, delta)
	
	if rotation_smoothing:
		var rot_rate = delta * rotation_smoothing_speed
		parent_3D.rotation.x = lerp_angle(parent_3D.rotation.x, _rotation_3d.x, rot_rate)
		parent_3D.rotation.y = lerp_angle(parent_3D.rotation.y, _rotation_3d.y, rot_rate)
		parent_3D.rotation.z = lerp_angle(parent_3D.rotation.z, _rotation_3d.z, rot_rate)
	
	if shaking:
		shake_strength = move_toward(shake_strength, 0, shake_decay_rate * delta)
		
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

func bump(strength: Variant):
	if parent_3D:
		strength *= -1
	zoom += strength

func go_to_marker(marker: Variant) -> void:
	position = marker.global_position
	rotation = marker.global_rotation

var _zoom_tween:Tween = null
func tween_zoom(new_zoom: Vector2, speed: float, trans:Tween.TransitionType = Tween.TransitionType.TRANS_CUBIC, ease_type:Tween.EaseType = Tween.EaseType.EASE_IN_OUT):
	
	if _zoom_tween:
		_zoom_tween.kill()
		
	_zoom_tween = create_tween().set_parallel().set_trans(trans).set_ease(ease_type)
	
	_zoom_tween.tween_property(self, 'target_zoom', new_zoom, speed)
	_zoom_tween.tween_property(self, 'zoom', new_zoom, speed)

func lerp_position(cur: Variant, intended: Variant, delta: float):
	var c = position_smoothing_speed * delta
	return ((intended - cur) * c) + cur
