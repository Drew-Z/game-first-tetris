extends Node

@export var lock_stream: AudioStream
@export var line_clear_stream: AudioStream
@export var hard_drop_stream: AudioStream
@export var game_over_stream: AudioStream
@export var restart_stream: AudioStream

var _players: Dictionary = {}


func _ready() -> void:
	_register_player(&"lock", lock_stream)
	_register_player(&"line_clear", line_clear_stream)
	_register_player(&"hard_drop", hard_drop_stream)
	_register_player(&"game_over", game_over_stream)
	_register_player(&"restart", restart_stream)


func play_lock() -> void:
	_play_event(&"lock")


func play_line_clear(_cleared_row_count: int = 0) -> void:
	_play_event(&"line_clear")


func play_hard_drop() -> void:
	_play_event(&"hard_drop")


func play_game_over() -> void:
	_play_event(&"game_over")


func play_restart() -> void:
	_play_event(&"restart")


func _register_player(event_name: StringName, stream: AudioStream) -> void:
	var player := AudioStreamPlayer.new()
	player.name = "%sPlayer" % [String(event_name).capitalize()]
	player.stream = stream
	add_child(player)
	_players[event_name] = player


func _play_event(event_name: StringName) -> void:
	var player: AudioStreamPlayer = _players.get(event_name)
	if player == null or player.stream == null:
		return

	player.play()
