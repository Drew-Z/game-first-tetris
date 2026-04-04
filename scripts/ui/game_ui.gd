extends VBoxContainer

@onready var stage_label: Label = $StageLabel
@onready var status_label: Label = $StatusLabel


func show_structure_mode(columns: int, rows: int) -> void:
	stage_label.text = "标准俄罗斯方块骨架 %d x %d" % [columns, rows]
	status_label.text = "当前仅完成场景结构与模块边界，尚未接入玩法逻辑。"
