extends Node2D

const ENVIRONMENT_ATLAS := preload("res://assets/game/atlases/environment_tiles.png")
const PROPS_ATLAS := preload("res://assets/game/atlases/props_atlas.png")
const INTERACTABLE_SCRIPT := preload("res://scripts/world/interactable.gd")

@onready var tiles: TileMapLayer = $Tiles
@onready var props_back: Node2D = $PropsBack
@onready var props_front: Node2D = $PropsFront
@onready var solids: Node2D = $Solids
@onready var player: CharacterBody2D = $Player
@onready var hud: CanvasLayer = $GameHUD

var _atlas_source_id := -1
var _active_interactable: Interactable


func _ready() -> void:
	_build_tile_map()
	_build_props()
	_build_collisions()
	player.interaction_changed.connect(_on_interaction_changed)
	hud.dialogue_closed.connect(_on_dialogue_closed)
	print("HELL_CYCLE_PLAYABLE_OK")
	var capture_path := _capture_path_from_args()
	if not capture_path.is_empty():
		player.global_position = Vector2(800, 192)
		player.set_facing(Vector2.LEFT)
		_capture_runtime.call_deferred(capture_path)


func _build_tile_map() -> void:
	var tile_set := TileSet.new()
	tile_set.tile_size = Vector2i(32, 32)
	var source := TileSetAtlasSource.new()
	source.texture = ENVIRONMENT_ATLAS
	source.texture_region_size = Vector2i(32, 32)
	for atlas_y in 2:
		for atlas_x in 10:
			source.create_tile(Vector2i(atlas_x, atlas_y))
	_atlas_source_id = tile_set.add_source(source)
	tiles.tile_set = tile_set

	for y in range(3, 10):
		for x in range(21, 29):
			tiles.set_cell(Vector2i(x, y), _atlas_source_id, Vector2i((x + y) % 4, 0))
	for x in range(20, 30):
		tiles.set_cell(Vector2i(x, 2), _atlas_source_id, Vector2i(x % 4, 1))
		if x < 24 or x > 25:
			tiles.set_cell(Vector2i(x, 10), _atlas_source_id, Vector2i((x + 1) % 4, 1))
	for y in range(3, 11):
		tiles.set_cell(Vector2i(20, y), _atlas_source_id, Vector2i(6, 1))
		tiles.set_cell(Vector2i(29, y), _atlas_source_id, Vector2i(7, 1))
	for y in range(10, 16):
		for x in range(24, 26):
			tiles.set_cell(Vector2i(x, y), _atlas_source_id, Vector2i((x + y) % 4, 0))
		tiles.set_cell(Vector2i(23, y), _atlas_source_id, Vector2i(6, 1))
		tiles.set_cell(Vector2i(26, y), _atlas_source_id, Vector2i(7, 1))


func _build_props() -> void:
	_add_prop(props_back, "bedroom_rug", Rect2(576, 128, 128, 64), Vector2(800, 230), -1)
	_add_prop(props_back, "bed", Rect2(0, 0, 96, 64), Vector2(704, 160), 0)
	_add_prop(props_back, "bedside_table", Rect2(192, 0, 32, 32), Vector2(768, 176), 1)
	_add_prop(props_back, "wardrobe", Rect2(224, 0, 64, 64), Vector2(896, 144), 0)
	_add_prop(props_back, "bedroom_window", Rect2(736, 128, 96, 64), Vector2(816, 112), 0)
	_add_prop(props_front, "bedroom_lamp", Rect2(704, 128, 32, 32), Vector2(768, 148), 2)
	_add_prop(props_front, "door_bedroom", Rect2(0, 64, 64, 64), Vector2(800, 336), 3, ENVIRONMENT_ATLAS)

	_add_interaction(&"bed", Vector2(752, 176), &"bedroom.bed.inspect")
	_add_interaction(&"bedside_table", Vector2(768, 176), &"bedroom.table.inspect")
	_add_interaction(&"bedroom_window", Vector2(816, 144), &"bedroom.window.inspect")


func _build_collisions() -> void:
	_add_solid(Rect2(640, 64, 320, 32))
	_add_solid(Rect2(640, 96, 32, 256))
	_add_solid(Rect2(928, 96, 32, 256))
	_add_solid(Rect2(640, 320, 128, 32))
	_add_solid(Rect2(832, 320, 128, 32))
	_add_solid(Rect2(736, 320, 32, 192))
	_add_solid(Rect2(832, 320, 32, 192))
	_add_solid(Rect2(656, 136, 96, 52))
	_add_solid(Rect2(864, 112, 64, 56))


func _add_prop(parent: Node2D, id: String, region: Rect2, position_value: Vector2, z: int, atlas: Texture2D = PROPS_ATLAS) -> void:
	var sprite := Sprite2D.new()
	sprite.name = id
	var texture := AtlasTexture.new()
	texture.atlas = atlas
	texture.region = region
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
	player.set_control_enabled(false)
	hud.show_dialogue(interactable.dialogue_key)


func _on_dialogue_closed() -> void:
	if _active_interactable != null:
		_active_interactable.release()
	_active_interactable = null
	player.set_control_enabled(true)


func _capture_path_from_args() -> String:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--capture-screenshot="):
			return argument.trim_prefix("--capture-screenshot=")
	return ""


func _capture_runtime(path: String) -> void:
	for frame in 6:
		await get_tree().process_frame
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
