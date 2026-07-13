extends SceneTree


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var house_scene := load("res://scenes/world/house.tscn") as PackedScene
	if house_scene == null:
		_fail("house scene could not be loaded")
		return
	var house := house_scene.instantiate()
	root.add_child(house)
	await process_frame

	var tile_layer := house.get_node_or_null("Tiles") as TileMapLayer
	if tile_layer == null or tile_layer.get_used_cells().size() < 80:
		_fail("bedroom TileMapLayer is missing or incomplete")
		return
	var player := house.get_node_or_null("Player") as CharacterBody2D
	if player == null:
		_fail("playable CharacterBody2D is missing")
		return
	if player.collision_layer != 2 or player.collision_mask != 1:
		_fail("player collision layers do not match the contract")
		return
	var teaching_ids: Array[StringName] = []
	for interaction: Node in get_nodes_in_group(&"interactable"):
		if StringName(interaction.get("fragment_id")).is_empty():
			teaching_ids.append(StringName(interaction.get("interaction_id")))
	if teaching_ids.size() != 2 or &"bed" not in teaching_ids or &"exit_door" not in teaching_ids:
		_fail("bedroom must expose the two approved teaching interactions")
		return
	var text_catalog := root.get_node_or_null("TextCatalog")
	if text_catalog == null:
		_fail("TextCatalog autoload is missing")
		return
	for key: StringName in [
		&"ui.phase.loop1_bedroom",
		&"ui.action.inspect",
		&"bedroom.bed.loop1.01",
		&"bedroom.bed.loop1.02",
		&"bedroom.door.loop1.01",
		&"bedroom.door.loop1.02",
	]:
		if not text_catalog.call("has_key", key):
			_fail("missing localization key: %s" % key)
			return

	player.global_position = Vector2(796, 184)
	player.call("set_facing", Vector2.LEFT)
	await physics_frame
	await physics_frame
	var target: Area2D = player.get("current_target")
	if target == null:
		_fail("reachable teaching interaction was not selected")
		return
	target.call("interact")
	await process_frame
	var hud := house.get_node("GameHUD")
	if not hud.get("dialogue_open") or player.get("control_enabled"):
		_fail("interaction did not open dialogue and lock movement")
		return
	var dialogue_controller := root.get_node("DialogueController")
	await create_timer(0.2).timeout
	dialogue_controller.call("advance")
	await create_timer(0.4).timeout
	dialogue_controller.call("advance")
	await create_timer(0.2).timeout
	dialogue_controller.call("advance")
	await create_timer(0.4).timeout
	dialogue_controller.call("advance")
	await process_frame
	if not player.get("control_enabled") or target.get("busy"):
		_fail("closing dialogue did not restore movement and release the target")
		return

	print("PLAYABLE_BEDROOM_SMOKE_OK")
	house.queue_free()
	quit()


func _fail(message: String) -> void:
	push_error("PLAYABLE_BEDROOM_SMOKE_FAILED: %s" % message)
	quit(1)
