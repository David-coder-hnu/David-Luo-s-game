extends Node2D

const ENVIRONMENT_ATLAS := preload("res://assets/game/atlases/environment_tiles.png")
const PROPS_ATLAS := preload("res://assets/game/atlases/props_atlas.png")
const V3_ROOM_TEXTURES := {
	&"bedroom": {0: preload("res://assets/game/generated_v3/runtime/rooms/bedroom_loop1.png")},
	&"hallway": {0: preload("res://assets/game/generated_v3/runtime/rooms/hallway_loop1.png")},
	&"kitchen": {
		0: preload("res://assets/game/generated_v3/runtime/rooms/kitchen_loop1.png"),
		1: preload("res://assets/game/generated_v3/runtime/rooms/kitchen_loop2.png"),
	},
	&"child_room": {
		0: preload("res://assets/game/generated_v3/runtime/rooms/child_room_loop1.png"),
		1: preload("res://assets/game/generated_v3/runtime/rooms/child_room_loop2.png"),
	},
	&"living_room": {0: preload("res://assets/game/generated_v3/runtime/rooms/living_room_loop1.png")},
}
const INTERACTABLE_SCRIPT := preload("res://scripts/world/interactable.gd")
const FRAGMENT_DATA_PATH := "res://data/fragments/fragments.json"

const TILE_SIZE := 32
const MAP_SIZE := Vector2i(50, 38)
const VIEWPORT_SIZE := Vector2(640, 360)
const ROOM_RECTS := {
	&"bedroom": Rect2(20 * TILE_SIZE, 2 * TILE_SIZE, 10 * TILE_SIZE, 9 * TILE_SIZE),
	&"hallway": Rect2(18 * TILE_SIZE, 11 * TILE_SIZE, 14 * TILE_SIZE, 11 * TILE_SIZE),
	&"kitchen": Rect2(2 * TILE_SIZE, 11 * TILE_SIZE, 16 * TILE_SIZE, 11 * TILE_SIZE),
	&"child_room": Rect2(32 * TILE_SIZE, 11 * TILE_SIZE, 16 * TILE_SIZE, 11 * TILE_SIZE),
	&"living_room": Rect2(14 * TILE_SIZE, 22 * TILE_SIZE, 22 * TILE_SIZE, 14 * TILE_SIZE),
}
const ROOM_CAMERA_CENTERS := {
	&"bedroom": Vector2(800, 240),
	&"hallway": Vector2(800, 528),
	&"kitchen": Vector2(320, 528),
	&"child_room": Vector2(1280, 528),
	&"living_room": Vector2(800, 928),
}
const CHILD_DRAWING_POSITIONS := {
	0: Vector2(1120, 608),
	1: Vector2(1184, 608),
}

@onready var tiles: TileMapLayer = $Tiles
@onready var room_backgrounds: Node2D = $RoomBackgrounds
@onready var props_back: Node2D = $PropsBack
@onready var props_front: Node2D = $PropsFront
@onready var solids: Node2D = $Solids
@onready var player: CharacterBody2D = $Player
@onready var room_camera: Camera2D = $RoomCamera
@onready var hud: CanvasLayer = $GameHUD

var _atlas_source_id := -1
var _active_interactable: Interactable
var _wall_cells: Dictionary = {}
var _walkable_cells: Dictionary = {}
var _current_room_id: StringName = &"bedroom"
var _fragment_definitions: Dictionary = {}
var _pending_fragment_id: StringName = &""
var _room_background_sprites: Dictionary = {}


func _ready() -> void:
	if GameState.snapshot_for_debug()["phase"] == &"title":
		GameState.start_new_game()
	_build_tile_map()
	_build_v3_backgrounds()
	_build_props()
	_load_fragment_definitions()
	_build_fragment_interactions()
	_build_collisions()
	GameState.phase_changed.connect(_on_phase_changed)
	player.interaction_changed.connect(_on_interaction_changed)
	hud.dialogue_closed.connect(_on_dialogue_closed)
	print("HELL_CYCLE_PLAYABLE_OK")
	var capture_path := _capture_path_from_args()
	if not capture_path.is_empty():
		_prepare_capture_phase(_capture_phase_from_args())
		_place_player_for_capture(_capture_room_from_args())
		_capture_runtime.call_deferred(capture_path)


