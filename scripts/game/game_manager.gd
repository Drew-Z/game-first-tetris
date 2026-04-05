extends Node

const PieceStateModel := preload("res://scripts/game/data/piece_state.gd")
const GameModeState := preload("res://scripts/game/game_mode_state.gd")
const SevenBagPieceSourceModel := preload("res://scripts/game/data/seven_bag_piece_source.gd")
const TetrominoData := preload("res://scripts/game/data/tetromino_data.gd")
const ROGUE_PRE_RUN_CHOICE_ROUND := 1

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
@export var rogue_second_choice_clear_lines: int = 2
@export var rogue_third_choice_clear_lines: int = 4

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
var remaining_spawn_protection_uses: int = 0
var rogue_hard_drop_bonus_score: int = 0
var rogue_line_clear_bonus_per_row: int = 0
var rogue_selected_upgrade_ids: Array[StringName] = []
var rogue_selected_upgrade_display_names: Array[String] = []
var is_rogue_choice_pending: bool = false
var triggered_rogue_choice_rounds: Array[int] = []
var pending_rogue_choice_round: int = 0
var rogue_active_run_carry_over_upgrade_id: StringName = &""
var rogue_next_run_carry_over_upgrade_id: StringName = &""


func _ready() -> void:
	_setup_mode_state()
	_ensure_piece_source()
	start_game()


func _process(delta: float) -> void:
	if is_game_over or is_rogue_choice_pending or active_piece_state == null or not is_piece_falling:
		return

	gravity_timer += delta

	var current_drop_step := _get_current_drop_step_seconds()

	while gravity_timer >= current_drop_step and is_piece_falling:
		gravity_timer -= current_drop_step
		_try_auto_drop_active_piece()


func _unhandled_input(event: InputEvent) -> void:
	if is_game_over or is_rogue_choice_pending:
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
	_prepare_rogue_run_state()
	next_piece_id = _draw_next_piece_id()
	_spawn_new_active_piece()
	_sync_ui()


