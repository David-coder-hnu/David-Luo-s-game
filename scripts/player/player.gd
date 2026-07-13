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
var _interaction_blocked_until_msec := 0


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
	if control_enabled and Time.get_ticks_msec() >= _interaction_blocked_until_msec and Input.is_action_just_pressed("interact") and current_target != null:
		current_target.call("interact", {
			"player": self,
			"game_snapshot": GameState.snapshot_for_debug(),
		})


func set_control_enabled(value: bool) -> void:
	control_enabled = value
	if not value:
		velocity = Vector2.ZERO
	else:
		_interaction_blocked_until_msec = Time.get_ticks_msec() + 150


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
	var best_in_front := false
	var best_distance_squared := INF
	var best_id := ""
	var snapshot := GameState.snapshot_for_debug()
	for node: Node in get_tree().get_nodes_in_group(&"interactable"):
		var candidate := node as Area2D
		if candidate == null or not candidate.has_method("get_interaction_score") or not candidate.has_method("can_interact"):
			continue
		if not candidate.call("can_interact", snapshot):
			continue
		var score: Dictionary = candidate.call("get_interaction_score", global_position, facing)
		var distance_squared: float = score["distance_squared"]
		if distance_squared > INTERACTION_DISTANCE * INTERACTION_DISTANCE:
			continue
		var in_front: bool = score["in_front"]
		var candidate_id := String(score["interaction_id"])
		if (in_front and not best_in_front) or (
			in_front == best_in_front and (
				distance_squared < best_distance_squared - 0.001 or (
					is_equal_approx(distance_squared, best_distance_squared) and candidate_id < best_id
				)
			)
		):
			best_target = candidate
			best_in_front = in_front
			best_distance_squared = distance_squared
			best_id = candidate_id
	current_target = best_target
	var next_prompt: StringName = &""
	if current_target != null:
		next_prompt = current_target.call("get_prompt_key", snapshot)
	if next_prompt != _last_prompt:
		_last_prompt = next_prompt
		interaction_changed.emit(next_prompt)