func _process(_delta: float) -> void:
	room_camera.position = camera_target_for_position(player.global_position).round()
	var room_id := room_id_for_position(player.global_position)
	if not room_id.is_empty() and room_id != _current_room_id:
		_current_room_id = room_id
		_set_active_v3_background(room_id)
		hud.set_room(room_id)
		GameState.record_room_entry(room_id)


func _build_tile_map() -> void:
	var tile_set := TileSet.new()
	tile_set.tile_size = Vector2i(TILE_SIZE, TILE_SIZE)
	var source := TileSetAtlasSource.new()
	source.texture = ENVIRONMENT_ATLAS
	source.texture_region_size = Vector2i(TILE_SIZE, TILE_SIZE)
	for atlas_y in 2:
		for atlas_x in 10:
			source.create_tile(Vector2i(atlas_x, atlas_y))
	_atlas_source_id = tile_set.add_source(source)
	tiles.tile_set = tile_set

	_build_room(Rect2i(20, 2, 10, 9), &"wood", [Vector2i(24, 10), Vector2i(25, 10)])
	_build_room(
		Rect2i(18, 11, 14, 11),
		&"hall",
		[
			Vector2i(24, 11), Vector2i(25, 11),
			Vector2i(18, 15), Vector2i(18, 16),
			Vector2i(31, 15), Vector2i(31, 16),
			Vector2i(24, 21), Vector2i(25, 21),
		],
	)
	_build_room(Rect2i(2, 11, 16, 11), &"kitchen", [Vector2i(17, 15), Vector2i(17, 16)])
	_build_room(Rect2i(32, 11, 16, 11), &"wood", [Vector2i(32, 15), Vector2i(32, 16)])
	_build_room(Rect2i(14, 22, 22, 14), &"living", [Vector2i(24, 22), Vector2i(25, 22)])


func _build_v3_backgrounds() -> void:
	for room_id: StringName in V3_ROOM_TEXTURES:
		var sprite := Sprite2D.new()
		sprite.name = "%sV3" % String(room_id).to_pascal_case()
		sprite.texture = _v3_texture_for_room(room_id)
		sprite.position = ROOM_CAMERA_CENTERS[room_id]
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		sprite.visible = room_id == _current_room_id
		room_backgrounds.add_child(sprite)
		_room_background_sprites[room_id] = sprite


func _set_active_v3_background(room_id: StringName) -> void:
	for candidate_id: StringName in _room_background_sprites:
		(_room_background_sprites[candidate_id] as Sprite2D).visible = candidate_id == room_id


func _v3_texture_for_room(room_id: StringName) -> Texture2D:
	var variants: Dictionary = V3_ROOM_TEXTURES[room_id]
	var cycle_index: int = GameState.snapshot_for_debug()["cycle_index"]
	return variants.get(cycle_index, variants[0]) as Texture2D


func _refresh_v3_background_textures() -> void:
	for room_id: StringName in _room_background_sprites:
		(_room_background_sprites[room_id] as Sprite2D).texture = _v3_texture_for_room(room_id)


func _on_phase_changed(_from: StringName, _to: StringName) -> void:
	_refresh_v3_background_textures()
	_apply_cycle_interaction_positions()


