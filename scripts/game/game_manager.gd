extends Node

const PieceStateModel := preload("res://scripts/game/data/piece_state.gd")
const TetrominoData := preload("res://scripts/game/data/tetromino_data.gd")

@onready var board: Node2D = $"../Layout/PlayfieldPanel/PlayfieldMargin/Playfield/Board"
@onready var active_piece: Node2D = $"../Layout/PlayfieldPanel/PlayfieldMargin/Playfield/ActivePiece"
@onready var game_ui: VBoxContainer = $"../Layout/SidebarPanel/GameUI"

@export var initial_piece_id: StringName = &"T"

var active_piece_state = null


func _ready() -> void:
	start_game()


func start_game() -> void:
	_setup_board()
	_spawn_initial_piece()
	_sync_ui()


func _setup_board() -> void:
	if board.has_method("setup_board_state"):
		board.call("setup_board_state")


func _spawn_initial_piece() -> void:
	var spawn_box_size := TetrominoData.get_spawn_box_size(initial_piece_id)
	var spawn_origin := Vector2i(3, 0)

	if board.has_method("get_spawn_origin"):
		spawn_origin = board.call("get_spawn_origin", spawn_box_size)

	if active_piece.get("cell_size") != null and board.get("cell_size") != null:
		active_piece.set("cell_size", board.get("cell_size"))

	active_piece_state = PieceStateModel.new(initial_piece_id, spawn_origin, 0)

	if active_piece.has_method("spawn_piece"):
		active_piece.call("spawn_piece", active_piece_state)


func _sync_ui() -> void:
	if game_ui.has_method("show_structure_mode"):
		game_ui.call("show_structure_mode", board.get("columns"), board.get("rows"))

	if active_piece_state == null:
		return

	if game_ui.has_method("show_spawn_summary"):
		game_ui.call("show_spawn_summary", active_piece_state.piece_id, active_piece_state.origin)
