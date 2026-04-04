extends Node

@onready var board: Node2D = $"../Layout/PlayfieldPanel/PlayfieldMargin/Playfield/Board"
@onready var active_piece: Node2D = $"../Layout/PlayfieldPanel/PlayfieldMargin/Playfield/ActivePiece"
@onready var game_ui: VBoxContainer = $"../Layout/SidebarPanel/GameUI"


func _ready() -> void:
	_sync_structure_mode()


func _sync_structure_mode() -> void:
	if board.has_method("get_spawn_preview_position"):
		active_piece.position = board.call("get_spawn_preview_position")

	if active_piece.get("cell_size") != null and board.get("cell_size") != null:
		active_piece.set("cell_size", board.get("cell_size"))

	if game_ui.has_method("show_structure_mode"):
		game_ui.call("show_structure_mode", board.get("columns"), board.get("rows"))
