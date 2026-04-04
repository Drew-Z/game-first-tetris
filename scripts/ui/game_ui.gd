extends VBoxContainer

signal restart_requested

@onready var stage_label: Label = $StageLabel
@onready var status_label: Label = $StatusLabel
@onready var data_label: Label = $DataLabel
@onready var restart_button: Button = $RestartButton


func _ready() -> void:
	restart_button.pressed.connect(_on_restart_button_pressed)


func show_structure_mode(columns: int, rows: int) -> void:
	stage_label.text = "标准俄罗斯方块骨架 %d x %d" % [columns, rows]
	status_label.text = "当前支持静态格子碰撞、左右移动、自动下落、软降、Hard Drop、基础旋转、触底锁定、继续生成，以及出生判定失败后的结束状态。"
	restart_button.disabled = true


func show_piece_runtime_summary(
	piece_id: StringName,
	next_piece_id: StringName,
	origin: Vector2i,
	rotation_index: int,
	is_falling: bool,
	locked_count: int,
	score: int
) -> void:
	var fall_status := "下落中" if is_falling else "已到底停止"
	restart_button.disabled = true
	data_label.text = "活动方块：%s，下一个：%s，位置：%s，旋转：r%d，状态：%s，已锁定数量：%d，分数：%d" % [
		piece_id,
		next_piece_id,
		origin,
		rotation_index,
		fall_status,
		locked_count,
		score,
	]


func show_game_over_summary(locked_count: int, score: int) -> void:
	restart_button.disabled = false
	data_label.text = "游戏结束：出生位置被静态格子占用。已锁定数量：%d，分数：%d，当前已停止输入、下落和继续生成。" % [locked_count, score]


func _on_restart_button_pressed() -> void:
	restart_requested.emit()