func _build_room(rect: Rect2i, floor_type: StringName, openings: Array) -> void:
	for y in range(rect.position.y + 1, rect.end.y - 1):
		for x in range(rect.position.x + 1, rect.end.x - 1):
			_set_floor(Vector2i(x, y), floor_type)
	for x in range(rect.position.x, rect.end.x):
		_set_boundary_cell(Vector2i(x, rect.position.y), floor_type, openings, Vector2i(posmod(x + rect.position.y, 4), 1))
		_set_boundary_cell(Vector2i(x, rect.end.y - 1), floor_type, openings, Vector2i(posmod(x + rect.end.y - 1, 4), 1))
	for y in range(rect.position.y + 1, rect.end.y - 1):
		_set_boundary_cell(Vector2i(rect.position.x, y), floor_type, openings, Vector2i(6, 1))
		_set_boundary_cell(Vector2i(rect.end.x - 1, y), floor_type, openings, Vector2i(7, 1))


func _set_boundary_cell(cell: Vector2i, floor_type: StringName, openings: Array, wall_atlas: Vector2i) -> void:
	if cell in openings:
		_set_floor(cell, floor_type)
		return
	_set_wall(cell, wall_atlas)


func _set_floor(cell: Vector2i, floor_type: StringName) -> void:
	var atlas := Vector2i(posmod(cell.x + cell.y, 4), 0)
	if floor_type == &"kitchen":
		atlas.x += 4
	tiles.set_cell(cell, _atlas_source_id, atlas)
	_walkable_cells[cell] = true
	_wall_cells.erase(cell)


func _set_wall(cell: Vector2i, atlas: Vector2i) -> void:
	tiles.set_cell(cell, _atlas_source_id, atlas)
	_wall_cells[cell] = true
	_walkable_cells.erase(cell)


func _build_props() -> void:
	# Bedroom: the first playable teaching composition.
	_add_prop(props_back, "bedroom_rug", Rect2(576, 128, 128, 64), Vector2(800, 230), -1)
	_add_prop(props_back, "bed", Rect2(0, 0, 96, 64), Vector2(704, 160), 0)
	_add_prop(props_back, "bedside_table", Rect2(192, 0, 32, 32), Vector2(768, 176), 1)
	_add_prop(props_back, "wardrobe", Rect2(224, 0, 64, 64), Vector2(896, 144), 0)
	_add_prop(props_back, "bedroom_window", Rect2(736, 128, 96, 64), Vector2(816, 112), 0)
	_add_prop(props_front, "bedroom_lamp", Rect2(704, 128, 32, 32), Vector2(768, 148), 2)
	_add_prop(props_front, "doorway_bedroom", Rect2(192, 64, 64, 64), Vector2(800, 336), 3, ENVIRONMENT_ATLAS)

	# Hallway: balanced directional anchors and the sealed exit.
	_add_prop(props_back, "exit_door", Rect2(512, 128, 64, 96), Vector2(992, 400), 0)
	_add_prop(props_back, "light_hall_north", Rect2(448, 128, 32, 32), Vector2(800, 416), 1)
	_add_prop(props_back, "light_hall_south", Rect2(448, 128, 32, 32), Vector2(800, 624), 1)
	_add_prop(props_front, "doorway_kitchen", Rect2(192, 64, 64, 64), Vector2(576, 512), 2, ENVIRONMENT_ATLAS)
	_add_prop(props_front, "doorway_child", Rect2(192, 64, 64, 64), Vector2(1024, 512), 2, ENVIRONMENT_ATLAS)
	_add_prop(props_front, "doorway_living", Rect2(192, 64, 64, 64), Vector2(800, 704), 2, ENVIRONMENT_ATLAS)

	# Kitchen: stain, glass and receipt remain distinct visual targets.
	_add_prop(props_back, "kitchen_counter", Rect2(352, 0, 192, 64), Vector2(320, 416), 0)
	_add_prop(props_back, "kitchen_stain", Rect2(608, 0, 64, 32), Vector2(288, 592), -1)
	_add_prop(props_back, "kitchen_glass", Rect2(544, 0, 32, 32), Vector2(400, 480), 1)
	_add_prop(props_back, "kitchen_receipt", Rect2(672, 0, 32, 32), Vector2(240, 608), 1)
	_add_prop(props_back, "light_kitchen", Rect2(448, 128, 32, 32), Vector2(448, 448), 1)

	# Child's room: the drawing is visible from a generous bed-side approach.
	_add_prop(props_back, "child_bed", Rect2(0, 64, 96, 64), Vector2(1120, 480), 0)
	_add_prop(props_back, "height_marks", Rect2(192, 64, 32, 64), Vector2(1472, 448), 0)
	_add_prop(props_back, "music_box", Rect2(224, 64, 32, 32), Vector2(1344, 480), 1)
	_add_prop(props_back, "child_drawing", Rect2(256, 64, 32, 32), Vector2(1120, 608), 1)
	_add_prop(props_back, "light_child", Rect2(448, 128, 32, 32), Vector2(1216, 448), 1)

	# Living room: family layout first, clock left, photograph right.
	_add_prop(props_back, "sofa", Rect2(0, 128, 96, 64), Vector2(560, 816), 0)
	_add_prop(props_back, "family_table", Rect2(96, 128, 96, 96), Vector2(800, 896), 0)
	_add_prop(props_back, "living_clock", Rect2(256, 128, 32, 64), Vector2(576, 800), 1)
	_add_prop(props_back, "memory_compartment", Rect2(288, 128, 64, 64), Vector2(640, 800), 0)
	_add_prop(props_back, "wedding_photo", Rect2(192, 128, 32, 32), Vector2(1008, 880), 1)
	_add_prop(props_back, "light_living", Rect2(448, 128, 32, 32), Vector2(896, 800), 1)

	_add_interaction(&"bed", Vector2(752, 176), &"bedroom.bed.loop1")
	_add_interaction(&"exit_door", Vector2(800, 296), &"bedroom.door.loop1")


