extends Node

func _ready() -> void:
	Signals.play_conductor_step_hit.connect(play_conductor_step_hit)
	Signals.play_conductor_beat_hit.connect(play_conductor_beat_hit)
	Signals.play_song_start.connect(play_song_start)
	Signals.play_song_finished.connect(play_song_finished)
	Signals.play_note_hit.connect(play_note_hit)
	Signals.play_note_miss.connect(play_note_miss)
	Signals.play_note_holding.connect(play_note_holding)
	Signals.play_note_created.connect(play_note_created)
	Signals.play_new_event.connect(play_new_event)
	Signals.play_combo_break.connect(play_combo_break)

func play_conductor_step_hit(step: int, measure: int) -> void:
		pass

func play_conductor_beat_hit(step: int, measure: int) -> void:
	pass

func play_song_start() -> void:
	pass

func play_song_finished() -> void:
	pass

func play_note_hit(note: Note, lane: int, hit_time_difference: float, strum_manager: StrumManager) -> void:
	pass

func play_note_miss(note: Note, lane: int, strum_manager: StrumManager) -> void:
	pass

func play_note_holding(note: Note, lane: int, hold_delta: float, strum_manager: StrumManager) -> void:
	pass

func play_note_created(note: Note, strum: Strum) -> void:
	pass

func play_new_event(time: float,event_name: String, params: Array) -> void:
	pass

func play_combo_break() -> void:
	pass
