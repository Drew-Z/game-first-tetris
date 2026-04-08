extends Node

const GameManagerScript := preload("res://scripts/game/game_manager.gd")

@onready var game_manager: Node = $"../GameManager"


func tap_action(action_id: StringName) -> void:
	if game_manager == null or not game_manager.has_method("trigger_game_action"):
		return

	game_manager.call("trigger_game_action", action_id, GameManagerScript.INPUT_SOURCE_TOUCH)


func set_touch_action_pressed(action_id: StringName, is_pressed: bool) -> void:
	if game_manager == null or not game_manager.has_method("set_game_action_pressed"):
		return

	game_manager.call(
		"set_game_action_pressed",
		action_id,
		is_pressed,
		GameManagerScript.INPUT_SOURCE_TOUCH
	)


func release_all_touch_actions() -> void:
	if game_manager == null or not game_manager.has_method("clear_game_action_source_state"):
		return

	game_manager.call("clear_game_action_source_state", GameManagerScript.INPUT_SOURCE_TOUCH)


func get_supported_touch_actions() -> Dictionary:
	return {
		"instant": GameManagerScript.get_instant_game_actions(),
		"continuous": GameManagerScript.get_continuous_game_actions(),
	}
