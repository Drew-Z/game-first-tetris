extends Node2D

const PieceStateModel := preload("res://scripts/game/data/piece_state.gd")

@export var cell_size: int = 32

var piece_state = null


func _ready() -> void:
	if piece_state == null:
		piece_state = PieceStateModel.new()

	queue_redraw()


func _draw() -> void:
	if piece_state == null:
		return

	for cell in piece_state.get_board_cells():
		var rect := Rect2(Vector2(cell) * cell_size, Vector2.ONE * cell_size)
		draw_rect(rect, piece_state.get_color(), true)
		draw_rect(rect, Color.WHITE, false, 2.0)


func configure_from_state(new_piece_state) -> void:
	piece_state = new_piece_state
	queue_redraw()
