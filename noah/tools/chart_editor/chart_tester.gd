extends BasicSong

# Called when the node enters the scene tree for the first time.
func vanilla_4214990372__ready():
	super._ready()
	
	Signals.connect("play_setup_finished", self._on_setup_finished)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func vanilla_4214990372__process(delta):
	$"UI/Chart Stats".text = "Song: " + str(playstate_host.song_data.title)
	$"UI/Chart Stats".text += "\n" + "Artist: " + str(playstate_host.song_data.artist)
	$"UI/Chart Stats".text += "\n" + "Difficulty: " + str(GameManager.difficulty)
	$"UI/Chart Stats".text += "\n" + "Tempo: " + str(GameManager.conductor.tempo)
	$"UI/Chart Stats".text += "\n" + "Scroll Speed: " + str(playstate_host.ui.strums[0].strums[0].scroll_speed)
	$"UI/Chart Stats".text += "\n" + str(GameManager.tallies).replace("{", "").replace("}", "").replace(",", "\n")


func vanilla_4214990372__on_setup_finished() -> void:
	get_tree().call_group(&"strums", "set_skin", ChartEditor.note_skin)


# ModLoader Hooks - The following code has been automatically added by the Godot Mod Loader.


func _ready():
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_4214990372__ready, [], 938654360)
	else:
		return vanilla_4214990372__ready()


func _process(delta):
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_4214990372__process, [delta], 2229722146)
	else:
		return vanilla_4214990372__process(delta)


func _on_setup_finished():
	if _ModLoaderHooks.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_4214990372__on_setup_finished, [], 1911848729)
	else:
		vanilla_4214990372__on_setup_finished()
