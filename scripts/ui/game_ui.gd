extends VBoxContainer

@onready var stage_label: Label = $StageLabel
@onready var status_label: Label = $StatusLabel
@onready var data_label: Label = $DataLabel


func show_structure_mode(columns: int, rows: int) -> void:
	stage_label.text = "标准俄罗斯方块骨架 %d x %d" % [columns, rows]
	status_label.text = "当前只实现开局生成一个活动方块并正确显示。"


func show_spawn_summary(piece_id: StringName, spawn_origin: Vector2i) -> void:
	data_label.text = "已生成活动方块：%s，出生点：%s，当前仅做显示联动。" % [piece_id, spawn_origin]
