extends SceneTree

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
	var game_state := root.get_node("GameState")
	var dialogue := root.get_node("DialogueController")
	var house_scene := load("res://scenes/world/house.tscn") as PackedScene
	var house := house_scene.instantiate()
	root.add_child(house)
	await process_frame
	var fragments := _fragment_nodes()
	if fragments.size() != 3:
		_fail("house did not expose exactly three fragment interactions")
		return

	for order: Array in FRAGMENT_ORDERS:
		game_state.start_new_game()
		for index in order.size():
			var fragment_id: StringName = order[index]
			var interaction: Area2D = fragments[fragment_id]
			interaction.call("interact", {"game_snapshot": game_state.snapshot_for_debug()})
			if not dialogue.call("is_active"):
				_fail("first fragment dialogue did not start: %s" % fragment_id)
				return
			if fragment_id in game_state.snapshot_for_debug()["completed_fragments_sorted"]:
				_fail("fragment completed before dialogue closed: %s" % fragment_id)
				return
			dialogue.call("_finish")
			var snapshot: Dictionary = game_state.snapshot_for_debug()
			if snapshot["completed_fragments_sorted"].size() != index + 1:
				_fail("fragment completion count was wrong for order %s" % [order])
				return

		var repeated: Area2D = fragments[order[0]]
		repeated.call("interact", {"game_snapshot": game_state.snapshot_for_debug()})
		if String(dialogue.get("_dialogue_id")) != _repeat_dialogue_id(order[0]):
			_fail("completed fragment did not use loop-one repeat text: %s" % order[0])
			return
		dialogue.call("_finish")
		if game_state.snapshot_for_debug()["completed_fragments_sorted"].size() != 3:
			_fail("repeat interaction changed fragment count")
			return

	house.queue_free()
	await process_frame
	print("FRAGMENT_FLOW_SMOKE_OK")
	quit()


func _fragment_nodes() -> Dictionary:
	var result := {}
	for node: Node in get_nodes_in_group(&"interactable"):
		var fragment_id: StringName = node.get("fragment_id")
		if not fragment_id.is_empty():
			result[fragment_id] = node
	return result


func _repeat_dialogue_id(fragment_id: StringName) -> String:
	if fragment_id == &"kitchen_receipt":
		return "fragment.kitchen.repeat_loop1"
	if fragment_id == &"child_drawing":
		return "fragment.child.repeat_loop1"
	return "fragment.wedding.repeat_loop1"


func _fail(message: String) -> void:
	push_error("FRAGMENT_FLOW_SMOKE_FAILED: %s" % message)
	quit(1)
