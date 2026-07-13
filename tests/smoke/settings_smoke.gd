extends SceneTree

const SETTINGS_SCRIPT := preload("res://scripts/autoload/settings.gd")
const TEST_PATH := "user://settings_smoke_test.json"


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_remove_test_file()
	var settings := SETTINGS_SCRIPT.new()
	settings.storage_path = TEST_PATH
	settings.load_settings()
	if not is_equal_approx(settings.master_volume, 0.7) or settings.fullscreen or settings.reduce_flashes:
		_fail("missing file did not produce defaults")
		return
	settings.set_master_volume(0.35)
	settings.set_fullscreen(true)
	settings.set_reduce_flashes(true)

	var reloaded := SETTINGS_SCRIPT.new()
	reloaded.storage_path = TEST_PATH
	reloaded.load_settings()
	if not is_equal_approx(reloaded.master_volume, 0.35) or not reloaded.fullscreen or not reloaded.reduce_flashes:
		_fail("valid settings did not survive reload")
		return

	var corrupt := FileAccess.open(TEST_PATH, FileAccess.WRITE)
	corrupt.store_string("{broken")
	corrupt = null
	reloaded.load_settings()
	if not is_equal_approx(reloaded.master_volume, 0.7) or reloaded.fullscreen or reloaded.reduce_flashes:
		_fail("corrupt settings did not recover to defaults")
		return
	if not FileAccess.file_exists(TEST_PATH):
		_fail("recovered defaults were not rewritten")
		return

	settings.free()
	reloaded.free()
	_remove_test_file()
	print("SETTINGS_SMOKE_OK")
	quit()


func _remove_test_file() -> void:
	if FileAccess.file_exists(TEST_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_PATH))


func _fail(message: String) -> void:
	_remove_test_file()
	push_error("SETTINGS_SMOKE_FAILED: %s" % message)
	quit(1)
