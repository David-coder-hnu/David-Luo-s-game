extends SceneTree

const ACTION_KEYS := {
	"move_up": [KEY_W, KEY_UP],
	"move_down": [KEY_S, KEY_DOWN],
	"move_left": [KEY_A, KEY_LEFT],
	"move_right": [KEY_D, KEY_RIGHT],
	"interact": [KEY_E, KEY_ENTER],
	"cancel": [KEY_ESCAPE],
	"step_large": [KEY_SHIFT],
	"dev_panel": [KEY_F10],
}


func _initialize() -> void:
	ProjectSettings.set_setting("application/config/name", "地狱轮回")
	ProjectSettings.set_setting("application/run/main_scene", "res://scenes/main/main.tscn")
	ProjectSettings.set_setting("display/window/size/viewport_width", 640)
	ProjectSettings.set_setting("display/window/size/viewport_height", 360)
	ProjectSettings.set_setting("display/window/size/window_width_override", 1280)
	ProjectSettings.set_setting("display/window/size/window_height_override", 720)
	ProjectSettings.set_setting("display/window/stretch/mode", "canvas_items")
	ProjectSettings.set_setting("display/window/stretch/aspect", "keep")
	ProjectSettings.set_setting("display/window/stretch/scale_mode", "integer")
	ProjectSettings.set_setting("rendering/renderer/rendering_method", "gl_compatibility")
	ProjectSettings.set_setting("rendering/renderer/rendering_method.mobile", "gl_compatibility")
	ProjectSettings.set_setting("rendering/textures/default_filters/use_nearest_mipmap_filter", false)
	ProjectSettings.set_setting("rendering/textures/canvas_textures/default_texture_filter", 0)
	ProjectSettings.set_setting("rendering/2d/snap/snap_2d_transforms_to_pixel", true)
	ProjectSettings.set_setting("rendering/2d/snap/snap_2d_vertices_to_pixel", true)
	ProjectSettings.set_setting("audio/driver/enable_input", false)
	ProjectSettings.set_setting("autoload/Settings", "*res://scripts/autoload/settings.gd")
	ProjectSettings.set_setting("autoload/GameState", "*res://scripts/autoload/game_state.gd")
	ProjectSettings.set_setting("autoload/TextCatalog", "*res://scripts/autoload/text_catalog.gd")
	ProjectSettings.set_setting("autoload/DialogueController", "*res://scripts/autoload/dialogue_controller.gd")

	for action_name: String in ACTION_KEYS:
		var events: Array[InputEvent] = []
		for physical_keycode: Key in ACTION_KEYS[action_name]:
			var event := InputEventKey.new()
			event.physical_keycode = physical_keycode
			events.append(event)
		ProjectSettings.set_setting(
			"input/%s" % action_name,
			{"deadzone": 0.5, "events": events},
		)

	var save_error := ProjectSettings.save()
	if save_error != OK:
		push_error("Unable to save project settings: %s" % error_string(save_error))
		quit(1)
		return

	print("PROJECT_CONFIGURATION_OK")
	quit()