func _setup_board() -> void:
	if board.has_method("setup_board_state"):
		board.call("setup_board_state")

	if game_ui != null and not game_ui.is_connected("restart_requested", Callable(self, "_on_restart_requested")):
		game_ui.connect("restart_requested", Callable(self, "_on_restart_requested"))
	if game_ui != null and game_ui.has_signal("rogue_upgrade_selected"):
		if not game_ui.is_connected("rogue_upgrade_selected", Callable(self, "_on_rogue_upgrade_selected")):
			game_ui.connect("rogue_upgrade_selected", Callable(self, "_on_rogue_upgrade_selected"))


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
			runtime_result.mode_id,
			runtime_result.mode_display_name,
			runtime_result.mode_note,
			runtime_result.rogue_upgrade_display_name,
			runtime_result.remaining_spawn_protection_uses,
			runtime_result.rogue_upgrade_effects_text,
			runtime_result.rogue_active_carry_over_upgrade_display_name,
			runtime_result.rogue_next_run_carry_over_upgrade_display_name
		)
	if game_ui.has_method("set_rogue_choice_prompt"):
		game_ui.call(
			"set_rogue_choice_prompt",
			runtime_result.is_rogue_choice_pending,
			runtime_result.rogue_choice_prompt_title,
			runtime_result.rogue_choice_prompt_hint
		)

	if is_game_over:
		if game_ui.has_method("show_game_over_summary"):
			game_ui.call(
				"show_game_over_summary",
				runtime_result.locked_piece_count,
				runtime_result.score,
				runtime_result.current_level,
				runtime_result.mode_id,
				runtime_result.mode_display_name,
			runtime_result.mode_note,
			runtime_result.rogue_upgrade_display_name,
			runtime_result.remaining_spawn_protection_uses,
			runtime_result.rogue_upgrade_effects_text,
			runtime_result.rogue_active_carry_over_upgrade_display_name,
			runtime_result.rogue_next_run_carry_over_upgrade_display_name
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
			runtime_result.mode_id,
			runtime_result.mode_display_name,
			runtime_result.mode_note,
			runtime_result.rogue_upgrade_display_name,
			runtime_result.remaining_spawn_protection_uses,
			runtime_result.rogue_upgrade_effects_text,
			runtime_result.rogue_active_carry_over_upgrade_display_name,
			runtime_result.rogue_next_run_carry_over_upgrade_display_name
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

	score += rogue_hard_drop_bonus_score
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
			score += cleared_row_count * rogue_line_clear_bonus_per_row
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
	_try_trigger_next_rogue_choice()
	_sync_ui()


func _enter_game_over() -> void:
	active_piece_state = null
	is_piece_falling = false
	is_game_over = true
	gravity_timer = 0.0
	_capture_rogue_meta_progression_on_game_over()

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
	is_rogue_choice_pending = false
	triggered_rogue_choice_rounds.clear()
	pending_rogue_choice_round = 0
	rogue_active_run_carry_over_upgrade_id = &""

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
			if _try_consume_spawn_protection(spawn_cells):
				spawn_cells = next_piece_state.get_board_cells()
			else:
				_enter_game_over()
				return

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


func _get_rogue_choice_round_configs() -> Array[Dictionary]:
	return [
		{
			"round": ROGUE_PRE_RUN_CHOICE_ROUND,
			"trigger_type": "pre_run",
			"required_cleared_lines": 0,
		},
		{
			"round": 2,
			"trigger_type": "cleared_lines",
			"required_cleared_lines": rogue_second_choice_clear_lines,
		},
		{
			"round": 3,
			"trigger_type": "cleared_lines",
			"required_cleared_lines": rogue_third_choice_clear_lines,
		},
	]


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
		"mode_note": _get_mode_note_for_ui(),
		"rogue_upgrade_id": mode_state["rogue_upgrade_id"],
		"rogue_upgrade_display_name": _get_rogue_upgrade_summary(),
		"remaining_spawn_protection_uses": remaining_spawn_protection_uses,
		"rogue_upgrade_effects_text": _get_rogue_upgrade_effects_text(),
		"rogue_active_carry_over_upgrade_display_name": _get_rogue_upgrade_display_name(rogue_active_run_carry_over_upgrade_id),
		"rogue_next_run_carry_over_upgrade_display_name": _get_rogue_upgrade_display_name(rogue_next_run_carry_over_upgrade_id),
		"is_rogue_choice_pending": is_rogue_choice_pending,
		"rogue_choice_prompt_title": _get_rogue_choice_prompt_title(),
		"rogue_choice_prompt_hint": _get_rogue_choice_prompt_hint(),
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
	if mode_id != &"rogue":
		_clear_rogue_restart_loop_carry_over()
	_setup_mode_state()


func set_entry_mode(mode_id: StringName) -> void:
	set_mode_setup(mode_id, &"")


func _setup_mode_state() -> void:
	mode_state = GameModeState.create(entry_mode, rogue_upgrade_id)


func _prepare_rogue_run_state() -> void:
	rogue_hard_drop_bonus_score = 0
	rogue_line_clear_bonus_per_row = 0
	remaining_spawn_protection_uses = 0
	rogue_selected_upgrade_ids.clear()
	rogue_selected_upgrade_display_names.clear()
	is_rogue_choice_pending = false
	triggered_rogue_choice_rounds.clear()
	pending_rogue_choice_round = 0
	rogue_active_run_carry_over_upgrade_id = &""

	if entry_mode != &"rogue":
		_clear_rogue_restart_loop_carry_over()
		return

	rogue_active_run_carry_over_upgrade_id = _consume_rogue_restart_loop_carry_over_for_new_run()
	if rogue_active_run_carry_over_upgrade_id != &"":
		_apply_rogue_upgrade_effect(rogue_active_run_carry_over_upgrade_id)

	_apply_rogue_upgrade_effect(StringName(mode_state.get("rogue_upgrade_id", &"")))
	triggered_rogue_choice_rounds.append(ROGUE_PRE_RUN_CHOICE_ROUND)


func _apply_rogue_upgrade_effect(selected_upgrade_id: StringName) -> void:
	if entry_mode != &"rogue":
		return

	var upgrade_definition := GameModeState.get_rogue_upgrade_definition(selected_upgrade_id)
	var normalized_upgrade_id: StringName = upgrade_definition["id"]
	rogue_selected_upgrade_ids.append(normalized_upgrade_id)
	rogue_selected_upgrade_display_names.append(String(upgrade_definition["display_name"]))
	rogue_hard_drop_bonus_score += int(upgrade_definition["hard_drop_bonus_score"])
	rogue_line_clear_bonus_per_row += int(upgrade_definition["line_clear_bonus_per_row"])
	remaining_spawn_protection_uses += int(upgrade_definition["spawn_protection_uses"])


func _capture_rogue_meta_progression_on_game_over() -> void:
	if entry_mode != &"rogue":
		return

	_store_rogue_restart_loop_carry_over_from_run()


func _get_next_run_carry_over_upgrade_id() -> StringName:
	if rogue_selected_upgrade_ids.is_empty():
		return &""

	return rogue_selected_upgrade_ids[rogue_selected_upgrade_ids.size() - 1]


func _store_rogue_restart_loop_carry_over_from_run() -> void:
	# The meta shell intentionally keeps only one carry-over result for the next
	# Rogue restart loop. It is not a persistent save or a classic-mode feature.
	rogue_next_run_carry_over_upgrade_id = _get_next_run_carry_over_upgrade_id()


func _consume_rogue_restart_loop_carry_over_for_new_run() -> StringName:
	var carry_over_upgrade_id := rogue_next_run_carry_over_upgrade_id
	rogue_next_run_carry_over_upgrade_id = &""
	return carry_over_upgrade_id


func _clear_rogue_restart_loop_carry_over() -> void:
	rogue_active_run_carry_over_upgrade_id = &""
	rogue_next_run_carry_over_upgrade_id = &""


func _get_rogue_upgrade_display_name(rogue_upgrade_id: StringName) -> String:
	if rogue_upgrade_id == &"":
		return ""

	var upgrade_definition := GameModeState.get_rogue_upgrade_definition(rogue_upgrade_id)
	return String(upgrade_definition["display_name"])


func _try_trigger_next_rogue_choice() -> void:
	if entry_mode != &"rogue":
		return
	if is_game_over or active_piece_state == null:
		return
	if is_rogue_choice_pending:
		return

	for choice_config in _get_rogue_choice_round_configs():
		var choice_round := int(choice_config["round"])
		if _has_triggered_rogue_choice_round(choice_round):
			continue
		if not _is_rogue_choice_trigger_ready(choice_config):
			continue

		_begin_rogue_choice(choice_round)
		return


func _begin_rogue_choice(choice_round: int) -> void:
	triggered_rogue_choice_rounds.append(choice_round)
	pending_rogue_choice_round = choice_round
	is_rogue_choice_pending = true
	is_piece_falling = false
	gravity_timer = 0.0


func _on_rogue_upgrade_selected(selected_upgrade_id: StringName) -> void:
	if entry_mode != &"rogue" or not is_rogue_choice_pending or is_game_over:
		return

	_apply_rogue_upgrade_effect(selected_upgrade_id)
	is_rogue_choice_pending = false
	pending_rogue_choice_round = 0
	is_piece_falling = active_piece_state != null
	gravity_timer = 0.0
	_sync_ui()


func _try_consume_spawn_protection(spawn_cells: Array[Vector2i]) -> bool:
	if entry_mode != &"rogue":
		return false

	if remaining_spawn_protection_uses <= 0:
		return false

	if not board.has_method("clear_cells"):
		return false

	board.call("clear_cells", spawn_cells)
	remaining_spawn_protection_uses -= 1
	return true


func _get_mode_note_for_ui() -> String:
	var note := String(mode_state.get("mode_note", ""))

	if entry_mode != &"rogue":
		return note

	if is_rogue_choice_pending:
		return "%s 当前已触发第 %d 次 3 选 1，请先完成选择后再继续。" % [
			note,
			pending_rogue_choice_round,
		]

	if remaining_spawn_protection_uses > 0:
		return "%s 当前剩余出生保护：%d 次。" % [note, remaining_spawn_protection_uses]

	if entry_mode == &"rogue" and mode_state.get("rogue_upgrade_id", &"") == &"spawn_protection":
		return "%s 当前剩余出生保护：%d 次。" % [note, remaining_spawn_protection_uses]

	return note


func _get_rogue_upgrade_summary() -> String:
	if rogue_selected_upgrade_display_names.is_empty():
		return String(mode_state.get("rogue_upgrade_display_name", ""))

	var segments: Array[String] = []
	var counts := _get_rogue_upgrade_counts()

	for upgrade_id in GameModeState.get_rogue_upgrade_options():
		var count := int(counts.get(upgrade_id, 0))
		if count <= 0:
			continue

		var upgrade_definition := GameModeState.get_rogue_upgrade_definition(upgrade_id)
		segments.append("%s x%d" % [String(upgrade_definition["display_name"]), count])

	return " / ".join(segments)


func _get_rogue_upgrade_counts() -> Dictionary:
	var counts: Dictionary = {}

	for upgrade_id in rogue_selected_upgrade_ids:
		counts[upgrade_id] = int(counts.get(upgrade_id, 0)) + 1

	return counts


func _get_rogue_upgrade_effects_text() -> String:
	if entry_mode != &"rogue":
		return ""

	var counts := _get_rogue_upgrade_counts()
	if counts.is_empty():
		return "本局尚未获得 Rogue 强化。"

	var lines: Array[String] = []

	for upgrade_id in GameModeState.get_rogue_upgrade_options():
		var count := int(counts.get(upgrade_id, 0))
		if count <= 0:
			continue

		var upgrade_definition := GameModeState.get_rogue_upgrade_definition(upgrade_id)
		var line := "- %s x%d" % [String(upgrade_definition["display_name"]), count]

		match upgrade_id:
			&"hard_drop_bonus":
				line += "（当前每次 Hard Drop 额外 +%d 分）" % [rogue_hard_drop_bonus_score]
			&"line_clear_bonus":
				line += "（当前每消除 1 行额外 +%d 分）" % [rogue_line_clear_bonus_per_row]
			&"spawn_protection":
				line += "（当前剩余 %d 次）" % [remaining_spawn_protection_uses]

		lines.append(line)

	return "\n".join(lines)


func _get_rogue_choice_prompt_title() -> String:
	if not is_rogue_choice_pending:
		return ""

	return "Rogue 模式：局内第 %d 次强化 3 选 1" % [pending_rogue_choice_round]


func _get_rogue_choice_prompt_hint() -> String:
	if not is_rogue_choice_pending:
		return ""

	return "当前按累计消除 %d 行触发。请选择一个新的本局强化，经典模式不受影响。" % [
		_get_rogue_choice_threshold_for_round(pending_rogue_choice_round),
	]


func _get_rogue_choice_threshold_for_round(choice_round: int) -> int:
	for choice_config in _get_rogue_choice_round_configs():
		if int(choice_config["round"]) != choice_round:
			continue
		return int(choice_config["required_cleared_lines"])

	return 0


func _has_triggered_rogue_choice_round(choice_round: int) -> bool:
	return triggered_rogue_choice_rounds.has(choice_round)


func _is_rogue_choice_trigger_ready(choice_config: Dictionary) -> bool:
	var trigger_type := String(choice_config.get("trigger_type", ""))

	match trigger_type:
		"pre_run":
			return false
		"cleared_lines":
			return cleared_line_count >= int(choice_config.get("required_cleared_lines", 0))
		_:
			return false
