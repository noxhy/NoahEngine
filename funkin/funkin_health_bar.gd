extends BasicHealthBar

@onready var player_icon = $Icons/Player
@onready var enemy_icon = $Icons/Enemy

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Signals.connect("play_conductor_beat_hit", on_beat)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super(delta)
	var display_x: float = (value / max_value) * size.x
	display_x = size.x - display_x
	
	$Icons.position = Vector2(display_x, 10)
	var conditions = [
		[GameManager.health >= 80, "winning", "losing"],
		[GameManager.health <= 20, "losing", "winning"],
		[true, "default", "default"]
	]
	
	for condition in conditions:
		if condition[0]:
			if player_icon.sprite_frames.get_animation_names().has(condition[1]):
				player_icon.play(condition[1])
			
			if enemy_icon.sprite_frames.get_animation_names().has(condition[2]):
				enemy_icon.play(condition[2])
			
			break


func on_beat(current_beat: int, measure_relative: int):
	var time: float = GameManager.conductor.seconds_per_beat * 0.5 * (1 / GameManager.conductor.stream_player.pitch_scale)
	
	Global.bop_tween(player_icon, "scale", Vector2(0.8, 0.8), Vector2(0.9, 0.9), time, Tween.TRANS_QUAD)
	Global.bop_tween(enemy_icon, "scale", Vector2(0.8, 0.8), Vector2(0.9, 0.9), time, Tween.TRANS_QUAD)


func set_player_icons(icons: SpriteFrames):
	player_icon.frames = icons


func set_enemy_icons(icons: SpriteFrames):
	enemy_icon.frames = icons


func set_player_color(color: Color):
	tint_progress = color


func set_enemy_color(color: Color):
	tint_under = color
