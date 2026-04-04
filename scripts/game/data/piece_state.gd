class_name PieceState
extends RefCounted

const TetrominoData := preload("res://scripts/game/data/tetromino_data.gd")

var piece_id: StringName
var rotation_index: int
var origin: Vector2i


func _init(
	new_piece_id: StringName = &"T",
	new_origin: Vector2i = Vector2i(3, 0),
	new_rotation_index: int = 0
) -> void:
	piece_id = new_piece_id
	rotation_index = new_rotation_index
	origin = new_origin


func get_local_cells() -> Array[Vector2i]:
	return TetrominoData.get_local_cells(piece_id, rotation_index)


func get_board_cells() -> Array[Vector2i]:
	return TetrominoData.get_global_cells(piece_id, origin, rotation_index)


func get_color() -> Color:
	return TetrominoData.get_color(piece_id)


func describe() -> String:
	return "%s r%d origin=%s" % [piece_id, rotation_index, origin]
