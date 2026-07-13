extends Node

const DEFAULT_LOCALE_PATH := "res://data/localization/zh_CN.json"

var _entries: Dictionary = {}


func _ready() -> void:
	_load_catalog(DEFAULT_LOCALE_PATH)


func get_text(key: StringName) -> String:
	var string_key := String(key)
	if _entries.has(string_key):
		return String(_entries[string_key])
	push_warning("Missing localization key: %s" % string_key)
	return "[%s]" % string_key


func has_key(key: StringName) -> bool:
	return _entries.has(String(key))


func _load_catalog(path: String) -> void:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Unable to open localization catalog: %s" % path)
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		push_error("Localization catalog must be a JSON object: %s" % path)
		return
	_entries = parsed
