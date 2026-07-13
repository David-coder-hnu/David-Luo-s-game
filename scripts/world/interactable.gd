class_name Interactable
extends Area2D

signal activated(dialogue_key: StringName)

var interaction_id: StringName
var prompt_key: StringName = &"ui.action.inspect"
var dialogue_key: StringName
var busy := false
var enabled := true


func get_interaction_id() -> StringName:
	return interaction_id


func get_interaction_score(player_position: Vector2, facing: Vector2) -> Dictionary:
	var offset := global_position - player_position
	var distance_squared := offset.length_squared()
	var direction := offset.normalized() if distance_squared > 0.0 else facing
	return {
		"in_front": facing.dot(direction) >= 0.70710678,
		"distance_squared": distance_squared,
		"interaction_id": interaction_id,
	}


func can_interact(_game_snapshot: Dictionary) -> bool:
	return enabled and not busy


func get_prompt_key(game_snapshot: Dictionary) -> StringName:
	return prompt_key if can_interact(game_snapshot) else &""


func interact(context: Dictionary = {}) -> void:
	var snapshot: Dictionary = context.get("game_snapshot", {})
	if not can_interact(snapshot):
		return
	busy = true
	activated.emit(dialogue_key)


func release() -> void:
	busy = false
