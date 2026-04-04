extends Node

const PieceStateModel := preload("res://scripts/game/data/piece_state.gd")
const TetrominoData := preload("res://scripts/game/data/tetromino_data.gd")

@onready var board: Node2D = $"../Layout/PlayfieldPanel/PlayfieldMargin/Playfield/Board"
@onready var active_piece: Node2D = $"../Layout/PlayfieldPanel/PlayfieldMargin/Playfield/ActivePiece"
@onready var game_ui: VBoxContainer = $"../Layout/SidebarPanel/GameUI"

@export var initial_piece_id: StringName = &"T"
@export var gravity_step_seconds: float = 0.6

var active_piece_state = null
var gravity_timer: float = 0.0
var is_piece_falling: bool = false
var is_game_over: bool = false
var locked_piece_count: int = 0
var score: int = 0


func _ready() -> void:
	start_game()


func _process(delta: float) -> void:
	if is_game_over or active_piece_state == null or not is_piece_falling:
		return

	gravity_timer += delta

	while gravity_timer >= gravity_step_seconds and is_piece_falling:
		gravity_timer -= gravity_step_seconds
		_try_auto_drop_active_piece()


func _unhandled_input(event: InputEvent) -> void:
	if is_game_over:
		return

	if event.is_action_pressed("ui_left"):
		_try_move_active_piece(Vector2i.LEFT)
	elif event.is_action_pressed("ui_right"):
		_try_move_active_piece(Vector2i.RIGHT)


func start_game() -> void:
	_prepare_runtime_for_restart()
	is_game_over = false
	locked_piece_count = 0
	score = 0
	_spawn_new_active_piece()
	_sync_ui()


func _setup_board() -> void:
	if board.has_method("setup_board_state"):
		board.call("setup_board_state")

	if game_ui != null and not game_ui.is_connected("restart_requested", Callable(self, "_on_restart_requested")):
		game_ui.connect("restart_requested", Callable(self, "_on_restart_requested"))


func _spawn_new_active_piece() -> void:
	var piece_id: StringName = initial_piece_id
	var spawn_box_size := TetrominoData.get_spawn_box_size(piece_id)
	var spawn_origin := Vector2i(3, 0)

	if board.has_method("get_spawn_origin"):
		spawn_origin = board.call("get_spawn_origin", spawn_box_size)

	if active_piece.get("cell_size") != null and board.get("cell_size") != null:
		active_piece.set("cell_size", board.get("cell_size"))

	var next_piece_state = PieceStateModel.new(piece_id, spawn_origin, 0)
	var spawn_cells: Array[Vector2i] = next_piece_state.get_board_cells()

	if board.has_method("can_place_piece"):
		if not board.call("can_place_piece", spawn_cells):
			_enter_game_over()
			return

	active_piece_state = next_piece_state
	gravity_timer = 0.0
	is_piece_falling = true

	if active_piece.has_method("spawn_piece"):
		active_piece.call("spawn_piece", active_piece_state)


func _sync_ui() -> void:
	if game_ui.has_method("show_structure_mode"):
		game_ui.call("show_structure_mode", board.get("columns"), board.get("rows"))

	if is_game_over:
		if game_ui.has_method("show_game_over_summary"):
			game_ui.call("show_game_over_summary", locked_piece_count, score)
		return

	if active_piece_state == null:
		return

	if game_ui.has_method("show_piece_runtime_summary"):
		game_ui.call(
			"show_piece_runtime_summary",
			active_piece_state.piece_id,
			active_piece_state.origin,
			is_piece_falling,
			locked_piece_count,
			score
		)


func _try_move_active_piece(offset: Vector2i) -> void:
	if active_piece_state == null:
		return

	var target_origin: Vector2i = active_piece_state.origin + offset
	var target_cells: Array[Vector2i] = TetrominoData.get_global_cells(
		active_piece_state.piece_id,
		target_origin,
		active_piece_state.rotation_index
	)

	if board.has_method("can_place_piece_horizontally"):
		if not board.call("can_place_piece_horizontally", target_cells):
			return

	active_piece_state.move_by(offset)

	if active_piece.has_method("spawn_piece"):
		active_piece.call("spawn_piece", active_piece_state)

	_sync_ui()


func _try_auto_drop_active_piece() -> void:
	if active_piece_state == null:
		return

	var target_origin: Vector2i = active_piece_state.origin + Vector2i.DOWN
	var target_cells: Array[Vector2i] = TetrominoData.get_global_cells(
		active_piece_state.piece_id,
		target_origin,
		active_piece_state.rotation_index
	)

	if board.has_method("can_place_piece_vertically"):
		if not board.call("can_place_piece_vertically", target_cells):
			_lock_active_piece()
			return

	active_piece_state.move_by(Vector2i.DOWN)

	if active_piece.has_method("spawn_piece"):
		active_piece.call("spawn_piece", active_piece_state)

	_sync_ui()


func _lock_active_piece() -> void:
	if active_piece_state == null:
		return

	var locked_cells: Array[Vector2i] = active_piece_state.get_board_cells()
	var locked_piece_id: StringName = active_piece_state.piece_id

	if board.has_method("write_piece_cells"):
		board.call("write_piece_cells", locked_cells, locked_piece_id)

	if board.has_method("clear_full_rows"):
		var cleared_row_count: int = board.call("clear_full_rows")
		if cleared_row_count > 0:
			score += cleared_row_count

	if active_piece.has_method("clear_piece"):
		active_piece.call("clear_piece")

	locked_piece_count += 1
	active_piece_state = null
	is_piece_falling = false
	gravity_timer = 0.0
	_spawn_new_active_piece()
	_sync_ui()


func _enter_game_over() -> void:
	active_piece_state = null
	is_piece_falling = false
	is_game_over = true
	gravity_timer = 0.0

	if active_piece.has_method("clear_piece"):
		active_piece.call("clear_piece")

	_sync_ui()


func _on_restart_requested() -> void:
	start_game()


func _prepare_runtime_for_restart() -> void:
	_setup_board()
	active_piece_state = null
	is_piece_falling = false
	gravity_timer = 0.0

	if active_piece.has_method("clear_piece"):
		active_piece.call("clear_piece")

	if board.has_method("reset_board_state"):
		board.call("reset_board_state")
