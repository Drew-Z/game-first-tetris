extends Node2D

@export var columns: int = 10
@export var rows: int = 20
@export var cell_size: int = 32
@export var board_color: Color = Color("1b2a41")
@export var grid_color: Color = Color("3a506b")
@export var border_color: Color = Color("e0e1dd")


func _ready() -> void:
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


func get_board_pixel_size() -> Vector2:
	return Vector2(columns * cell_size, rows * cell_size)


func get_spawn_preview_position() -> Vector2:
	return Vector2(cell_size * 3, cell_size)