func _load_fragment_definitions() -> void:
	var file := FileAccess.open(FRAGMENT_DATA_PATH, FileAccess.READ)
	if file == null:
		push_error("Unable to open fragment definitions: %s" % FRAGMENT_DATA_PATH)
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary or not parsed.has("fragments") or not parsed["fragments"] is Array:
		push_error("Fragment definitions must contain a fragments array")
		return
	for definition: Dictionary in parsed["fragments"]:
		var fragment_id := StringName(definition.get("id", ""))
		if fragment_id in GameState.FRAGMENT_IDS:
			_fragment_definitions[fragment_id] = definition


func _build_fragment_interactions() -> void:
	var cycle_index: int = GameState.snapshot_for_debug()["cycle_index"]
	var positions := {
		&"kitchen_receipt": Vector2(240, 608),
		&"child_drawing": CHILD_DRAWING_POSITIONS.get(cycle_index, CHILD_DRAWING_POSITIONS[0]),
		&"wedding_photo": Vector2(1008, 880),
	}
	for fragment_id: StringName in positions:
		var definition: Dictionary = _fragment_definitions.get(fragment_id, {})
		if definition.is_empty():
			push_error("Missing fragment definition: %s" % fragment_id)
			continue
		_add_fragment_interaction(definition, positions[fragment_id])


func _apply_cycle_interaction_positions() -> void:
	var child_drawing := get_node_or_null("child_drawing") as Node2D
	if child_drawing == null:
		return
	var cycle_index: int = GameState.snapshot_for_debug()["cycle_index"]
	child_drawing.position = CHILD_DRAWING_POSITIONS.get(cycle_index, CHILD_DRAWING_POSITIONS[0])


func _build_collisions() -> void:
	for cell: Vector2i in _wall_cells:
		_add_solid(Rect2(Vector2(cell * TILE_SIZE), Vector2(TILE_SIZE, TILE_SIZE)))
	_add_solid(Rect2(656, 136, 96, 52))
	_add_solid(Rect2(864, 112, 64, 56))
	_add_solid(Rect2(224, 384, 192, 52))
	_add_solid(Rect2(1072, 456, 96, 48))
	_add_solid(Rect2(512, 792, 96, 48))
	_add_solid(Rect2(752, 856, 96, 72))


