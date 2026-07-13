extends CanvasLayer

signal dialogue_closed

@onready var prompt_panel: PanelContainer = $PromptPanel
@onready var prompt: Label = $PromptPanel/Prompt
@onready var dialogue_panel: PanelContainer = $DialoguePanel
@onready var dialogue_text: Label = $DialoguePanel/Margin/Text
@onready var room_tag: Label = $RoomTag

var dialogue_open := false


func _ready() -> void:
	_apply_styles()
	room_tag.text = TextCatalog.get_text(&"ui.phase.loop1_bedroom")


func _unhandled_input(event: InputEvent) -> void:
	if dialogue_open and event.is_action_pressed("interact"):
		close_dialogue()
		get_viewport().set_input_as_handled()


func set_prompt(text_key: StringName) -> void:
	prompt.text = TextCatalog.get_text(text_key) if not text_key.is_empty() else ""
	prompt_panel.visible = not text_key.is_empty() and not dialogue_open


func show_dialogue(text_key: StringName) -> void:
	dialogue_text.text = TextCatalog.get_text(text_key)
	dialogue_panel.visible = true
	prompt_panel.visible = false
	dialogue_open = true


func close_dialogue() -> void:
	dialogue_panel.visible = false
	dialogue_open = false
	dialogue_closed.emit()


func _apply_styles() -> void:
	var prompt_style := StyleBoxFlat.new()
	prompt_style.bg_color = Color("151923e8")
	prompt_style.border_color = Color("52666c")
	prompt_style.set_border_width_all(1)
	prompt_style.corner_radius_top_left = 2
	prompt_style.corner_radius_top_right = 2
	prompt_style.corner_radius_bottom_left = 2
	prompt_style.corner_radius_bottom_right = 2
	prompt_panel.add_theme_stylebox_override("panel", prompt_style)

	var dialogue_style := StyleBoxFlat.new()
	dialogue_style.bg_color = Color("0b0c14f2")
	dialogue_style.border_color = Color("40525a")
	dialogue_style.set_border_width_all(2)
	dialogue_style.set_corner_radius_all(2)
	dialogue_panel.add_theme_stylebox_override("panel", dialogue_style)
