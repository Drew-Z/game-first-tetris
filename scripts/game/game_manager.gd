extends Node

const PieceStateModel := preload("res://scripts/game/data/piece_state.gd")
const GameModeState := preload("res://scripts/game/game_mode_state.gd")
const SevenBagPieceSourceModel := preload("res://scripts/game/data/seven_bag_piece_source.gd")
const TetrominoData := preload("res://scripts/game/data/tetromino_data.gd")

@onready var board: Node2D = $"../Layout/PlayfieldPanel/PlayfieldMargin/Playfield/Board"
@onready var active_piece: Node2D = $"../Layout/PlayfieldPanel/PlayfieldMargin/Playfield/ActivePiece"
@onready var game_ui: VBoxContainer = $"../Layout/SidebarPanel/GameUI"
@onready var game_audio: Node = $"../GameAudio"

@export var entry_mode: StringName = &"classic"
@export var rogue_upgrade_id: StringName = &""
@export var initial_piece_id: StringName = &"T"
@export var gravity_step_seconds: float = 0.6
@export var soft_drop_step_seconds: float = 0.08
@export var lines_per_level: int = 5
@export var gravity_step_decrease_per_level: float = 0.08
@export var minimum_gravity_step_seconds: float = 0.12

var active_piece_state = null
var next_piece_id: StringName = &""
var hold_piece_id: StringName = &""
var gravity_timer: float = 0.0
var is_piece_falling: bool = false
var is_game_over: bool = false
var locked_piece_count: int = 0
var score: int = 0
var cleared_line_count: int = 0
var current_level: int = 1
var can_hold_current_piece: bool = true
var piece_source = null
var mode_state: Dictionary = {}


func _ready() -> void:
	_setup_mode_state()
	_ensure_piece_source()
	start_game()


func _process(delta: float) -> void:
	if is_game_over or active_piece_state == null or not is_piece_falling:
		return

	gravity_timer += delta

	var current_drop_step := _get_current_drop_step_seconds()

	while gravity_timer >= current_drop_step and is_piece_falling:
		gravity_timer -= current_drop_step
		_try_auto_drop_active_piece()


func _unhandled_input(event: InputEvent) -> void:
	if is_game_over:
		return

	if event.is_action_pressed("ui_left"):
		_try_move_active_piece(Vector2i.LEFT)
	elif event.is_action_pressed("ui_right"):
		_try_move_active_piece(Vector2i.RIGHT)
	elif event.is_action_pressed("ui_up"):
		_try_rotate_active_piece()
	elif event.is_action_pressed("hard_drop"):
		_try_hard_drop_active_piece()
	elif event.is_action_pressed("hold"):
		_try_hold_active_piece()


func start_game() -> void:
	_setup_mode_state()
	_prepare_runtime_for_restart()
	is_game_over = false
	locked_piece_count = 0
	score = 0
	cleared_line_count = 0
	current_level = 1
	next_piece_id = _draw_next_piece_id()
	_spawn_new_active_piece()
	_sync_ui()


func _setup_board() -> void:
	if board.has_method("setup_board_state"):
		board.call("setup_board_state")

	if game_ui != null and not game_ui.is_connected("restart_requested", Callable(self, "_on_restart_requested")):
		game_ui.connect("restart_requested", Callable(self, "_on_restart_requested"))


func _spawn_new_active_piece() -> void:
	var piece_id: StringName = initial_piece_id
	if next_piece_id != &"":
		piece_id = next_piece_id

	_spawn_piece_from_id(piece_id, true, true)


