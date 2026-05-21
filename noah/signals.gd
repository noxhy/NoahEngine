extends Node

## Signal to be emitted when the countdown is ready to begin.
## Emit this at a later point if u have a intro cutscene
signal play_song_ready_to_start

signal play_setup_finished

signal play_conductor_step_hit(step: int, measure: int)
signal play_conductor_beat_hit(step: int, measure: int)


signal play_note_hit(time: float, lane: int, note_type: Variant, hit_time: float, strum_manager: Variant)
signal play_note_miss(time: float, lane: int, note_type: Variant, hit_time: float, strum_manager: Variant)
signal play_note_holding(time: float, lane: int, note_length:float, note_type: Variant, strum_manager: Variant)
signal play_note_created(time: float, lane: int, note_length: float, note_type: Variant, tempo: float)
signal play_new_event(event_name: String, params: Array, time: float)
signal play_combo_break
