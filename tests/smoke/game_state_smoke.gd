extends SceneTree

const GAME_STATE_SCRIPT := preload("res://scripts/autoload/game_state.gd")
const FRAGMENT_ORDERS := [
	[&"kitchen_receipt", &"child_drawing", &"wedding_photo"],
	[&"kitchen_receipt", &"wedding_photo", &"child_drawing"],
	[&"child_drawing", &"kitchen_receipt", &"wedding_photo"],
	[&"child_drawing", &"wedding_photo", &"kitchen_receipt"],
	[&"wedding_photo", &"kitchen_receipt", &"child_drawing"],
	[&"wedding_photo", &"child_drawing", &"kitchen_receipt"],
]


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	for order: Array in FRAGMENT_ORDERS:
		var state := GAME_STATE_SCRIPT.new()
		state.start_new_game()
		for index in order.size():
			var result: Dictionary = state.complete_fragment(order[index])
			if result["status"] != &"ok" or result["should_start_punishment"] != (index == 2):
				_fail("fragment order failed: %s" % [order])
				return
		var repeat: Dictionary = state.complete_fragment(order[2])
		if repeat["status"] != &"noop" or repeat["completed_count"] != 3 or repeat["is_last_fragment"]:
			_fail("fragment completion is not idempotent")
			return
		if state.request_phase(&"punishment_1")["status"] != &"ok":
			_fail("complete fragments did not unlock punishment")
			return
		if state.request_phase(&"loop_2")["status"] != &"ok":
			_fail("punishment did not transition to loop 2")
			return
		state.free()

	var state := GAME_STATE_SCRIPT.new()
	state.start_new_game()
	if not state.record_room_entry(&"kitchen") or state.record_room_entry(&"child_room"):
		_fail("first room was not write-once")
		return
	if state.request_phase(&"punishment_1")["status"] != &"rejected":
		_fail("punishment started before all fragments")
		return
	for fragment: StringName in [&"kitchen_receipt", &"child_drawing", &"wedding_photo"]:
		state.complete_fragment(fragment)
	state.request_phase(&"punishment_1")
	state.request_phase(&"loop_2")
	for attempt in 2:
		if state.register_clock_attempt(6, 40)["hint_upgraded"]:
			_fail("clock hint upgraded before third error")
			return
	if not state.register_clock_attempt(6, 40)["hint_upgraded"]:
		_fail("clock hint did not upgrade on third error")
		return
	if state.open_final_memory()["status"] != &"rejected":
		_fail("final memory opened before the clock was solved")
		return
	if state.register_clock_attempt(2, 17)["status"] != &"correct":
		_fail("02:17 did not solve the clock")
		return
	if state.open_final_memory()["status"] != &"ok" or state.open_final_memory()["status"] != &"noop":
		_fail("final memory opening is not idempotent")
		return
	if state.request_phase(&"ending_face")["status"] != &"rejected":
		_fail("request_phase bypassed commit_ending")
		return
	if state.commit_ending(&"ending_face")["status"] != &"ok":
		_fail("valid ending could not be committed")
		return
	if state.commit_ending(&"ending_avoid")["status"] != &"rejected":
		_fail("second ending was not rejected")
		return
	if state.request_phase(&"title")["status"] != &"ok":
		_fail("ending could not return to a clean title state")
		return
	var snapshot: Dictionary = state.snapshot_for_debug()
	if snapshot["phase"] != &"title" or snapshot["cycle_index"] != 0 or not snapshot["completed_fragments_sorted"].is_empty():
		_fail("reset did not restore a clean title state")
		return

	state.free()
	print("GAME_STATE_SMOKE_OK")
	quit()


func _fail(message: String) -> void:
	push_error("GAME_STATE_SMOKE_FAILED: %s" % message)
	quit(1)
