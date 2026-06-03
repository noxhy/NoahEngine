extends CanvasLayer

@onready var strums = [$"Player Strum", $"Enemy Strum"]
@onready var player_icon = $"Health Bar/Icon Manager/Player"
@onready var enemy_icon = $"Health Bar/Icon Manager/Enemy"

@onready var rating_marker = $"Rating Marker"
@onready var combo_marker = $"Combo Marker"

@export var target_scale = Vector2(1, 1)
@export_range(1, 25) var lerp_weight: float = 5.0
@export var lerping = true

@export var target_health = 50.0

@onready var health_bar:TextureProgressBar = $"Health Bar"
@onready var performance_text:Label = $"Health Bar/Performance"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update_performance_text()
	update_health_bar(Global.frame_independent_lerp(health_bar.value, target_health, 25, delta))


func _physics_process(delta):
	scale = Global.frame_independent_lerp(scale,target_scale, lerp_weight, delta)

# Util
func set_player_icons(icons: SpriteFrames): player_icon.frames = icons
func set_enemy_icons(icons: SpriteFrames): enemy_icon.frames = icons

func set_player_color(color: Color): health_bar.tint_progress = color
func set_enemy_color(color: Color): health_bar.tint_under = color


# Visual Util
func icon_bop(time: float):
	Global.bop_tween(player_icon, "scale", Vector2(0.8, 0.8), Vector2(0.9, 0.9), time, Tween.TRANS_QUAD)
	Global.bop_tween(enemy_icon, "scale", Vector2(0.8, 0.8), Vector2(0.9, 0.9), time, Tween.TRANS_QUAD)


func update_performance_text():
	var perf_str: String = 'Botplay'
	
	if not SettingsManager.get_value(SettingsManager.SEC_GAMEPLAY, "botplay"):
		perf_str = "Score: " + Global.format_number(GameManager.score) \
		+ " • " + "Misses: " + str(GameManager.tallies.get("miss", 0))
	
	performance_text.text = perf_str


func update_health_bar(health: float):
	health_bar.value = health
	
	var display_x: float = (health_bar.value / health_bar.max_value) * health_bar.size.x
	display_x = health_bar.size.x - display_x
	
	$"Health Bar/Icon Manager".position = Vector2(display_x, 10)
	
	var conditions = [
		[health >= 80, "winning", "losing"],
		[health <= 20, "losing", "winning"],
		[true, "default", "default"],
	]
	
	for condition in conditions:
		if condition[0]:
			if player_icon.sprite_frames.get_animation_names().has(condition[1]):
				player_icon.play(condition[1])
			
			if enemy_icon.sprite_frames.get_animation_names().has(condition[2]):
				enemy_icon.play(condition[2])
			break


func downscroll_ui():
	$"Player Strum".position.y *= -1
	$"Enemy Strum".position.y *= -1
	health_bar.position.y *= -1


func set_credits(song_name: String, artist_names: String):
	pass
