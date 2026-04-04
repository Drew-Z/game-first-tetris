extends Node2D

@export var cell_size: int = 32
@export var piece_color: Color = Color("5bc0be")

var piece_type: StringName = &"T"
var rotation_index: int = 0
var grid_position: Vector2i = Vector2i(3, 1)
var preview_cells: Array[Vector2i] = [
	Vector2i(1, 0),
	Vector2i(0, 1),
	Vector2i(1, 1),
	Vector2i(2, 1),
]


func _ready() -> void:
	queue_redraw()


func _draw() -> void:
	for cell in preview_cells:
		var rect := Rect2(Vector2(cell) * cell_size, Vector2.ONE * cell_size)
		draw_rect(rect, piece_color, true)
		draw_rect(rect, Color.WHITE, false, 2.0)
