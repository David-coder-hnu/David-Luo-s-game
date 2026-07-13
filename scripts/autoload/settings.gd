extends Node

signal settings_changed(key: StringName, value: Variant)

const SCHEMA_VERSION := 1
const DEFAULT_MASTER_VOLUME := 0.7
const DEFAULT_FULLSCREEN := false
const DEFAULT_REDUCE_FLASHES := false

var storage_path := "user://settings.json"
var master_volume := DEFAULT_MASTER_VOLUME
var fullscreen := DEFAULT_FULLSCREEN
var reduce_flashes := DEFAULT_REDUCE_FLASHES


func _ready() -> void:
	load_settings()


func load_settings() -> void:
	var loaded := _read_valid_settings()
	if loaded.is_empty():
		_reset_to_defaults()
		_save_settings()
	else:
		master_volume = loaded["master_volume"]
		fullscreen = loaded["fullscreen"]
		reduce_flashes = loaded["reduce_flashes"]
	_apply_all()


func set_master_volume(value: float, persist := true) -> void:
	var normalized := clampf(value, 0.0, 1.0)
	if is_equal_approx(master_volume, normalized):
		return
	master_volume = normalized
	_apply_master_volume()
	settings_changed.emit(&"master_volume", master_volume)
	if persist:
		_save_settings()


func set_fullscreen(value: bool, persist := true) -> void:
	if fullscreen == value:
		return
	fullscreen = value
	_apply_fullscreen()
	settings_changed.emit(&"fullscreen", fullscreen)
	if persist:
		_save_settings()


func set_reduce_flashes(value: bool, persist := true) -> void:
	if reduce_flashes == value:
		return
	reduce_flashes = value
	settings_changed.emit(&"reduce_flashes", reduce_flashes)
	if persist:
		_save_settings()


func snapshot() -> Dictionary:
	return {
		"schema_version": SCHEMA_VERSION,
		"master_volume": master_volume,
		"fullscreen": fullscreen,
		"reduce_flashes": reduce_flashes,
	}


func _read_valid_settings() -> Dictionary:
	if not FileAccess.file_exists(storage_path):
		return {}
	var file := FileAccess.open(storage_path, FileAccess.READ)
	if file == null:
		return {}
	var json := JSON.new()
	if json.parse(file.get_as_text()) != OK:
		return {}
	var parsed: Variant = json.data
	if not parsed is Dictionary:
		return {}
	var data := parsed as Dictionary
	if data.get("schema_version") is not float and data.get("schema_version") is not int:
		return {}
	if int(data.get("schema_version")) != SCHEMA_VERSION:
		return {}
	if data.get("master_volume") is not float and data.get("master_volume") is not int:
		return {}
	if data.get("fullscreen") is not bool or data.get("reduce_flashes") is not bool:
		return {}
	var volume := float(data.get("master_volume"))
	if volume < 0.0 or volume > 1.0:
		return {}
	return {
		"master_volume": volume,
		"fullscreen": bool(data.get("fullscreen")),
		"reduce_flashes": bool(data.get("reduce_flashes")),
	}


func _reset_to_defaults() -> void:
	master_volume = DEFAULT_MASTER_VOLUME
	fullscreen = DEFAULT_FULLSCREEN
	reduce_flashes = DEFAULT_REDUCE_FLASHES


func _save_settings() -> void:
	var file := FileAccess.open(storage_path, FileAccess.WRITE)
	if file == null:
		push_error("Unable to write settings: %s" % storage_path)
		return
	file.store_string(JSON.stringify(snapshot(), "\t"))


func _apply_all() -> void:
	_apply_master_volume()
	_apply_fullscreen()


func _apply_master_volume() -> void:
	var master_bus := AudioServer.get_bus_index("Master")
	if master_bus < 0:
		return
	AudioServer.set_bus_mute(master_bus, master_volume <= 0.0)
	AudioServer.set_bus_volume_db(master_bus, linear_to_db(maxf(master_volume, 0.0001)))


func _apply_fullscreen() -> void:
	if DisplayServer.get_name() == "headless":
		return
	if not fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	elif OS.get_name() == "Windows":
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
