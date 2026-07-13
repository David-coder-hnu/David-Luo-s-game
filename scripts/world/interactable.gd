class_name Interactable
extends Area2D

signal activated(dialogue_key: StringName)

var interaction_id: StringName
var prompt_key: StringName = &"ui.action.inspect"
var dialogue_key: StringName
var busy := false


func interact() -> void:
	if busy:
		return
	busy = true
	activated.emit(dialogue_key)


func release() -> void:
	busy = false
