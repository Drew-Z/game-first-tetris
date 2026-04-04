extends VBoxContainer

@onready var stage_label: Label = $StageLabel
@onready var status_label: Label = $StatusLabel
@onready var data_label: Label = $DataLabel


func show_structure_mode(columns: int, rows: int) -> void:
	stage_label.text = "标准俄罗斯方块骨架 %d x %d" % [columns, rows]
	status_label.text = "当前支持左右移动、自动下落，以及到底停止。"


func show_piece_runtime_summary(piece_id: StringName, origin: Vector2i, is_falling: bool) -> void:
	var fall_status := "下落中" if is_falling else "已到底停止"
	data_label.text = "活动方块：%s，位置：%s，状态：%s" % [piece_id, origin, fall_status]
