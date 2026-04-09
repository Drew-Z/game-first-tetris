extends Node2D

const BoardStateModel := preload("res://scripts/game/data/board_state.gd")
const TetrominoData := preload("res://scripts/game/data/tetromino_data.gd")

@export var columns: int = 10
@export var rows: int = 20
@export var cell_size: int = 32
@export var board_color: Color = Color("1b2a41")
@export var grid_color: Color = Color("3a506b")
@export var border_color: Color = Color("e0e1dd")
@export var line_clear_flash_duration: float = 0.18
@export var line_clear_flash_color: Color = Color(1.0, 1.0, 1.0, 0.72)

var board_state = null
var flashed_rows: Array[int] = []
var line_clear_flash_timer: float = 0.0


func _ready() -> void:
	setup_board_state()
	queue_redraw()


func _process(delta: float) -> void:
	if flashed_rows.is_empty():
		return

	line_clear_flash_timer = maxf(line_clear_flash_timer - delta, 0.0)
	if line_clear_flash_timer <= 0.0:
		flashed_rows.clear()

	queue_redraw()


func _draw() -> void:
	var board_size := get_board_pixel_size()
	draw_rect(Rect2(Vector2.ZERO, board_size), board_color, true)
	draw_rect(Rect2(Vector2.ZERO, board_size), border_color, false, 2.0)

	for column in range(columns + 1):
		var x := float(column * cell_size)
		draw_line(Vector2(x, 0.0), Vector2(x, board_size.y), grid_color, 1.0)

	for row in range(rows + 1):
		var y := float(row * cell_size)
		draw_line(Vector2(0.0, y), Vector2(board_size.x, y), grid_color, 1.0)

	if board_state == null:
		return

	for row in range(rows):
		for column in range(columns):
			var cell := Vector2i(column, row)
			var piece_id: StringName = board_state.get_cell(cell)

			if piece_id == BoardStateModel.EMPTY_CELL:
				continue

			var rect := Rect2(grid_to_local(cell), Vector2.ONE * cell_size)
			draw_rect(rect, TetrominoData.get_color(piece_id), true)
			draw_rect(rect, border_color, false, 1.0)

	_draw_line_clear_flash()


func setup_board_state() -> void:
	board_state = BoardStateModel.new(columns, rows)
	queue_redraw()


func grid_to_local(cell: Vector2i) -> Vector2:
	return Vector2(cell.x * cell_size, cell.y * cell_size)


func local_to_grid(local_position: Vector2) -> Vector2i:
	return Vector2i(floori(local_position.x / cell_size), floori(local_position.y / cell_size))


func get_board_pixel_size() -> Vector2:
	return Vector2(columns * cell_size, rows * cell_size)


func get_spawn_origin(spawn_box_size: int = 4) -> Vector2i:
	if board_state == null:
		setup_board_state()

	return board_state.get_spawn_origin(spawn_box_size)


func get_spawn_preview_position() -> Vector2:
	return grid_to_local(get_spawn_origin())


func is_inside_horizontal_bounds(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.x < columns


func can_place_piece_horizontally(cells: Array[Vector2i]) -> bool:
	for cell in cells:
		if not is_inside_horizontal_bounds(cell):
			return false

	return can_place_piece(cells)


func is_inside_bottom_bounds(cell: Vector2i) -> bool:
	return cell.y >= 0 and cell.y < rows


func can_place_piece_vertically(cells: Array[Vector2i]) -> bool:
	for cell in cells:
		if not is_inside_bottom_bounds(cell):
			return false

	return can_place_piece(cells)


func can_place_piece(cells: Array[Vector2i]) -> bool:
	return _are_cells_placeable(cells)


func write_piece_cells(cells: Array[Vector2i], piece_id: StringName) -> void:
	if board_state == null:
		setup_board_state()

	for cell in cells:
		board_state.set_cell(cell, piece_id)

	queue_redraw()


func clear_cells(cells: Array[Vector2i]) -> void:
	if board_state == null:
		setup_board_state()

	for cell in cells:
		board_state.clear_cell(cell)

	queue_redraw()


func clear_full_rows() -> int:
	if board_state == null:
		setup_board_state()

	var clear_result: Dictionary = board_state.clear_full_rows_detailed()
	var cleared_row_count: int = int(clear_result.get("count", 0))
	var cleared_rows_variant: Array = clear_result.get("rows", [])

	if cleared_row_count > 0:
		flashed_rows.clear()
		for row in cleared_rows_variant:
			flashed_rows.append(int(row))
		line_clear_flash_timer = line_clear_flash_duration

	queue_redraw()
	return cleared_row_count


func _are_cells_placeable(cells: Array[Vector2i]) -> bool:
	if board_state == null:
		setup_board_state()

	return board_state.are_cells_placeable(cells)


func reset_board_state() -> void:
	if board_state == null:
		setup_board_state()
		return

	board_state.reset()
	flashed_rows.clear()
	line_clear_flash_timer = 0.0
	queue_redraw()


func _draw_line_clear_flash() -> void:
	if flashed_rows.is_empty() or line_clear_flash_timer <= 0.0:
		return

	var alpha_scale := line_clear_flash_timer / line_clear_flash_duration
	var flash_color := line_clear_flash_color
	flash_color.a *= alpha_scale

	for row in flashed_rows:
		var rect := Rect2(
			Vector2(0.0, float(row * cell_size)),
			Vector2(float(columns * cell_size), float(cell_size))
		)
		draw_rect(rect, flash_color, true)
