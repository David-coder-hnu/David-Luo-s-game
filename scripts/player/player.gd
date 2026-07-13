extends CharacterBody2D

signal interaction_changed(prompt_key: StringName)

const SPEED := 96.0
const INTERACTION_DISTANCE := 48.0
const SPRITESHEET := preload("res://assets/game/characters/qin_zheng_spritesheet.png")
const DIRECTION_ROWS := {
	"down": 0,
	"up": 1,
	"left": 2,
	"right": 3,
}

@onready var sprite: AnimatedSprite2D = $Sprite

var control_enabled := true
var facing := Vector2.DOWN
var current_target: Area2D
var _last_prompt: StringName = &""


func _ready() -> void:
	_build_animations()
	_set_animation("down", false)


func _physics_process(_delta: float) -> void:
	var input_vector := Vector2.ZERO
	if control_enabled:
		input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_vector.normalized() * SPEED
	if not input_vector.is_zero_approx():
		facing = input_vector.normalized()
		_set_animation(_facing_name(), true)
	else:
		_set_animation(_facing_name(), false)
	move_and_slide()
	_select_interaction()
	if control_enabled and Input.is_action_just_pressed("interact") and current_target != null:
		current_target.call("interact")


func set_control_enabled(value: bool) -> void:
	control_enabled = value
	if not value:
		velocity = Vector2.ZERO


func set_facing(value: Vector2) -> void:
	facing = value.normalized()
	_set_animation(_facing_name(), false)


func _build_animations() -> void:
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")
	for direction: String in DIRECTION_ROWS:
		frames.add_animation(direction)
		frames.set_animation_loop(direction, true)
		frames.set_animation_speed(direction, 8.0)
		for column in 4:
			var frame := AtlasTexture.new()
			frame.atlas = SPRITESHEET
			frame.region = Rect2(column * 32, DIRECTION_ROWS[direction] * 48, 32, 48)
			frames.add_frame(direction, frame)
	sprite.sprite_frames = frames


func _set_animation(direction: String, moving: bool) -> void:
	if sprite.animation != direction:
		sprite.play(direction)
	if moving:
		if not sprite.is_playing():
			sprite.play(direction)
	else:
		sprite.pause()
		sprite.frame = 0


func _facing_name() -> String:
	if absf(facing.x) > absf(facing.y):
		return "right" if facing.x > 0.0 else "left"
	return "down" if facing.y > 0.0 else "up"


func _select_interaction() -> void:
	var best_target: Area2D
	var best_front := -1.0
	var best_distance := INF
	var best_id := ""
	for node: Node in get_tree().get_nodes_in_group(&"interactable"):
		var candidate := node as Area2D
		if candidate == null:
			continue
		var offset := candidate.global_position - global_position
		var distance := offset.length()
		if distance > INTERACTION_DISTANCE:
			continue
		var front := facing.dot(offset.normalized())
		var candidate_id := String(candidate.get("interaction_id"))
		if front > best_front + 0.001 or (
			is_equal_approx(front, best_front) and (
				distance < best_distance - 0.001 or (
					is_equal_approx(distance, best_distance) and candidate_id < best_id
				)
			)
		):
			best_target = candidate
			best_front = front
			best_distance = distance
			best_id = candidate_id
	current_target = best_target
	var next_prompt: StringName = &""
	if current_target != null:
		next_prompt = current_target.get("prompt_key")
	if next_prompt != _last_prompt:
		_last_prompt = next_prompt
		interaction_changed.emit(next_prompt)
