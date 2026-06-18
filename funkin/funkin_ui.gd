extends BasicUI

@export var pixel: bool = false


func _ready() -> void:
	super()
	$"Health Bar".pixel = pixel


func update_enemy(enemy: Character):
	$"Health Bar".set_enemy_color(enemy.color)
	$"Health Bar".set_enemy_icons(enemy.icons)


func update_player(player: Character):
	$"Health Bar".set_player_color(player.color)
	$"Health Bar".set_player_icons(player.icons)
