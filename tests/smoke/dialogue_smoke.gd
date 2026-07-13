extends SceneTree


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var controller := root.get_node_or_null("DialogueController")
	if controller == null or not controller.call("start_dialogue", &"bedroom.bed.loop1"):
		_fail("approved bedroom dialogue could not start")
		return
	if controller.call("current_page_count") != 2 or controller.call("current_page_index") != 0:
		_fail("Chinese dialogue did not load two pages")
		return
	if controller.call("advance") != &"blocked":
		_fail("opening input was not isolated for 100ms")
		return
	await create_timer(0.2).timeout
	if controller.call("advance") != &"revealed" or not controller.call("is_current_page_complete"):
		_fail("first advance did not reveal the current page")
		return
	await create_timer(0.4).timeout
	var page_result: StringName = controller.call("advance")
	if page_result != &"page" or controller.call("current_page_index") != 1:
		_fail("second advance did not move to page two: result=%s elapsed=%s" % [page_result, Time.get_ticks_msec() - int(controller.get("_page_started_msec"))])
		return
	await create_timer(0.2).timeout
	if controller.call("advance") != &"revealed":
		_fail("page two could not be fast-forwarded")
		return
	await create_timer(0.4).timeout
	if controller.call("advance") != &"finished" or controller.call("is_active"):
		_fail("dialogue did not finish exactly once")
		return
	if controller.call("advance") != &"inactive":
		_fail("inactive dialogue accepted an extra input")
		return

	print("DIALOGUE_SMOKE_OK")
	quit()


func _fail(message: String) -> void:
	push_error("DIALOGUE_SMOKE_FAILED: %s" % message)
	quit(1)
