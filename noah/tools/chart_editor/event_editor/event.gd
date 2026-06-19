extends Node2D
class_name ChartEvent

@onready var area = $Area2D
@onready var collision_shape = $Area2D/CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D

var time: float
var event: String
var parameters: Array
var grid_size: Vector2 = Vector2(128, 128)

# Called when the node enters the scene tree for the first time.
func vanilla_1913280149__ready() -> void:
	if Constants.EVENT_DATA.has(event):
		if Constants.EVENT_DATA[event].has("texture"):
			sprite.texture = load(Constants.EVENT_DATA[event]["texture"])
	
	update()

func vanilla_1913280149_update():
	if sprite:
		sprite.scale = grid_size / sprite.get_rect().size
	
	if collision_shape:
		collision_shape.shape = RectangleShape2D.new()
		$VisibleOnScreenEnabler2D.scale = grid_size / $VisibleOnScreenEnabler2D.rect.size
		collision_shape.scale = $VisibleOnScreenEnabler2D.scale * 0.9
		collision_shape.shape.set_size($VisibleOnScreenEnabler2D.rect.size)


func vanilla_1913280149__on_visible_on_screen_enabler_2d_screen_entered() -> void:
	$Sprite2D.visible = true


func vanilla_1913280149__on_visible_on_screen_enabler_2d_screen_exited() -> void:
	$Sprite2D.visible = false


# ModLoader Hooks - The following code has been automatically added by the Godot Mod Loader.


func _ready():
	if _ModLoaderHooks.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_1913280149__ready, [], 360332233)
	else:
		vanilla_1913280149__ready()


func update():
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_1913280149_update, [], 1218903608)
	else:
		return vanilla_1913280149_update()


func _on_visible_on_screen_enabler_2d_screen_entered():
	if _ModLoaderHooks.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_1913280149__on_visible_on_screen_enabler_2d_screen_entered, [], 402569995)
	else:
		vanilla_1913280149__on_visible_on_screen_enabler_2d_screen_entered()


func _on_visible_on_screen_enabler_2d_screen_exited():
	if _ModLoaderHooks.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_1913280149__on_visible_on_screen_enabler_2d_screen_exited, [], 3537743047)
	else:
		vanilla_1913280149__on_visible_on_screen_enabler_2d_screen_exited()
