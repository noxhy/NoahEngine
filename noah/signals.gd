extends Node
@warning_ignore_start('unused_signal')

## Global Signal bus that contains access to alot of playstate related functions

## Signal to be emitted when the countdown is ready to begin.
## Emit this at a later point if u have a intro cutscene
signal play_song_ready_to_start()

signal play_setup_finished()

signal play_conductor_step_hit(step: int, measure: int)
signal play_conductor_beat_hit(step: int, measure: int)


signal play_note_hit(note: Note, lane: int, hit_time_difference: float, strum_manager: Variant)
signal play_note_miss(time: float, lane: int, note_type: String, hit_time: float, strum_manager: Variant)
signal play_note_holding(time: float, lane: int, note_length:float, note_type: String, strum_manager: Variant)
signal play_create_note(time: float, lane: int, note_length: float, note_type: String, tempo: float)
signal play_new_event(event_name: String, params: Array, time: float)
signal play_combo_break()

signal play_paused()
signal play_unpaused()
