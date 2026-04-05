extends VBoxContainer

signal restart_requested
signal rogue_upgrade_selected(rogue_upgrade_id: StringName)

@onready var stage_label: Label = $StageLabel
@onready var status_label: Label = $StatusLabel
@onready var current_state_label: Label = $CurrentStateLabel
@onready var stats_label: Label = $StatsLabel
@onready var rogue_header: Label = $RogueHeader
@onready var rogue_status_label: Label = $RogueStatusLabel
@onready var rogue_choice_panel: VBoxContainer = $RogueChoicePanel
@onready var rogue_choice_title: Label = $RogueChoicePanel/RogueChoiceTitle
@onready var rogue_choice_hint: Label = $RogueChoicePanel/RogueChoiceHint
@onready var rogue_hard_drop_button: Button = $RogueChoicePanel/RogueChoiceButtons/HardDropBonusButton
@onready var rogue_line_clear_button: Button = $RogueChoicePanel/RogueChoiceButtons/LineClearBonusButton
@onready var rogue_spawn_protection_button: Button = $RogueChoicePanel/RogueChoiceButtons/SpawnProtectionButton
@onready var restart_button: Button = $RestartButton
@onready var next_preview: Control = $PreviewRow/NextPanel/NextPreview
@onready var hold_preview: Control = $PreviewRow/HoldPanel/HoldPreview
@onready var next_piece_label: Label = $PreviewRow/NextPanel/NextPieceLabel
@onready var hold_piece_label: Label = $PreviewRow/HoldPanel/HoldPieceLabel
@onready var hint_label: Label = $HintLabel
@onready var system_label: Label = $SystemLabel


func _ready() -> void:
	restart_button.pressed.connect(_on_restart_button_pressed)
	rogue_hard_drop_button.pressed.connect(_on_rogue_hard_drop_pressed)
	rogue_line_clear_button.pressed.connect(_on_rogue_line_clear_pressed)
	rogue_spawn_protection_button.pressed.connect(_on_rogue_spawn_protection_pressed)
	set_rogue_choice_prompt(false)


func show_structure_mode(
	columns: int,
	rows: int,
	mode_id: StringName = &"classic",
	mode_display_name: String = "经典模式",
	mode_note: String = "",
	rogue_upgrade_display_name: String = "",
	remaining_spawn_protection_uses: int = 0,
	rogue_upgrade_effects_text: String = ""
) -> void:
	stage_label.text = "%s %d x %d" % [mode_display_name, columns, rows]
	status_label.text = "当前支持静态格子碰撞、左右移动、自动下落、软降、Hard Drop、Hold、基础旋转、触底锁定、继续生成，以及出生判定失败后的结束状态。默认按键：Space=Hard Drop，C=Hold。%s" % [mode_note]
	restart_button.disabled = true
	current_state_label.text = "活动方块状态将在这里显示。"
	stats_label.text = "分数与等级将在这里显示。"
	_update_rogue_status(mode_id, rogue_upgrade_display_name, remaining_spawn_protection_uses, rogue_upgrade_effects_text)
	hint_label.text = "操作提示：左右移动、上旋转、下软降、Space 硬降、C Hold。"
	system_label.text = "状态提示：当前游戏可正常运行。当前模式：%s。" % [mode_display_name]
	_set_preview_meta(next_piece_label, &"")
	_set_preview_meta(hold_piece_label, &"")


func show_piece_runtime_summary(
	piece_id: StringName,
	next_piece_id: StringName,
	hold_piece_id: StringName,
	can_hold_current_piece: bool,
	origin: Vector2i,
	rotation_index: int,
	is_falling: bool,
	locked_count: int,
	score: int,
	level: int,
	mode_id: StringName = &"classic",
	mode_display_name: String = "经典模式",
	mode_note: String = "",
	rogue_upgrade_display_name: String = "",
	remaining_spawn_protection_uses: int = 0,
	rogue_upgrade_effects_text: String = ""
) -> void:
	var fall_status := "下落中" if is_falling else "已到底停止"
	var hold_status := "可用" if can_hold_current_piece else "本轮已用"
	restart_button.disabled = true
	_show_preview(next_preview, next_piece_id)
	_show_preview(hold_preview, hold_piece_id)
	_set_preview_meta(next_piece_label, next_piece_id)
	_set_preview_meta(hold_piece_label, hold_piece_id)
	current_state_label.text = "活动方块：%s，位置：%s，旋转：r%d，状态：%s，Hold 状态：%s" % [
		piece_id,
		origin,
		rotation_index,
		fall_status,
		hold_status,
	]
	stats_label.text = "等级：%d，分数：%d，已锁定数量：%d" % [
		level,
		score,
		locked_count,
	]
	_update_rogue_status(mode_id, rogue_upgrade_display_name, remaining_spawn_protection_uses, rogue_upgrade_effects_text)
	hint_label.text = "操作提示：左右移动、上旋转、下软降、Space 硬降、C Hold。"
	system_label.text = "状态提示：当前游戏进行中。当前模式：%s。%s" % [mode_display_name, mode_note]