func is_walkable_cell(cell: Vector2i) -> bool:
	return _walkable_cells.has(cell) and not _wall_cells.has(cell)


func is_wall_cell(cell: Vector2i) -> bool:
	return _wall_cells.has(cell)


func map_size() -> Vector2i:
	return MAP_SIZE


func room_id_for_position(world_position: Vector2) -> StringName:
	for room_id: StringName in ROOM_RECTS:
		if (ROOM_RECTS[room_id] as Rect2).has_point(world_position):
			return room_id
	return &""


func camera_target_for_position(world_position: Vector2) -> Vector2:
	for room_id: StringName in ROOM_RECTS:
		var rect: Rect2 = ROOM_RECTS[room_id]
		if not rect.has_point(world_position):
			continue
		var target: Vector2 = ROOM_CAMERA_CENTERS[room_id]
		if rect.size.x > VIEWPORT_SIZE.x:
			target.x = clampf(world_position.x, rect.position.x + VIEWPORT_SIZE.x * 0.5, rect.end.x - VIEWPORT_SIZE.x * 0.5)
		if rect.size.y > VIEWPORT_SIZE.y:
			target.y = clampf(world_position.y, rect.position.y + VIEWPORT_SIZE.y * 0.5, rect.end.y - VIEWPORT_SIZE.y * 0.5)
		return target
	return Vector2(
		clampf(world_position.x, VIEWPORT_SIZE.x * 0.5, MAP_SIZE.x * TILE_SIZE - VIEWPORT_SIZE.x * 0.5),
		clampf(world_position.y, VIEWPORT_SIZE.y * 0.5, MAP_SIZE.y * TILE_SIZE - VIEWPORT_SIZE.y * 0.5),
	)


func _add_prop(parent: Node2D, id: String, region: Rect2, position_value: Vector2, z: int, atlas: Texture2D = PROPS_ATLAS) -> void:
	var sprite := Sprite2D.new()
	sprite.name = id
	var texture := AtlasTexture.new()
	texture.atlas = atlas
	texture.region = region
	texture.filter_clip = true
	sprite.texture = texture
	sprite.position = position_value
	sprite.z_index = z
	parent.add_child(sprite)


func _add_interaction(id: StringName, position_value: Vector2, dialogue_key: StringName) -> void:
	var area := INTERACTABLE_SCRIPT.new() as Interactable
	area.name = String(id)
	area.interaction_id = id
	area.dialogue_key = dialogue_key
	area.position = position_value
	area.add_to_group(&"interactable")
	var shape_node := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 8.0
	shape_node.shape = shape
	area.add_child(shape_node)
	area.activated.connect(_on_interaction_activated.bind(area))
	add_child(area)


func _add_fragment_interaction(definition: Dictionary, position_value: Vector2) -> void:
	var first_dialogues: Array = definition.get("dialogue_first", [])
	var repeat_loop_1: Array = definition.get("dialogue_repeat_loop_1", [])
	var repeat_loop_2: Array = definition.get("dialogue_repeat_loop_2", [])
	if first_dialogues.is_empty() or repeat_loop_1.is_empty() or repeat_loop_2.is_empty():
		push_error("Fragment dialogue sets are incomplete: %s" % definition.get("id", ""))
		return
	var area := INTERACTABLE_SCRIPT.new() as Interactable
	area.name = String(definition["interaction_id"])
	area.interaction_id = StringName(definition["interaction_id"])
	area.fragment_id = StringName(definition["id"])
	area.dialogue_first = StringName(first_dialogues[0])
	area.dialogue_repeat_loop_1 = StringName(repeat_loop_1[0])
	area.dialogue_repeat_loop_2 = StringName(repeat_loop_2[0])
	area.position = position_value
	area.add_to_group(&"interactable")
	var shape_node := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 8.0
	shape_node.shape = shape
	area.add_child(shape_node)
	area.activated.connect(_on_interaction_activated.bind(area))
	add_child(area)


