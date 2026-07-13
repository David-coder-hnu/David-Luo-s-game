extends SceneTree


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var game_state := root.get_node("GameState")
	game_state.start_new_game()
	var house_scene := load("res://scenes/world/house.tscn") as PackedScene
	var house := house_scene.instantiate()
	root.add_child(house)
	await process_frame

	var kitchen := house.get_node("RoomBackgrounds/KitchenV3") as Sprite2D
	var child_room := house.get_node("RoomBackgrounds/ChildRoomV3") as Sprite2D
	var bedroom := house.get_node("RoomBackgrounds/BedroomV3") as Sprite2D
	var child_drawing := house.get_node("child_drawing") as Area2D
	var kitchen_loop_1 := kitchen.texture
	var child_room_loop_1 := child_room.texture
	var bedroom_loop_1 := bedroom.texture
	var child_drawing_loop_1_position := child_drawing.position
	if kitchen_loop_1 == null or child_room_loop_1 == null or bedroom_loop_1 == null:
		_fail("V3 loop-one textures were not loaded")
		return

	for fragment_id: StringName in game_state.FRAGMENT_IDS:
		game_state.complete_fragment(fragment_id)
	if game_state.request_phase(game_state.PHASE_PUNISHMENT_1)["status"] != &"ok":
		_fail("could not enter punishment before V3 loop-two check")
		return
	if game_state.request_phase(game_state.PHASE_LOOP_2)["status"] != &"ok":
		_fail("could not enter loop two for V3 texture check")
		return
	await process_frame

	if kitchen.texture == kitchen_loop_1:
		_fail("kitchen did not switch to its V3 loop-two texture")
		return
	if child_room.texture == child_room_loop_1:
		_fail("child room did not switch to its V3 loop-two texture")
		return
	if child_drawing.position == child_drawing_loop_1_position or child_drawing.position != Vector2(1184, 608):
		_fail("child drawing interaction did not follow the face-up loop-two paper")
		return
	if bedroom.texture != bedroom_loop_1:
		_fail("room without a loop-two texture did not preserve its approved fallback")
		return
	house.call("_place_player_for_capture", &"kitchen")
	await process_frame
	var room_tag := house.get_node("GameHUD/RoomTag") as Label
	if room_tag.text != "第二轮  ·  厨房":
		_fail("HUD did not reflect the loop-two kitchen state: %s" % room_tag.text)
		return

	game_state.start_new_game()
	await process_frame
	if kitchen.texture != kitchen_loop_1 or child_room.texture != child_room_loop_1:
		_fail("starting a new game did not restore the V3 loop-one textures")
		return
	if child_drawing.position != child_drawing_loop_1_position:
		_fail("starting a new game did not restore the hidden child drawing interaction")
		return

	print("V3_ROOM_STATE_SMOKE_OK")
	house.queue_free()
	quit()


func _fail(message: String) -> void:
	push_error("V3_ROOM_STATE_SMOKE_FAILED: %s" % message)
	quit(1)
