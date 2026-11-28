extends Node
@warning_ignore_start('unused_signal')
## Signal bus providing access to a variety of events dispatched by the playstate to be used by any node.

## Signal to be emitted when the countdown is ready to begin.
## Emit this at a later point if u have a intro cutscene
signal song_ready_to_start()

## Signal to emitted whenever a new step has been reached by the conductor.
signal conductor_step_hit(step: int, measure: int)

## Signal to emitted whenever a new beat has been reached by the conductor.
signal conductor_beat_hit(beat: int, measure: int)

signal song_start()

## Signal to be emitted whenever a song is finished.
signal song_finished()

## Signal to be emitted whenever a note is hit.
signal note_hit(note: BasicNote, lane: int, hit_time_difference: float, strum_manager: StrumManager)

## Signal to be emitted whenever a note is missed.
signal note_miss(note: BasicNote, lane: int, strum_manager: StrumManager)

## Signal that is emitted whenever a note is being held.
signal note_held(note: BasicNote, lane: int, hold_delta: float, strum_manager: StrumManager)

## Signal that provides the raw data of the note to be created.
signal note_creation_requested(time: float, lane: int, note_length: float, note_type: String, tempo: float)

## Signal that is emitted after a note was created.
signal note_created(note: BasicNote, strum: Strum)

## Signal to be emitted whenever an event within a chart is ready to be dispatched
signal new_event(time: float, event_name: String, params: Array)

## Signal to be emitted whenever a combo is broken
signal combo_break()

## Signal to be emitted whenever the players health is changed
signal health_changed(new_health: float, delta: float)

## Signal to be emitted whenever the game is paused
signal paused()

## Signal to be emitted whenever the game is unpaused
signal unpaused()

## Signal to be emitted when the player has "died"
## Connect to this to apply your own behavior on death
signal play_died()

## emitted whenever the players stats change i.e misses,score,combo
signal stats_changed(stats: NoahStats)

signal settings_loaded()
