extends Node

const LOAD_PATH = "user://save.res"
var instance: Save

# Called when the node enters the scene tree for the first time.
func vanilla_3121520923__ready() -> void:
	instance = Save.new()
	_load()

## Flushes the save in storage.
func vanilla_3121520923_flush():
	ResourceSaver.save(instance, LOAD_PATH)
	print("(SaveManager): Saved song scores and tokens")

## Loads the save from storage.
func vanilla_3121520923__load():
	if !FileAccess.file_exists(LOAD_PATH):
		printerr("(SaveManager): Save File does not exist. Creating a new Save File.")
		flush()
		return
	
	instance = load(LOAD_PATH)
	if not instance:
		instance = Save.new()
		flush()
		printerr("(SaveManager): Save File could not be loaded. Creating a new Save File.")
	else:
		print("(SaveManager): Loaded song scores and values")

## Sets the results data of a song for a certain difficulty
## Returns true if the new score is a highscore.
func vanilla_3121520923_set_song_stats(song: Song, difficulty: String, score: int, grade: float) -> bool:
	var is_highscore: bool = false
	var song_stats = instance.song_stats.get(hash(song.resource_path), {})
	if !song_stats.has(difficulty):
		song_stats[difficulty] = {}
	# So you don't have to worry about checking it yourself
	var highscore: int = get_highscore(song, difficulty)
	if (highscore < score):
		song_stats[difficulty]["highscore"] = score
		is_highscore = true
	
	# So you don't have to worry about checking it yourself
	var _grade: float = get_grade(song, difficulty)
	if (_grade < grade):
		song_stats[difficulty]["grade"] = grade
	
	instance.song_stats[hash(song.resource_path)] = song_stats
	flush()
	return is_highscore


## Sets the results data of a week for a certain difficulty
## Returns true if the new score is a highscore.
func vanilla_3121520923_set_week_stats(week: Week, difficulty: String, score: int, grade: float) -> bool:
	var is_highscore: bool = false
	var week_stats = instance.week_stats.get(week, {})
	if !week_stats.has(difficulty):
		week_stats[difficulty] = {}
	# So you don't have to worry about checking it yourself
	var highscore: int = get_week_highscore(week, difficulty)
	if (highscore < score):
		week_stats[difficulty]["highscore"] = score
		is_highscore = true
	
	# So you don't have to worry about checking it yourself
	var _grade: float = get_week_grade(week, difficulty)
	if (_grade < grade):
		week_stats[difficulty]["grade"] = grade
	
	instance.week_stats[hash(week.resource_path)] = week_stats
	flush()
	return is_highscore


## Gets the highscore of the difficulty of the song
func vanilla_3121520923_get_highscore(song: Song, difficulty: String) -> int:
	var highscore = instance.song_stats.get(hash(song.resource_path), {}).get(difficulty, {}).get("highscore", -1)
	return highscore

## Gets the grade of the difficulty of the song
func vanilla_3121520923_get_grade(song: Song, difficulty: String) -> float:
	var grade = instance.song_stats.get(hash(song.resource_path), {}).get(difficulty, {}).get("grade", -1)
	return grade

## Gets the highscore of the difficulty of the week
func vanilla_3121520923_get_week_highscore(week: Week, difficulty: String) -> int:
	var highscore = instance.week_stats.get(hash(week.resource_path), {}).get(difficulty, {}).get("highscore", -1)
	return highscore

func vanilla_3121520923_has_week_stats(week: Week) -> bool:
	return instance.week_stats.has(hash(week.resource_path));

## Gets the grade of the difficulty of the week
func vanilla_3121520923_get_week_grade(week: Week, difficulty: String) -> float:
	var grade = instance.week_stats.get(hash(week.resource_path), {}).get(difficulty, {}).get("grade", -1)
	return grade


# ModLoader Hooks - The following code has been automatically added by the Godot Mod Loader.


func _ready():
	if _ModLoaderHooks.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_3121520923__ready, [], 4043952847)
	else:
		vanilla_3121520923__ready()


func flush():
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_3121520923_flush, [], 130647869)
	else:
		return vanilla_3121520923_flush()


func _load():
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_3121520923__load, [], 122339290)
	else:
		return vanilla_3121520923__load()


func set_song_stats(song: Song, difficulty: String, score: int, grade: float) -> bool:
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_3121520923_set_song_stats, [song, difficulty, score, grade], 2932581355)
	else:
		return vanilla_3121520923_set_song_stats(song, difficulty, score, grade)


func set_week_stats(week: Week, difficulty: String, score: int, grade: float) -> bool:
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_3121520923_set_week_stats, [week, difficulty, score, grade], 397538688)
	else:
		return vanilla_3121520923_set_week_stats(week, difficulty, score, grade)


func get_highscore(song: Song, difficulty: String) -> int:
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_3121520923_get_highscore, [song, difficulty], 523197014)
	else:
		return vanilla_3121520923_get_highscore(song, difficulty)


func get_grade(song: Song, difficulty: String) -> float:
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_3121520923_get_grade, [song, difficulty], 3602982877)
	else:
		return vanilla_3121520923_get_grade(song, difficulty)


func get_week_highscore(week: Week, difficulty: String) -> int:
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_3121520923_get_week_highscore, [week, difficulty], 1133629697)
	else:
		return vanilla_3121520923_get_week_highscore(week, difficulty)


func has_week_stats(week: Week) -> bool:
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_3121520923_has_week_stats, [week], 494925872)
	else:
		return vanilla_3121520923_has_week_stats(week)


func get_week_grade(week: Week, difficulty: String) -> float:
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_3121520923_get_week_grade, [week, difficulty], 1339359496)
	else:
		return vanilla_3121520923_get_week_grade(week, difficulty)
