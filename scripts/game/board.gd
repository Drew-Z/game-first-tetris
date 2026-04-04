extends Node2D

const BoardStateModel := preload("res://scripts/game/data/board_state.gd")

@export var columns: int = 10
@export var rows: int = 20
@export var cell_size: int = 32
@export var board_color: Color = Color("1b2a41")
@export var grid_color: Color = Color("3a506b")
@export var border_color: Color = Color("e0e1dd")

var board_state = null


func _ready() -> void:
	setup_board_state()
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
			draw_rect(rect, Color("415a77"), true)
			draw_rect(rect, border_color, false, 1.0)


func setup_board_state() -> void:
	board_state = BoardStateModel.new(columns, rows)


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

	return true


func is_inside_bottom_bounds(cell: Vector2i) -> bool:
	return cell.y >= 0 and cell.y < rows


func can_place_piece_vertically(cells: Array[Vector2i]) -> bool:
	for cell in cells:
		if not is_inside_bottom_bounds(cell):
			return false

	return true
