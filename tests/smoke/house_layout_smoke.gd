extends SceneTree

const TARGET_CELLS := {
	&"bedroom": Vector2i(25, 7),
	&"hallway": Vector2i(25, 16),
	&"kitchen": Vector2i(10, 16),
	&"child_room": Vector2i(40, 16),
	&"living_room": Vector2i(25, 29),
}
const OPENING_CELLS := [
	Vector2i(24, 10), Vector2i(25, 10), Vector2i(24, 11), Vector2i(25, 11),
	Vector2i(17, 15), Vector2i(17, 16), Vector2i(18, 15), Vector2i(18, 16),
	Vector2i(31, 15), Vector2i(31, 16), Vector2i(32, 15), Vector2i(32, 16),
	Vector2i(24, 21), Vector2i(25, 21), Vector2i(24, 22), Vector2i(25, 22),
]
const CARDINALS := [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var house_scene := load("res://scenes/world/house.tscn") as PackedScene
	var house := house_scene.instantiate()
	root.add_child(house)
	await process_frame

	if house.call("map_size") != Vector2i(50, 38):
		_fail("map size is not 50x38")
		return
	var tile_layer := house.get_node("Tiles") as TileMapLayer
	if tile_layer.get_used_cells().size() < 650:
		_fail("five-room tile coverage is incomplete: %s" % tile_layer.get_used_cells().size())
		return
	var room_backgrounds := house.get_node_or_null("RoomBackgrounds")
	if room_backgrounds == null or room_backgrounds.get_child_count() != 5:
		_fail("five V3 runtime room backgrounds are not wired into the house")
		return
	var visible_backgrounds := 0
	for background: CanvasItem in room_backgrounds.get_children():
		if background.visible:
			visible_backgrounds += 1
	if visible_backgrounds != 1:
		_fail("exactly one V3 room background must be visible")
		return
	for opening: Vector2i in OPENING_CELLS:
		if house.call("is_wall_cell", opening) or not house.call("is_walkable_cell", opening):
			_fail("door opening is blocked: %s" % opening)
			return
	for wall: Vector2i in [Vector2i(20, 2), Vector2i(2, 11), Vector2i(47, 21), Vector2i(14, 35)]:
		if not house.call("is_wall_cell", wall):
			_fail("required perimeter wall is missing: %s" % wall)
			return

	var reachable := _flood_fill(house, TARGET_CELLS[&"bedroom"])
	for room_id: StringName in TARGET_CELLS:
		var target: Vector2i = TARGET_CELLS[room_id]
		if not reachable.has(target):
			_fail("room center is unreachable: %s" % room_id)
			return

	if house.call("camera_target_for_position", Vector2(320, 528)) != Vector2(320, 528):
		_fail("kitchen camera does not align to the room composition")
		return
	if house.call("camera_target_for_position", Vector2(1280, 528)) != Vector2(1280, 528):
		_fail("child room camera does not align to the room composition")
		return
	for room_id: StringName in TARGET_CELLS:
		var world_position := Vector2(TARGET_CELLS[room_id] * 32) + Vector2(16, 16)
		if house.call("room_id_for_position", world_position) != room_id:
			_fail("room identification failed: %s" % room_id)
			return

	print("HOUSE_LAYOUT_SMOKE_OK")
	house.queue_free()
	quit()


func _flood_fill(house: Node, start: Vector2i) -> Dictionary:
	var visited := {start: true}
	var frontier: Array[Vector2i] = [start]
	while not frontier.is_empty():
		var current: Vector2i = frontier.pop_front()
		for direction: Vector2i in CARDINALS:
			var neighbor: Vector2i = current + direction
			if visited.has(neighbor) or not house.call("is_walkable_cell", neighbor):
				continue
			visited[neighbor] = true
			frontier.append(neighbor)
	return visited


func _fail(message: String) -> void:
	push_error("HOUSE_LAYOUT_SMOKE_FAILED: %s" % message)
	quit(1)
