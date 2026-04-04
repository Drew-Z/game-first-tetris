extends Node

const PieceStateModel := preload("res://scripts/game/data/piece_state.gd")
const TetrominoData := preload("res://scripts/game/data/tetromino_data.gd")

@onready var board: Node2D = $"../Layout/PlayfieldPanel/PlayfieldMargin/Playfield/Board"
@onready var active_piece: Node2D = $"../Layout/PlayfieldPanel/PlayfieldMargin/Playfield/ActivePiece"
@onready var game_ui: VBoxContainer = $"../Layout/SidebarPanel/GameUI"

var preview_piece_id: StringName = &"T"


func _ready() -> void:
	_sync_structure_mode()


func _sync_structure_mode() -> void:
	var spawn_origin := Vector2i(3, 0)
	var spawn_box_size := TetrominoData.get_spawn_box_size(preview_piece_id)

	if board.has_method("setup_board_state"):
		board.call("setup_board_state")

	if board.has_method("get_spawn_origin"):
		spawn_origin = board.call("get_spawn_origin", spawn_box_size)

	if active_piece.get("cell_size") != null and board.get("cell_size") != null:
		active_piece.set("cell_size", board.get("cell_size"))

	if active_piece.has_method("configure_from_state"):
		active_piece.call("configure_from_state", PieceStateModel.new(preview_piece_id, spawn_origin, 0))

	if game_ui.has_method("show_structure_mode"):
		game_ui.call("show_structure_mode", board.get("columns"), board.get("rows"))

	if game_ui.has_method("show_data_model_summary"):
		game_ui.call("show_data_model_summary", board.call("get_spawn_origin"), preview_piece_id)
