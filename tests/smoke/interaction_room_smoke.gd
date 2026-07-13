extends SceneTree

const INTERACTABLE_SCRIPT := preload("res://scripts/world/interactable.gd")
const FIRST_ROOMS := {
	&"kitchen": Vector2(320, 528),
	&"child_room": Vector2(1280, 528),
	&"living_room": Vector2(800, 928),
}


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	if not await _verify_interaction_order():
		return
	if not await _verify_room_recording():
		return
	print("INTERACTION_ROOM_SMOKE_OK")
	quit()


func _verify_interaction_order() -> bool:
	var game_state := root.get_node("GameState")
	game_state.start_new_game()
	var player_scene := load("res://scenes/player/player.tscn") as PackedScene
	var player := player_scene.instantiate() as CharacterBody2D
	root.add_child(player)
	player.global_position = Vector2.ZERO
	player.call("set_facing", Vector2.DOWN)

	var behind := _make_interactable(&"behind", Vector2(0, -8))
	var zeta := _make_interactable(&"zeta", Vector2(16, 32))
	var alpha := _make_interactable(&"alpha", Vector2(-16, 32))
	root.add_child(behind)
	root.add_child(zeta)
	root.add_child(alpha)
	await process_frame
	player.call("_select_interaction")
	if player.get("current_target") != alpha:
		_fail("front cone, distance and stable ID ordering was not deterministic")
		return false

	alpha.set("busy", true)
	player.call("_select_interaction")
	if player.get("current_target") != zeta:
		_fail("busy interaction remained selectable")
		return false

	alpha.queue_free()
	zeta.queue_free()
	behind.queue_free()
	player.queue_free()
	await process_frame
	return true


func _verify_room_recording() -> bool:
	var game_state := root.get_node("GameState")
	var house_scene := load("res://scenes/world/house.tscn") as PackedScene
	var house := house_scene.instantiate()
	root.add_child(house)
	await process_frame
	var player := house.get_node("Player") as CharacterBody2D
	for first_room: StringName in FIRST_ROOMS:
		game_state.start_new_game()
		house.set("_current_room_id", &"bedroom")
		player.global_position = FIRST_ROOMS[first_room]
		house.call("_process", 0.0)
		if game_state.snapshot_for_debug()["first_room_loop_1"] != first_room:
			_fail("room trigger did not record %s" % first_room)
			return false
		var other_room: StringName = &"kitchen" if first_room != &"kitchen" else &"child_room"
		player.global_position = FIRST_ROOMS[other_room]
		house.call("_process", 0.0)
		if game_state.snapshot_for_debug()["first_room_loop_1"] != first_room:
			_fail("first room was overwritten after entering %s" % other_room)
			return false
	house.queue_free()
	await process_frame
	return true


func _make_interactable(id: StringName, position_value: Vector2) -> Area2D:
	var interaction := INTERACTABLE_SCRIPT.new() as Area2D
	interaction.set("interaction_id", id)
	interaction.set("dialogue_key", &"bedroom.bed.loop1")
	interaction.position = position_value
	interaction.add_to_group(&"interactable")
	return interaction


func _fail(message: String) -> void:
	push_error("INTERACTION_ROOM_SMOKE_FAILED: %s" % message)
	quit(1)
