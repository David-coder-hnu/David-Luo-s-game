extends Node

signal phase_changed(from: StringName, to: StringName)
signal fragment_completed(fragment_id: StringName, count: int)
signal all_fragments_completed
signal first_room_recorded(room_id: StringName)
signal clock_attempted(result: Dictionary)
signal final_memory_opened
signal ending_committed(ending_id: StringName)

const PHASE_TITLE := &"title"
const PHASE_LOOP_1 := &"loop_1"
const PHASE_PUNISHMENT_1 := &"punishment_1"
const PHASE_LOOP_2 := &"loop_2"
const PHASE_ENDING_FACE := &"ending_face"
const PHASE_ENDING_AVOID := &"ending_avoid"

const FRAGMENT_IDS := [&"kitchen_receipt", &"child_drawing", &"wedding_photo"]
const FIRST_ROOM_IDS := [&"kitchen", &"child_room", &"living_room"]

var _phase: StringName = PHASE_TITLE
var _cycle_index := 0
var _completed_fragments: Dictionary = {}
var _first_room_loop_1: StringName = &""
var _behavior_echo_played := false
var _clock_attempt_count := 0
var _clock_solved := false
var _final_memory_opened := false
var _ending_committed := false
var _ending_transition_authorized := false


func _ready() -> void:
	reset_progress()


func start_new_game() -> void:
	reset_progress()
	request_phase(PHASE_LOOP_1)


func reset_progress() -> void:
	var previous := _phase
	_phase = PHASE_TITLE
	_cycle_index = 0
	_completed_fragments.clear()
	_first_room_loop_1 = &""
	_behavior_echo_played = false
	_clock_attempt_count = 0
	_clock_solved = false
	_final_memory_opened = false
	_ending_committed = false
	_ending_transition_authorized = false
	if previous != PHASE_TITLE:
		phase_changed.emit(previous, PHASE_TITLE)


func request_phase(next_phase: StringName) -> Dictionary:
	if next_phase == _phase:
		return _result(&"noop")
	if not _is_legal_transition(_phase, next_phase):
		return _result(&"rejected", &"illegal_transition")
	if next_phase == PHASE_TITLE:
		reset_progress()
		return _result(&"ok")
	var previous := _phase
	_phase = next_phase
	if next_phase == PHASE_LOOP_2:
		_cycle_index = 1
	phase_changed.emit(previous, next_phase)
	return _result(&"ok")


func record_room_entry(room_id: StringName) -> bool:
	if _phase != PHASE_LOOP_1 or room_id not in FIRST_ROOM_IDS or not _first_room_loop_1.is_empty():
		return false
	_first_room_loop_1 = room_id
	first_room_recorded.emit(room_id)
	return true


func complete_fragment(fragment_id: StringName) -> Dictionary:
	if _phase != PHASE_LOOP_1 or fragment_id not in FRAGMENT_IDS:
		return _fragment_result(&"rejected", false, false)
	if _completed_fragments.has(fragment_id):
		return _fragment_result(&"noop", false, false)
	_completed_fragments[fragment_id] = true
	var count := _completed_fragments.size()
	fragment_completed.emit(fragment_id, count)
	var is_last := count == FRAGMENT_IDS.size()
	if is_last:
		all_fragments_completed.emit()
	return _fragment_result(&"ok", is_last, is_last)


func register_clock_attempt(hour: int, minute: int) -> Dictionary:
	if _phase != PHASE_LOOP_2:
		return _clock_result(&"rejected", false)
	if _clock_solved:
		return _clock_result(&"already_solved", false)
	if hour == 2 and minute == 17:
		_clock_solved = true
		var correct := _clock_result(&"correct", false)
		clock_attempted.emit(correct)
		return correct
	_clock_attempt_count += 1
	var upgraded := _clock_attempt_count == 3
	var incorrect := _clock_result(&"incorrect", upgraded)
	clock_attempted.emit(incorrect)
	return incorrect


func open_final_memory() -> Dictionary:
	if _phase != PHASE_LOOP_2 or not _clock_solved:
		return _result(&"rejected", &"clock_unsolved")
	if _final_memory_opened:
		return _result(&"noop")
	_final_memory_opened = true
	final_memory_opened.emit()
	return _result(&"ok")


func commit_ending(ending_id: StringName) -> Dictionary:
	if ending_id not in [PHASE_ENDING_FACE, PHASE_ENDING_AVOID]:
		return _result(&"rejected", &"unknown_ending")
	if _phase != PHASE_LOOP_2 or not _final_memory_opened or _ending_committed:
		return _result(&"rejected", &"ending_unavailable")
	_ending_transition_authorized = true
	var transition := request_phase(ending_id)
	_ending_transition_authorized = false
	if transition["status"] != &"ok":
		return transition
	_ending_committed = true
	ending_committed.emit(ending_id)
	return _result(&"ok")


func snapshot_for_debug() -> Dictionary:
	var fragments: Array = _completed_fragments.keys()
	fragments.sort()
	return {
		"phase": _phase,
		"cycle_index": _cycle_index,
		"completed_fragments_sorted": fragments,
		"first_room_loop_1": _first_room_loop_1,
		"behavior_echo_played": _behavior_echo_played,
		"clock_attempt_count": _clock_attempt_count,
		"clock_solved": _clock_solved,
		"final_memory_opened": _final_memory_opened,
		"ending_committed": _ending_committed,
	}


func _is_legal_transition(from: StringName, to: StringName) -> bool:
	if from == PHASE_TITLE:
		return to == PHASE_LOOP_1
	if from == PHASE_LOOP_1:
		return to == PHASE_PUNISHMENT_1 and _completed_fragments.size() == FRAGMENT_IDS.size()
	if from == PHASE_PUNISHMENT_1:
		return to == PHASE_LOOP_2
	if from == PHASE_LOOP_2:
		return to in [PHASE_ENDING_FACE, PHASE_ENDING_AVOID] and _final_memory_opened and not _ending_committed and _ending_transition_authorized
	if from in [PHASE_ENDING_FACE, PHASE_ENDING_AVOID]:
		return to == PHASE_TITLE
	return false


func _result(status: StringName, reason: StringName = &"") -> Dictionary:
	return {"status": status, "reason": reason}


func _fragment_result(status: StringName, is_last: bool, should_start: bool) -> Dictionary:
	return {
		"status": status,
		"completed_count": _completed_fragments.size(),
		"is_last_fragment": is_last,
		"should_start_punishment": should_start,
	}


func _clock_result(status: StringName, hint_upgraded: bool) -> Dictionary:
	return {
		"status": status,
		"attempt_count": _clock_attempt_count,
		"hint_upgraded": hint_upgraded,
	}