func _sync_ui() -> void:
	var runtime_result := get_runtime_result()

	if game_ui.has_method("show_structure_mode"):
		game_ui.call(
			"show_structure_mode",
			board.get("columns"),
			board.get("rows"),
			runtime_result.mode_display_name,
			runtime_result.mode_note
		)

	if is_game_over:
		if game_ui.has_method("show_game_over_summary"):
			game_ui.call(
				"show_game_over_summary",
				runtime_result.locked_piece_count,
				runtime_result.score,
				runtime_result.current_level,
				runtime_result.mode_display_name,
				runtime_result.mode_note
			)
		return

	if active_piece_state == null:
		return

	if game_ui.has_method("show_piece_runtime_summary"):
		game_ui.call(
			"show_piece_runtime_summary",
			active_piece_state.piece_id,
			runtime_result.next_piece_id,
			runtime_result.hold_piece_id,
			runtime_result.can_hold_current_piece,
			active_piece_state.origin,
			active_piece_state.rotation_index,
			is_piece_falling,
			runtime_result.locked_piece_count,
			runtime_result.score,
			runtime_result.current_level,
			runtime_result.mode_display_name,
			runtime_result.mode_note
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


func _try_rotate_active_piece() -> void:
	if active_piece_state == null:
		return

	var next_rotation_index := posmod(active_piece_state.rotation_index + 1, 4)
	var target_cells: Array[Vector2i] = active_piece_state.get_board_cells_for_rotation(next_rotation_index)

	if board.has_method("can_place_piece"):
		if not board.call("can_place_piece", target_cells):
			return

	active_piece_state.rotate_by(1)

	if active_piece.has_method("spawn_piece"):
		active_piece.call("spawn_piece", active_piece_state)

	_sync_ui()


func _try_hard_drop_active_piece() -> void:
	if active_piece_state == null:
		return

	while true:
		var target_origin: Vector2i = active_piece_state.origin + Vector2i.DOWN
		var target_cells: Array[Vector2i] = TetrominoData.get_global_cells(
			active_piece_state.piece_id,
			target_origin,
			active_piece_state.rotation_index
		)

		if board.has_method("can_place_piece_vertically"):
			if not board.call("can_place_piece_vertically", target_cells):
				break

		active_piece_state.move_by(Vector2i.DOWN)

	score += int(mode_state.get("hard_drop_bonus_score", 0))
	_play_audio_event("play_hard_drop")
	_lock_active_piece()


func _try_hold_active_piece() -> void:
	if active_piece_state == null or not can_hold_current_piece:
		return

	var current_piece_id: StringName = active_piece_state.piece_id
	var swapped_piece_id: StringName = hold_piece_id

	hold_piece_id = current_piece_id
	active_piece_state = null
	is_piece_falling = false
	gravity_timer = 0.0
	can_hold_current_piece = false

	if active_piece.has_method("clear_piece"):
		active_piece.call("clear_piece")

	if swapped_piece_id == &"":
		_spawn_new_active_piece()
		can_hold_current_piece = false
	else:
		_spawn_piece_from_id(swapped_piece_id, false, false)

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
			cleared_line_count += cleared_row_count
			score += cleared_row_count
			score += cleared_row_count * int(mode_state.get("line_clear_bonus_per_row", 0))
			_update_level_from_cleared_lines()
			_play_audio_event("play_line_clear", [cleared_row_count])

	if active_piece.has_method("clear_piece"):
		active_piece.call("clear_piece")

	locked_piece_count += 1
	_play_audio_event("play_lock")
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

	_play_audio_event("play_game_over")
	_sync_ui()


func _on_restart_requested() -> void:
	start_game()
	_play_audio_event("play_restart")


func _prepare_runtime_for_restart() -> void:
	_setup_board()
	_ensure_piece_source()
	piece_source.reset()
	active_piece_state = null
	next_piece_id = &""
	hold_piece_id = &""
	is_piece_falling = false
	gravity_timer = 0.0
	can_hold_current_piece = true

	if active_piece.has_method("clear_piece"):
		active_piece.call("clear_piece")

	if board.has_method("reset_board_state"):
		board.call("reset_board_state")


func _get_current_drop_step_seconds() -> float:
	if Input.is_action_pressed("ui_down"):
		return soft_drop_step_seconds

	return _get_current_gravity_step_seconds()


func _draw_next_piece_id() -> StringName:
	_ensure_piece_source()
	return piece_source.draw_next_piece_id(initial_piece_id)


func _spawn_piece_from_id(
	piece_id: StringName,
	should_refresh_next_queue: bool,
	allow_hold_after_spawn: bool
) -> void:
	var queued_next_piece_id: StringName = next_piece_id
	if should_refresh_next_queue:
		queued_next_piece_id = _draw_next_piece_id()

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
	if should_refresh_next_queue:
		next_piece_id = queued_next_piece_id

	gravity_timer = 0.0
	is_piece_falling = true
	can_hold_current_piece = allow_hold_after_spawn

	if active_piece.has_method("spawn_piece"):
		active_piece.call("spawn_piece", active_piece_state)


func _update_level_from_cleared_lines() -> void:
	var rule_config := get_rule_config()
	var normalized_lines_per_level := maxi(int(rule_config.lines_per_level), 1)
	current_level = int(floori(float(cleared_line_count) / float(normalized_lines_per_level))) + 1


func _get_current_gravity_step_seconds() -> float:
	var rule_config := get_rule_config()
	var level_offset := maxi(current_level - 1, 0)
	var current_gravity := float(rule_config.gravity_step_seconds) - (
		float(rule_config.gravity_step_decrease_per_level) * float(level_offset)
	)
	return maxf(current_gravity, float(rule_config.minimum_gravity_step_seconds))


func get_rule_config() -> Dictionary:
	return {
		"gravity_step_seconds": gravity_step_seconds,
		"soft_drop_step_seconds": soft_drop_step_seconds,
		"lines_per_level": lines_per_level,
		"gravity_step_decrease_per_level": gravity_step_decrease_per_level,
		"minimum_gravity_step_seconds": minimum_gravity_step_seconds,
	}


func get_runtime_result() -> Dictionary:
	_setup_mode_state()
	return {
		"score": score,
		"cleared_line_count": cleared_line_count,
		"current_level": current_level,
		"locked_piece_count": locked_piece_count,
		"is_game_over": is_game_over,
		"next_piece_id": next_piece_id,
		"hold_piece_id": hold_piece_id,
		"can_hold_current_piece": can_hold_current_piece,
		"mode_id": mode_state["mode_id"],
		"mode_display_name": mode_state["display_name"],
		"mode_note": mode_state["mode_note"],
		"rogue_upgrade_id": mode_state["rogue_upgrade_id"],
		"rogue_upgrade_display_name": mode_state["rogue_upgrade_display_name"],
	}


func _ensure_piece_source() -> void:
	if piece_source == null:
		piece_source = SevenBagPieceSourceModel.new()


func _play_audio_event(method_name: String, args: Array = []) -> void:
	if game_audio == null or not game_audio.has_method(method_name):
		return

	game_audio.callv(method_name, args)


func set_mode_setup(mode_id: StringName, selected_rogue_upgrade_id: StringName = &"") -> void:
	entry_mode = mode_id
	rogue_upgrade_id = selected_rogue_upgrade_id
	_setup_mode_state()


func set_entry_mode(mode_id: StringName) -> void:
	set_mode_setup(mode_id, &"")


func _setup_mode_state() -> void:
	mode_state = GameModeState.create(entry_mode, rogue_upgrade_id)
