class_name BoardState
extends RefCounted

const EMPTY_CELL: StringName = &""

var columns: int
var rows: int
var cells: Array[Array] = []


func _init(new_columns: int = 10, new_rows: int = 20) -> void:
	columns = new_columns
	rows = new_rows
	reset()


func reset() -> void:
	cells.clear()

	for row in range(rows):
		var row_cells: Array[StringName] = []
		row_cells.resize(columns)

		for column in range(columns):
			row_cells[column] = EMPTY_CELL

		cells.append(row_cells)


func is_inside_cell(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.x < columns and cell.y >= 0 and cell.y < rows


func get_cell(cell: Vector2i) -> StringName:
	if not is_inside_cell(cell):
		return EMPTY_CELL

	return cells[cell.y][cell.x]


func set_cell(cell: Vector2i, piece_id: StringName) -> bool:
	if not is_inside_cell(cell):
		return false

	cells[cell.y][cell.x] = piece_id
	return true


func clear_cell(cell: Vector2i) -> bool:
	return set_cell(cell, EMPTY_CELL)


func is_cell_empty(cell: Vector2i) -> bool:
	return is_inside_cell(cell) and get_cell(cell) == EMPTY_CELL


func get_spawn_origin(spawn_box_size: int = 4, spawn_row: int = 0) -> Vector2i:
	var spawn_x := maxi(0, floori(float(columns - spawn_box_size) / 2.0))
	return Vector2i(spawn_x, spawn_row)


func describe() -> String:
	return "Board %dx%d spawn=%s" % [columns, rows, get_spawn_origin()]
