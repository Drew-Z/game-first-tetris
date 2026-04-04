class_name TetrominoData
extends RefCounted

const PIECE_IDS: Array[StringName] = [&"I", &"O", &"T", &"S", &"Z", &"J", &"L"]

const DEFINITIONS := {
	&"I": {
		"id": &"I",
		"color": Color("00bbf9"),
		"spawn_box_size": 4,
		"rotations": [
			[Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1)],
			[Vector2i(2, 0), Vector2i(2, 1), Vector2i(2, 2), Vector2i(2, 3)],
			[Vector2i(0, 2), Vector2i(1, 2), Vector2i(2, 2), Vector2i(3, 2)],
			[Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2), Vector2i(1, 3)],
		],
	},
	&"O": {
		"id": &"O",
		"color": Color("fee440"),
		"spawn_box_size": 4,
		"rotations": [
			[Vector2i(1, 0), Vector2i(2, 0), Vector2i(1, 1), Vector2i(2, 1)],
			[Vector2i(1, 0), Vector2i(2, 0), Vector2i(1, 1), Vector2i(2, 1)],
			[Vector2i(1, 0), Vector2i(2, 0), Vector2i(1, 1), Vector2i(2, 1)],
			[Vector2i(1, 0), Vector2i(2, 0), Vector2i(1, 1), Vector2i(2, 1)],
		],
	},
	&"T": {
		"id": &"T",
		"color": Color("9b5de5"),
		"spawn_box_size": 4,
		"rotations": [
			[Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)],
			[Vector2i(1, 0), Vector2i(1, 1), Vector2i(2, 1), Vector2i(1, 2)],
			[Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(1, 2)],
			[Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 2)],
		],
	},
	&"S": {
		"id": &"S",
		"color": Color("00f5d4"),
		"spawn_box_size": 4,
		"rotations": [
			[Vector2i(1, 0), Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1)],
			[Vector2i(1, 0), Vector2i(1, 1), Vector2i(2, 1), Vector2i(2, 2)],
			[Vector2i(1, 1), Vector2i(2, 1), Vector2i(0, 2), Vector2i(1, 2)],
			[Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 2)],
		],
	},
	&"Z": {
		"id": &"Z",
		"color": Color("ef476f"),
		"spawn_box_size": 4,
		"rotations": [
			[Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(2, 1)],
			[Vector2i(2, 0), Vector2i(1, 1), Vector2i(2, 1), Vector2i(1, 2)],
			[Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 2), Vector2i(2, 2)],
			[Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(0, 2)],
		],
	},
	&"J": {
		"id": &"J",
		"color": Color("3a86ff"),
		"spawn_box_size": 4,
		"rotations": [
			[Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)],
			[Vector2i(1, 0), Vector2i(2, 0), Vector2i(1, 1), Vector2i(1, 2)],
			[Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(2, 2)],
			[Vector2i(1, 0), Vector2i(1, 1), Vector2i(0, 2), Vector2i(1, 2)],
		],
	},
	&"L": {
		"id": &"L",
		"color": Color("fb8500"),
		"spawn_box_size": 4,
		"rotations": [
			[Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)],
			[Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2), Vector2i(2, 2)],
			[Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(0, 2)],
			[Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2)],
		],
	},
}


static func get_piece_ids() -> Array[StringName]:
	return PIECE_IDS.duplicate()


static func get_definition(piece_id: StringName) -> Dictionary:
	return DEFINITIONS.get(piece_id, {})


static func get_spawn_box_size(piece_id: StringName) -> int:
	var definition := get_definition(piece_id)
	return int(definition.get("spawn_box_size", 4))


static func get_color(piece_id: StringName) -> Color:
	var definition := get_definition(piece_id)
	return definition.get("color", Color.WHITE)


static func get_local_cells(piece_id: StringName, rotation_index: int = 0) -> Array[Vector2i]:
	var definition := get_definition(piece_id)
	if definition.is_empty():
		return []

	var rotations: Array = definition["rotations"]
	var normalized_rotation := posmod(rotation_index, rotations.size())
	var cells: Array = rotations[normalized_rotation]
	var local_cells: Array[Vector2i] = []

	for cell in cells:
		local_cells.append(cell)

	return local_cells


static func get_global_cells(
	piece_id: StringName,
	origin: Vector2i,
	rotation_index: int = 0
) -> Array[Vector2i]:
	var board_cells: Array[Vector2i] = []

	for local_cell in get_local_cells(piece_id, rotation_index):
		board_cells.append(origin + local_cell)

	return board_cells
