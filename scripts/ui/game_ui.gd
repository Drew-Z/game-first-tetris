extends VBoxContainer

@onready var stage_label: Label = $StageLabel
@onready var status_label: Label = $StatusLabel
@onready var data_label: Label = $DataLabel


func show_structure_mode(columns: int, rows: int) -> void:
	stage_label.text = "标准俄罗斯方块骨架 %d x %d" % [columns, rows]
	status_label.text = "当前仅完成场景结构与模块边界，尚未接入玩法逻辑。"


func show_data_model_summary(spawn_origin: Vector2i, preview_piece_id: StringName) -> void:
	data_label.text = "数据结构：cells[row][column]，spawn=%s，preview=%s r0" % [spawn_origin, preview_piece_id]
