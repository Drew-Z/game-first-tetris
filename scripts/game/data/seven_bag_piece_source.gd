class_name SevenBagPieceSource
extends RefCounted

const TetrominoData := preload("res://scripts/game/data/tetromino_data.gd")

var piece_rng := RandomNumberGenerator.new()
var piece_bag: Array[StringName] = []


func _init() -> void:
	piece_rng.randomize()


func reset() -> void:
	piece_bag.clear()


func draw_next_piece_id(fallback_piece_id: StringName = &"T") -> StringName:
	if piece_bag.is_empty():
		_refill_piece_bag()

	if piece_bag.is_empty():
		return fallback_piece_id

	var next_piece: StringName = piece_bag[0]
	piece_bag.remove_at(0)
	return next_piece


func describe() -> String:
	return "SevenBag size=%d" % [piece_bag.size()]


func _refill_piece_bag() -> void:
	var remaining_piece_ids: Array[StringName] = TetrominoData.get_piece_ids()
	piece_bag.clear()

	while not remaining_piece_ids.is_empty():
		var next_index := piece_rng.randi_range(0, remaining_piece_ids.size() - 1)
		piece_bag.append(remaining_piece_ids[next_index])
		remaining_piece_ids.remove_at(next_index)
