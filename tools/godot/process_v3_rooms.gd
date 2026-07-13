extends SceneTree

const OUTPUT_SIZE := Vector2i(640, 360)
const ROOMS := {
	"bedroom": {
		"source": "res://assets/game/generated_v3/rooms/bedroom_loop1_background.png",
		"flip_x": false,
	},
	"hallway": {
		"source": "res://assets/game/generated_v3/rooms/hallway_master.png",
		"flip_x": false,
	},
	"kitchen": {
		"source": "res://assets/game/generated_v3/rooms/kitchen_master.png",
		"flip_x": false,
	},
	"child_room": {
		"source": "res://assets/game/generated_v3/rooms/child_room_loop1_background_v2.png",
		"flip_x": false,
	},
	"living_room": {
		"source": "res://assets/game/generated_v3/rooms/living_room_loop1_background.png",
		"flip_x": false,
	},
}
const OUTPUT_DIRECTORY := "res://assets/game/generated_v3/runtime/rooms"


func _initialize() -> void:
	var absolute_output := ProjectSettings.globalize_path(OUTPUT_DIRECTORY)
	var directory_error := DirAccess.make_dir_recursive_absolute(absolute_output)
	if directory_error != OK:
		push_error("Unable to create V3 runtime room directory: %s" % error_string(directory_error))
		quit(1)
		return

	for room_id: String in ROOMS:
		var definition: Dictionary = ROOMS[room_id]
		var source_path: String = definition["source"]
		var image := Image.new()
		var load_error := image.load(ProjectSettings.globalize_path(source_path))
		if load_error != OK:
			push_error("Unable to load %s: %s" % [source_path, error_string(load_error)])
			quit(1)
			return
		if definition["flip_x"]:
			image.flip_x()
		image.resize(OUTPUT_SIZE.x, OUTPUT_SIZE.y, Image.INTERPOLATE_NEAREST)
		var output_path := "%s/%s_loop1.png" % [OUTPUT_DIRECTORY, room_id]
		var save_error := image.save_png(ProjectSettings.globalize_path(output_path))
		if save_error != OK:
			push_error("Unable to save %s: %s" % [output_path, error_string(save_error)])
			quit(1)
			return
		print("V3_ROOM_RUNTIME_OK %s 640x360 flip_x=%s" % [room_id, definition["flip_x"]])

	quit()
