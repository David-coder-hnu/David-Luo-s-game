extends Node

signal dialogue_started(dialogue_id: StringName)
signal page_presented(dialogue_id: StringName, text_key: StringName, visible_characters: int, complete: bool, page_index: int, page_count: int)
signal dialogue_finished(dialogue_id: StringName)

const DIALOGUE_PATH := "res://data/dialogue/dialogues.json"
const CHARACTER_INTERVAL := 0.035
const PUNCTUATION_DELAY := 0.12
const INPUT_GUARD_MS := 100

var _definitions: Dictionary = {}
var _dialogue_id: StringName = &""
var _pages: Array = []
var _page_index := 0
var _visible_characters := 0
var _page_complete := false
var _page_started_msec := 0
var _elapsed := 0.0
var _next_character_delay := CHARACTER_INTERVAL


func _ready() -> void:
	_load_definitions()
	set_process(false)


func _process(delta: float) -> void:
	if not is_active() or _page_complete:
		return
	_elapsed += delta
	if _elapsed < _next_character_delay:
		return
	_elapsed -= _next_character_delay
	_visible_characters += 1
	var text := _current_text()
	if _visible_characters >= text.length():
		_visible_characters = text.length()
		_page_complete = true
		set_process(false)
	else:
		var revealed := text.substr(_visible_characters - 1, 1)
		_next_character_delay = PUNCTUATION_DELAY if revealed in ["。", "，", "！", "？", "；"] else CHARACTER_INTERVAL
	_emit_page()


func _unhandled_input(event: InputEvent) -> void:
	if is_active() and event.is_action_pressed("interact"):
		advance()
		get_viewport().set_input_as_handled()


func start_dialogue(dialogue_id: StringName) -> bool:
	if is_active() or not _definitions.has(String(dialogue_id)):
		return false
	var definition: Dictionary = _definitions[String(dialogue_id)]
	if not definition.has("pages") or not definition["pages"] is Array or definition["pages"].is_empty():
		return false
	_dialogue_id = dialogue_id
	_pages = definition["pages"]
	_page_index = 0
	dialogue_started.emit(_dialogue_id)
	_present_page()
	return true


func advance() -> StringName:
	if not is_active():
		return &"inactive"
	var page: Dictionary = _pages[_page_index]
	if Time.get_ticks_msec() - _page_started_msec < INPUT_GUARD_MS:
		return &"blocked"
	if not _page_complete:
		if not bool(page.get("skippable", true)):
			return &"blocked"
		_visible_characters = _current_text().length()
		_page_complete = true
		set_process(false)
		_emit_page()
		return &"revealed"
	if Time.get_ticks_msec() - _page_started_msec < int(page.get("min_display_ms", 0)):
		return &"blocked"
	if _page_index + 1 < _pages.size():
		_page_index += 1
		_present_page()
		return &"page"
	_finish()
	return &"finished"


func is_active() -> bool:
	return not _dialogue_id.is_empty()


func is_current_page_complete() -> bool:
	return _page_complete


func current_page_index() -> int:
	return _page_index


func current_page_count() -> int:
	return _pages.size()


func _present_page() -> void:
	_visible_characters = 0
	_page_complete = _current_text().is_empty()
	_page_started_msec = Time.get_ticks_msec()
	_elapsed = 0.0
	_next_character_delay = CHARACTER_INTERVAL
	set_process(not _page_complete)
	_emit_page()


func _current_text() -> String:
	if not is_active() or _page_index < 0 or _page_index >= _pages.size():
		return ""
	return TextCatalog.get_text(StringName(_pages[_page_index].get("text_key", "")))


func _emit_page() -> void:
	var page: Dictionary = _pages[_page_index]
	page_presented.emit(
		_dialogue_id,
		StringName(page.get("text_key", "")),
		_visible_characters,
		_page_complete,
		_page_index,
		_pages.size(),
	)


func _finish() -> void:
	var finished_id := _dialogue_id
	_dialogue_id = &""
	_pages = []
	_page_index = 0
	_visible_characters = 0
	_page_complete = false
	set_process(false)
	dialogue_finished.emit(finished_id)


func _load_definitions() -> void:
	var file := FileAccess.open(DIALOGUE_PATH, FileAccess.READ)
	if file == null:
		push_error("Unable to open dialogue definitions: %s" % DIALOGUE_PATH)
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary or not parsed.has("dialogues") or not parsed["dialogues"] is Dictionary:
		push_error("Dialogue definitions must contain a dialogues object")
		return
	_definitions = parsed["dialogues"]