func _add_solid(rect: Rect2) -> void:
	var body := StaticBody2D.new()
	body.collision_layer = 1
	body.collision_mask = 0
	var shape_node := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = rect.size
	shape_node.shape = shape
	shape_node.position = rect.position + rect.size * 0.5
	body.add_child(shape_node)
	solids.add_child(body)


func _on_interaction_changed(prompt_key: StringName) -> void:
	hud.set_prompt(prompt_key)


func _on_interaction_activated(_dialogue_key: StringName, interactable: Interactable) -> void:
	_active_interactable = interactable
	_pending_fragment_id = &""
	if not interactable.fragment_id.is_empty() and interactable.fragment_id not in GameState.snapshot_for_debug()["completed_fragments_sorted"]:
		_pending_fragment_id = interactable.fragment_id
	player.set_control_enabled(false)
	if not hud.show_dialogue(interactable.dialogue_key):
		_pending_fragment_id = &""
		interactable.release()
		_active_interactable = null
		player.set_control_enabled(true)


func _on_dialogue_closed() -> void:
	if not _pending_fragment_id.is_empty():
		GameState.complete_fragment(_pending_fragment_id)
	_pending_fragment_id = &""
	if _active_interactable != null:
		_active_interactable.release()
	_active_interactable = null
	player.set_control_enabled(true)


func _capture_path_from_args() -> String:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--capture-screenshot="):
			return argument.trim_prefix("--capture-screenshot=")
	return ""


func _capture_room_from_args() -> StringName:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--capture-room="):
			return StringName(argument.trim_prefix("--capture-room="))
	return &"bedroom"


func _capture_phase_from_args() -> StringName:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--capture-phase="):
			return StringName(argument.trim_prefix("--capture-phase="))
	return &"loop_1"


func _prepare_capture_phase(phase: StringName) -> void:
	if phase != GameState.PHASE_LOOP_2:
		return
	for fragment_id: StringName in GameState.FRAGMENT_IDS:
		GameState.complete_fragment(fragment_id)
	GameState.request_phase(GameState.PHASE_PUNISHMENT_1)
	GameState.request_phase(GameState.PHASE_LOOP_2)


func _place_player_for_capture(room_id: StringName) -> void:
	var positions := {
		&"bedroom": Vector2(796, 184),
		&"hallway": Vector2(800, 528),
		&"kitchen": Vector2(336, 544),
		&"child_room": Vector2(1312, 544),
		&"living_room": Vector2(800, 928),
	}
	player.global_position = positions.get(room_id, positions[&"bedroom"])
	player.set_facing(Vector2.LEFT if room_id == &"bedroom" else Vector2.DOWN)
	_current_room_id = room_id if room_id in ROOM_RECTS else &"bedroom"
	_set_active_v3_background(_current_room_id)
	hud.set_room(_current_room_id)


func _capture_runtime(path: String) -> void:
	for frame in 6:
		await get_tree().process_frame
	print("CAPTURE_METRICS viewport=%s window=%s camera=%s" % [get_viewport().get_visible_rect().size, get_window().size, room_camera.position])
	var image := get_viewport().get_texture().get_image()
	if image.get_size() != Vector2i(640, 360):
		image.resize(640, 360, Image.INTERPOLATE_NEAREST)
	var absolute_path := ProjectSettings.globalize_path(path)
	DirAccess.make_dir_recursive_absolute(absolute_path.get_base_dir())
	var error := image.save_png(absolute_path)
	if error != OK:
		push_error("Unable to save runtime screenshot: %s" % error_string(error))
		get_tree().quit(1)
		return
	print("RUNTIME_SCREENSHOT_OK 640x360 %s" % absolute_path)
	get_tree().quit()
