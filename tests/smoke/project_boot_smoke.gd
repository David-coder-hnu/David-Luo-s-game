extends SceneTree

const REQUIRED_ACTIONS := [
	"move_up",
	"move_down",
	"move_left",
	"move_right",
	"interact",
	"cancel",
	"step_large",
	"dev_panel",
]


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	if ProjectSettings.get_setting("display/window/size/viewport_width") != 640:
		_fail("viewport width is not 640")
		return
	if ProjectSettings.get_setting("display/window/size/viewport_height") != 360:
		_fail("viewport height is not 360")
		return
	if ProjectSettings.get_setting("display/window/stretch/scale_mode") != "integer":
		_fail("stretch scale mode is not integer")
		return
	for autoload_name: String in ["Settings", "GameState", "TextCatalog", "DialogueController"]:
		if not String(ProjectSettings.get_setting("autoload/%s" % autoload_name, "")).begins_with("*"):
			_fail("autoload is not configured: %s" % autoload_name)
			return

	for action_name: String in REQUIRED_ACTIONS:
		if not InputMap.has_action(action_name):
			_fail("missing input action: %s" % action_name)
			return
		if InputMap.action_get_events(action_name).is_empty():
			_fail("input action has no events: %s" % action_name)
			return

	var main_scene := load("res://scenes/main/main.tscn") as PackedScene
	if main_scene == null:
		_fail("main scene could not be loaded")
		return
	var main_instance := main_scene.instantiate()
	if main_instance.name != "Main":
		_fail("main scene root is not Main")
		return
	main_instance.free()

	print("F01_SMOKE_OK")
	quit()


func _fail(message: String) -> void:
	push_error("F01_SMOKE_FAILED: %s" % message)
	quit(1)
