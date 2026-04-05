extends Control

const TetrominoData := preload("res://scripts/game/data/tetromino_data.gd")

@export var preview_box_size: int = 4
@export var cell_size: int = 20
@export var border_color: Color = Color("e0e1dd")
@export var empty_text: String = "Empty"

var piece_id: StringName = &""


func _ready() -> void:
	custom_minimum_size = Vector2(preview_box_size * cell_size, preview_box_size * cell_size)
	queue_redraw()


func _draw() -> void:
	var box_size := Vector2(preview_box_size * cell_size, preview_box_size * cell_size)
	draw_rect(Rect2(Vector2.ZERO, box_size), Color(0, 0, 0, 0), false, 1.0)

	if piece_id == &"":
		_draw_empty_state(box_size)
		return

	var local_cells := TetrominoData.get_local_cells(piece_id, 0)
	var piece_color := TetrominoData.get_color(piece_id)

	for cell in local_cells:
		var rect := Rect2(Vector2(cell) * cell_size, Vector2.ONE * cell_size)
		draw_rect(rect, piece_color, true)
		draw_rect(rect, border_color, false, 1.0)


func show_piece(next_piece_id: StringName) -> void:
	piece_id = next_piece_id
	queue_redraw()


func clear_preview() -> void:
	show_piece(&"")


func _draw_empty_state(box_size: Vector2) -> void:
	draw_rect(Rect2(Vector2.ZERO, box_size), border_color, false, 1.0)
	var font := ThemeDB.fallback_font
	var font_size := ThemeDB.fallback_font_size
	if font == null:
		return

	var text_size := font.get_string_size(empty_text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
	var draw_position := Vector2(
		(box_size.x - text_size.x) * 0.5,
		(box_size.y + text_size.y) * 0.5
	)
	draw_string(font, draw_position, empty_text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, border_color)
