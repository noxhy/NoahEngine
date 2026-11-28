extends Node

func _ready() -> void:
	Signals.conductor_step_hit.connect(conductor_step_hit)
	Signals.conductor_beat_hit.connect(conductor_beat_hit)
	Signals.song_start.connect(song_start)
	Signals.song_finished.connect(song_finished)
	Signals.note_hit.connect(note_hit)
	Signals.note_miss.connect(note_miss)
	Signals.note_held.connect(note_held)
	Signals.note_created.connect(note_created)
	Signals.new_event.connect(new_event)
	Signals.combo_break.connect(combo_break)

func conductor_step_hit(step: int, measure: int) -> void:
		pass

func conductor_beat_hit(step: int, measure: int) -> void:
	pass

func song_start() -> void:
	pass

func song_finished() -> void:
	pass

func note_hit(note: Note, lane: int, hit_time_difference: float, strum_manager: StrumManager) -> void:
	pass

func note_miss(note: Note, lane: int, strum_manager: StrumManager) -> void:
	pass

func note_held(note: Note, lane: int, hold_delta: float, strum_manager: StrumManager) -> void:
	pass

func note_created(note: Note, strum: Strum) -> void:
	pass

func new_event(time: float,event_name: String, params: Array) -> void:
	pass

func combo_break() -> void:
	pass
