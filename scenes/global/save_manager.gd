extends Node

const LOAD_PATH = "user://save.tres"
var instance: Save

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	instance = Save.new()
	_load()

func flush():
	ResourceSaver.save(instance, LOAD_PATH)
	print("(SaveManager) Saved song scores and tokens")

func _load():
	if !FileAccess.file_exists(LOAD_PATH):
		printerr("(SaveManager) Save File does not exist")
		return
	
	instance = load(LOAD_PATH)
	print("(Save Manager) Loaded song scores and values")

## Sets the results data of a song for a certain difficulty
## Returns true if the new score is a highscore.
func set_song_stats(song: String, difficulty: String, score: int, grade: float) -> bool:
	var is_highscore: bool = false
	var song_stats = instance.song_stats.get(song, {})
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
	
	instance.song_stats[song] = song_stats
	flush()
	return is_highscore


## Sets the results data of a week for a certain difficulty
## Returns true if the new score is a highscore.
func set_week_stats(week: String, difficulty: String, score: int, grade: float) -> bool:
	var is_highscore: bool = false
	var week_stats = instance.week_stats.get(week, {})
	if !week_stats.has(difficulty):
		week_stats[difficulty] = {}
	# So you don't have to worry about checking it yourself
	var highscore: int = get_highscore(week, difficulty)
	if (highscore < score):
		week_stats[difficulty]["highscore"] = score
		is_highscore = true
	
	# So you don't have to worry about checking it yourself
	var _grade: float = get_grade(week, difficulty)
	if (_grade < grade):
		week_stats[difficulty]["grade"] = grade
	
	instance.week_stats[week] = week_stats
	flush()
	return is_highscore


## Gets the highscore of the difficulty of the song
func get_highscore(song: String, difficulty: String) -> int:
	var highscore = instance.song_stats.get(song, {}).get(difficulty, {}).get("highscore", -1)
	return highscore

## Gets the grade of the difficulty of the song
func get_grade(song: String, difficulty: String) -> float:
	var grade = instance.song_stats.get(song, {}).get(difficulty, {}).get("grade", -1)
	return grade

## Gets the highscore of the difficulty of the week
func get_week_highscore(week: String, difficulty: String) -> int:
	var highscore = instance.week_stats.get(week, {}).get(difficulty, {}).get("highscore", -1)
	return highscore

## Gets the grade of the difficulty of the week
func get_week_grade(week: String, difficulty: String) -> float:
	var grade = instance.week_stats.get(week, {}).get(difficulty, {}).get("grade", -1)
	return grade