func show_game_over_summary(
	locked_count: int,
	score: int,
	level: int,
	mode_id: StringName = &"classic",
	mode_display_name: String = "经典模式",
	mode_note: String = "",
	rogue_upgrade_display_name: String = "",
	remaining_spawn_protection_uses: int = 0,
	rogue_upgrade_effects_text: String = ""
) -> void:
	restart_button.disabled = false
	if next_preview.has_method("clear_preview"):
		next_preview.call("clear_preview")
	if hold_preview.has_method("clear_preview"):
		hold_preview.call("clear_preview")
	_set_preview_meta(next_piece_label, &"")
	_set_preview_meta(hold_piece_label, &"")
	current_state_label.text = "当前状态：无活动方块。"
	stats_label.text = "等级：%d，分数：%d，已锁定数量：%d" % [level, score, locked_count]
	_update_rogue_status(mode_id, rogue_upgrade_display_name, remaining_spawn_protection_uses, rogue_upgrade_effects_text)
	hint_label.text = "操作提示：可点击 Restart 重新开始。"
	system_label.text = "状态提示：游戏结束，出生位置被静态格子占用。当前已停止输入、下落和继续生成。当前模式：%s。%s" % [mode_display_name, mode_note]


func _on_restart_button_pressed() -> void:
	restart_requested.emit()


func _on_rogue_hard_drop_pressed() -> void:
	rogue_upgrade_selected.emit(&"hard_drop_bonus")


func _on_rogue_line_clear_pressed() -> void:
	rogue_upgrade_selected.emit(&"line_clear_bonus")


func _on_rogue_spawn_protection_pressed() -> void:
	rogue_upgrade_selected.emit(&"spawn_protection")


func set_rogue_choice_prompt(is_visible: bool, title: String = "", hint: String = "") -> void:
	rogue_choice_panel.visible = is_visible

	if not is_visible:
		rogue_choice_title.text = "Rogue 模式：局内强化 3 选 1"
		rogue_choice_hint.text = ""
		return

	rogue_choice_title.text = title
	rogue_choice_hint.text = hint


func _show_preview(preview_node: Control, piece_id: StringName) -> void:
	if preview_node == null or not preview_node.has_method("show_piece"):
		return

	preview_node.call("show_piece", piece_id)


func _set_preview_meta(label_node: Label, piece_id: StringName) -> void:
	if label_node == null:
		return

	if piece_id == &"":
		label_node.text = "形状：空"
		return

	label_node.text = "形状：%s" % [piece_id]


func _update_rogue_status(
	mode_id: StringName,
	rogue_upgrade_display_name: String,
	remaining_spawn_protection_uses: int,
	rogue_upgrade_effects_text: String = ""
) -> void:
	var is_rogue_mode := mode_id == &"rogue"
	rogue_header.visible = is_rogue_mode
	rogue_status_label.visible = is_rogue_mode

	if not is_rogue_mode:
		rogue_status_label.text = ""
		return

	var upgrade_summary := rogue_upgrade_display_name
	if upgrade_summary == "":
		upgrade_summary = "本局尚未获得 Rogue 强化"

	var protection_text := "未启用"
	if remaining_spawn_protection_uses > 0:
		protection_text = "%d 次" % [remaining_spawn_protection_uses]

	var effects_text := rogue_upgrade_effects_text
	if effects_text == "":
		effects_text = "本局尚未获得 Rogue 强化。"

	rogue_status_label.text = "当前模式：Rogue 模式\n已选强化：%s\n出生保护剩余：%s\n强化结果：\n%s" % [
		upgrade_summary,
		protection_text,
		effects_text,
	]
