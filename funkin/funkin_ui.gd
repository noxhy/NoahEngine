extends BasicUI

@onready var player_icon = $"Health Bar/Icon Manager/Player"
@onready var enemy_icon = $"Health Bar/Icon Manager/Enemy"
@onready var icon_manager = $"Health Bar/Icon Manager"

@onready var health_bar:TextureProgressBar = $"Health Bar"
@onready var performance_text:Label = $"Health Bar/Performance"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	super(delta)


func update_performance_text():
	var perf_str: String = 'Botplay'
	
	if not SettingsManager.get_value(SettingsManager.SEC_GAMEPLAY, "botplay"):
		perf_str = "Score: " + Global.format_number(GameManager.score) \
		+ " • " + "Misses: " + str(GameManager.tallies.get("miss", 0))
	
	performance_text.text = perf_str


func update_enemy(enemy: Character):
	$"Health Bar".set_enemy_color(enemy.color)
	$"Health Bar".set_enemy_icons(enemy.icons)


func update_player(player: Character):
	$"Health Bar".set_player_color(player.color)
	$"Health Bar".set_player_icons(player.icons)


func downscroll_ui():
	$"Player Strum".position.y *= -1
	$"Enemy Strum".position.y *= -1
	health_bar.position.y *= -1
