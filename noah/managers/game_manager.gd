extends Node

const SICK_RATING_WINDOW: float = 0.045
const GOOD_RATING_WINDOW: float = 0.09
const BAD_RATING_WINDOW: float = 0.135
const SHIT_RATING_WINDOW: float = 0.16
const GOOD_COMBO_FREQUENCY: int = 50
const GREAT_COMBO_FREQUENCY: int = 200
const HOLD_NOTE_LENIENCY: float = 1 / 3.0

var song_scene = "res://test/test_scene.tscn"

var conductor:Conductor

# Constants are read only even if I set a new variable to the constant
# so it's just a regular variable with constant notations
# future note: ok so this apparently just also gets set whenever
# other things do so idk
@onready var DEFAULT_TALLIES: Dictionary = {
	"sick": 0,
	"good": 0,
	"bad": 0,
	"shit": 0,
	"miss": 0,
	"max_combo": 0,
	"total_notes": 0
}

enum PLAY_MODE {
	STORY_MODE,
	FREEPLAY,
	CHARTING,
	PRACTICE
}

var freeplay: bool = true
var difficulty: String
var play_mode = PLAY_MODE.FREEPLAY
var current_song: Song
var current_week: Week
var week_songs: Array
var current_week_song: int = 0
var character: PlayableCharacter
var current_character: String = "boyfriend"

var week_score: int = 0
var week_deaths: int = 0
var total_accuracy: float = 0
var songs_played: int = 0
var week_tallies: Dictionary = DEFAULT_TALLIES.duplicate()
var tallies: Dictionary = DEFAULT_TALLIES.duplicate()
var grade: float
var highscore: bool = false
var score: int = 0

var health: float = 50

var accuracy: float = 0.0
var deaths: int = 0
var song_position: float
var seconds_per_beat: float :
	get():
		return conductor.seconds_per_beat
var seconds_per_step: float :
	get():
		return conductor.seconds_per_step
var offset: float :
	get():
		return conductor.offset

func vanilla_1214129798_reset_conductor():
	if conductor:
		remove_child(conductor)
		conductor.free()
	conductor = Conductor.new()
	add_child(conductor)
	conductor.new_beat.connect(_beat_change)
	conductor.new_step.connect(_step_change)

func vanilla_1214129798__step_change(step: int, measure: int):
	Signals.play_conductor_step_hit.emit(step, measure)

func vanilla_1214129798__beat_change(beat: int, measure: int):
	Signals.play_conductor_beat_hit.emit(beat, measure)

func vanilla_1214129798__ready() -> void:
	reset_conductor()
	reset_stats()

func vanilla_1214129798_started_song(song: Song):
	tallies = DEFAULT_TALLIES.duplicate()
	accuracy = 0.0
	current_song = song
	character = Preload.character_data[current_character]
	score = 0

func vanilla_1214129798_finished_song(_score: int):
	week_score += _score
	week_deaths += deaths
	total_accuracy += accuracy
	songs_played += 1
	deaths = 0
	current_week_song += 1
	
	for tally in tallies.keys():
		if week_tallies.has(tally):
			week_tallies[tally] += tallies[tally]
		else:
			week_tallies[tally] = tallies[tally]
	
	grade = get_grade(week_tallies)
	get_rank(grade)
	if !SettingsManager.get_value(SettingsManager.SEC_GAMEPLAY, "botplay"):
		match play_mode:
			PLAY_MODE.CHARTING:
				highscore = false
			
			PLAY_MODE.PRACTICE:
				highscore = false
			
			_:
				highscore = SaveManager.set_song_stats(current_song, difficulty, _score, get_grade(tallies))
				if !GameManager.freeplay and current_week_song == week_songs.size():
					highscore = SaveManager.set_week_stats(current_week, difficulty, week_score, grade)
	else:
		highscore = false

func vanilla_1214129798_reset_stats():
	accuracy = 0.0
	deaths = 0
	week_score = 0
	week_deaths = 0
	songs_played = 0
	current_week_song = 0
	
	tallies = DEFAULT_TALLIES.duplicate()
	week_tallies = DEFAULT_TALLIES.duplicate()

func vanilla_1214129798_get_week_accuracy() -> float:
	return total_accuracy / songs_played

func vanilla_1214129798_get_grade(_tallies: Dictionary) -> float:
	if _tallies.total_notes > 0:
		if _tallies.sick == _tallies.total_notes:
			return 2
		else:
			return float(_tallies.sick + _tallies.good - _tallies.miss) / _tallies.total_notes
	else:
		return 0

func vanilla_1214129798_get_rank(_grade: float) -> String:
	var accuracies = [
		[_grade == 2, "gold"],
		[_grade == 1, "perfect"],
		[_grade >= 0.90, "excellent"],
		[_grade >= 0.80, "great"],
		[_grade >= 0.60, "good"],
		[_grade >= 0, "loss"],
	]
	
	for condition in accuracies: if condition[0]:
		return condition[1]
	return "?"


# ModLoader Hooks - The following code has been automatically added by the Godot Mod Loader.


func reset_conductor():
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_1214129798_reset_conductor, [], 4123681433)
	else:
		return vanilla_1214129798_reset_conductor()


func _step_change(step: int, measure: int):
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_1214129798__step_change, [step, measure], 629601830)
	else:
		return vanilla_1214129798__step_change(step, measure)


func _beat_change(beat: int, measure: int):
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_1214129798__beat_change, [beat, measure], 3973446502)
	else:
		return vanilla_1214129798__beat_change(beat, measure)


func _ready():
	if _ModLoaderHooks.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_1214129798__ready, [], 3972037754)
	else:
		vanilla_1214129798__ready()


func started_song(song: Song):
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_1214129798_started_song, [song], 2618351283)
	else:
		return vanilla_1214129798_started_song(song)


func finished_song(_score: int):
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_1214129798_finished_song, [_score], 1153413894)
	else:
		return vanilla_1214129798_finished_song(_score)


func reset_stats():
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_1214129798_reset_stats, [], 2643518743)
	else:
		return vanilla_1214129798_reset_stats()


func get_week_accuracy() -> float:
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_1214129798_get_week_accuracy, [], 2401393883)
	else:
		return vanilla_1214129798_get_week_accuracy()


func get_grade(_tallies: Dictionary) -> float:
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_1214129798_get_grade, [_tallies], 465630632)
	else:
		return vanilla_1214129798_get_grade(_tallies)


func get_rank(_grade: float) -> String:
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_1214129798_get_rank, [_grade], 3138099825)
	else:
		return vanilla_1214129798_get_rank(_grade)
