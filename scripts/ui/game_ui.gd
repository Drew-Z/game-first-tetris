extends VBoxContainer

signal restart_requested
signal pause_requested
signal menu_requested
signal rogue_upgrade_selected(rogue_upgrade_id: StringName)

@onready var stage_label: Label = $StageLabel
@onready var status_label: Label = $StatusLabel
@onready var current_state_label: Label = $CurrentStateLabel
@onready var stats_label: Label = $StatsLabel
@onready var rogue_header: Label = $RogueHeader
@onready var rogue_status_label: Label = $RogueStatusLabel
@onready var rogue_effects_label: Label = $RogueEffectsLabel
@onready var rogue_choice_panel: VBoxContainer = $RogueChoicePanel
@onready var rogue_choice_title: Label = $RogueChoicePanel/RogueChoiceTitle
@onready var rogue_choice_hint: Label = $RogueChoicePanel/RogueChoiceHint
@onready var rogue_hard_drop_button: Button = $RogueChoicePanel/RogueChoiceButtons/HardDropBonusButton
@onready var rogue_line_clear_button: Button = $RogueChoicePanel/RogueChoiceButtons/LineClearBonusButton
@onready var rogue_spawn_protection_button: Button = $RogueChoicePanel/RogueChoiceButtons/SpawnProtectionButton
@onready var pause_button: Button = $SessionButtons/PauseButton
@onready var restart_button: Button = $RestartButton
@onready var menu_button: Button = $SessionButtons/MenuButton
@onready var help_button: Button = $SessionButtons/HelpButton
@onready var help_panel: VBoxContainer = $HelpPanel
@onready var help_text: Label = $HelpPanel/HelpText
@onready var next_preview: Control = $PreviewRow/NextPanel/NextPreview
@onready var hold_preview: Control = $PreviewRow/HoldPanel/HoldPreview
@onready var next_piece_label: Label = $PreviewRow/NextPanel/NextPieceLabel
@onready var hold_piece_label: Label = $PreviewRow/HoldPanel/HoldPieceLabel
@onready var hint_header: Label = $HintHeader
@onready var hint_label: Label = $HintLabel
@onready var system_label: Label = $SystemLabel

var current_mode_id: StringName = &"classic"
var current_mode_display_name: String = "经典模式"
var is_session_paused: bool = false
var is_session_game_over: bool = false
var is_choice_prompt_open: bool = false


func _ready() -> void:
	pause_button.pressed.connect(_on_pause_button_pressed)
	restart_button.pressed.connect(_on_restart_button_pressed)
	menu_button.pressed.connect(_on_menu_button_pressed)
	help_button.pressed.connect(_on_help_button_pressed)
	rogue_hard_drop_button.pressed.connect(_on_rogue_hard_drop_pressed)
	rogue_line_clear_button.pressed.connect(_on_rogue_line_clear_pressed)
	rogue_spawn_protection_button.pressed.connect(_on_rogue_spawn_protection_pressed)
	_set_help_panel_visible(false)
	set_rogue_choice_prompt(false)
	_update_focus_behavior(false, false, false)


func show_structure_mode(
	columns: int,
	rows: int,
	mode_id: StringName = &"classic",
	mode_display_name: String = "经典模式",
	mode_note: String = "",
	rogue_upgrade_display_name: String = "",
	remaining_spawn_protection_uses: int = 0,
	rogue_upgrade_effects_text: String = "",
	rogue_active_carry_over_upgrade_display_name: String = "",
	rogue_next_run_carry_over_upgrade_display_name: String = ""
) -> void:
	current_mode_id = mode_id
	current_mode_display_name = mode_display_name
	stage_label.text = mode_display_name
	status_label.text = "%d x %d 棋盘" % [columns, rows]
	current_state_label.text = "当前方块：--\n状态：等待开始\nHold：可用"
	stats_label.text = "等级：1  分数：0\n已锁定：0"
	_update_rogue_status(
		mode_id,
		rogue_upgrade_display_name,
		remaining_spawn_protection_uses,
		rogue_upgrade_effects_text,
		rogue_active_carry_over_upgrade_display_name,
		rogue_next_run_carry_over_upgrade_display_name
	)
	_set_help_visibility(false)
	_set_help_panel_visible(false)
	system_label.text = ""
	_set_preview_meta(next_piece_label, &"")
	_set_preview_meta(hold_piece_label, &"")
	set_rogue_choice_prompt(false)


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
	rogue_upgrade_effects_text: String = "",
	rogue_active_carry_over_upgrade_display_name: String = "",
	rogue_next_run_carry_over_upgrade_display_name: String = ""
) -> void:
	current_mode_id = mode_id
	current_mode_display_name = mode_display_name
	var fall_status := "下落中" if is_falling else "已到底停止"
	var hold_status := "可用" if can_hold_current_piece else "本轮已用"
	_show_preview(next_preview, next_piece_id)
	_show_preview(hold_preview, hold_piece_id)
	_set_preview_meta(next_piece_label, next_piece_id)
	_set_preview_meta(hold_piece_label, hold_piece_id)
	current_state_label.text = "当前方块：%s\n状态：%s\nHold：%s" % [
		piece_id,
		fall_status,
		hold_status,
	]
	stats_label.text = "等级：%d  分数：%d\n已锁定：%d" % [
		level,
		score,
		locked_count,
	]
	_update_rogue_status(
		mode_id,
		rogue_upgrade_display_name,
		remaining_spawn_protection_uses,
		rogue_upgrade_effects_text,
		rogue_active_carry_over_upgrade_display_name,
		rogue_next_run_carry_over_upgrade_display_name
	)
	_set_help_visibility(false)
	system_label.text = _get_runtime_system_text(is_falling, mode_note)


func show_game_over_summary(
	locked_count: int,
	score: int,
	level: int,
	mode_id: StringName = &"classic",
	mode_display_name: String = "经典模式",
	mode_note: String = "",
	rogue_upgrade_display_name: String = "",
	remaining_spawn_protection_uses: int = 0,
	rogue_upgrade_effects_text: String = "",
	rogue_active_carry_over_upgrade_display_name: String = "",
	rogue_next_run_carry_over_upgrade_display_name: String = ""
) -> void:
	current_mode_id = mode_id
	current_mode_display_name = mode_display_name
	if next_preview.has_method("clear_preview"):
		next_preview.call("clear_preview")
	if hold_preview.has_method("clear_preview"):
		hold_preview.call("clear_preview")
	_set_preview_meta(next_piece_label, &"")
	_set_preview_meta(hold_piece_label, &"")
	current_state_label.text = "当前方块：--\n状态：游戏结束\nHold：不可用"
	stats_label.text = "等级：%d  分数：%d\n已锁定：%d" % [level, score, locked_count]
	_update_rogue_status(
		mode_id,
		rogue_upgrade_display_name,
		remaining_spawn_protection_uses,
		rogue_upgrade_effects_text,
		rogue_active_carry_over_upgrade_display_name,
		rogue_next_run_carry_over_upgrade_display_name
	)
	_set_help_visibility(true, "Restart 重新开局\nMain Menu 返回菜单")
	system_label.text = "游戏结束"


func _on_restart_button_pressed() -> void:
	restart_requested.emit()


func _on_pause_button_pressed() -> void:
	pause_requested.emit()


func _on_menu_button_pressed() -> void:
	menu_requested.emit()


func _on_help_button_pressed() -> void:
	_set_help_panel_visible(not help_panel.visible)


func _on_rogue_hard_drop_pressed() -> void:
	rogue_upgrade_selected.emit(&"hard_drop_bonus")


func _on_rogue_line_clear_pressed() -> void:
	rogue_upgrade_selected.emit(&"line_clear_bonus")


func _on_rogue_spawn_protection_pressed() -> void:
	rogue_upgrade_selected.emit(&"spawn_protection")


func set_rogue_choice_prompt(is_visible: bool, title: String = "", hint: String = "") -> void:
	var is_rogue_mode := current_mode_id == &"rogue"
	rogue_choice_panel.visible = is_rogue_mode

	if not is_rogue_mode:
		is_choice_prompt_open = false
		rogue_choice_title.text = "Rogue 选择"
		rogue_choice_hint.text = ""
		_set_rogue_choice_buttons_visible(false)
		rogue_choice_panel.visible = false
		_set_help_visibility(false)
		_update_focus_behavior(is_session_paused, is_session_game_over, false)
		return

	rogue_choice_panel.visible = true

	if not is_visible:
		is_choice_prompt_open = false
		rogue_choice_title.text = "Rogue 选择进度"
		rogue_choice_hint.text = "当前无待选强化。\n下一轮到达阈值后，会在这里出现 3 选 1。"
		_set_rogue_choice_buttons_visible(false)
		_set_help_visibility(false)
		_update_focus_behavior(is_session_paused, is_session_game_over, false)
		return

	if help_panel.visible:
		_set_help_panel_visible(false)

	rogue_choice_title.text = title
	rogue_choice_hint.text = hint
	_set_rogue_choice_buttons_visible(true)
	_set_help_visibility(true, "↑ ↓ 选择强化\nEnter / Space 确认")
	is_choice_prompt_open = true
	_update_focus_behavior(is_session_paused, is_session_game_over, true)


func set_session_controls(is_paused: bool, can_pause: bool, is_game_over: bool) -> void:
	is_session_paused = is_paused
	is_session_game_over = is_game_over
	pause_button.text = "Resume" if is_paused else "Pause"
	pause_button.disabled = not can_pause
	restart_button.disabled = false
	menu_button.disabled = false
	_update_focus_behavior(is_paused, is_game_over, is_choice_prompt_open)

	if is_game_over:
		pause_button.text = "Pause"
		pause_button.disabled = true
	elif is_paused:
		_set_help_visibility(true, "Resume 继续\nRestart 重开\nMain Menu 返回菜单")
		system_label.text = "已暂停"


func _show_preview(preview_node: Control, piece_id: StringName) -> void:
	if preview_node == null or not preview_node.has_method("show_piece"):
		return

	preview_node.call("show_piece", piece_id)


func _set_preview_meta(label_node: Label, piece_id: StringName) -> void:
	if label_node == null:
		return

	if piece_id == &"":
		label_node.text = "形状：--"
		return

	label_node.text = "形状：%s" % [piece_id]


func _update_rogue_status(
	mode_id: StringName,
	rogue_upgrade_display_name: String,
	remaining_spawn_protection_uses: int,
	rogue_upgrade_effects_text: String = "",
	rogue_active_carry_over_upgrade_display_name: String = "",
	rogue_next_run_carry_over_upgrade_display_name: String = ""
) -> void:
	var is_rogue_mode := mode_id == &"rogue"
	rogue_header.visible = is_rogue_mode
	rogue_status_label.visible = is_rogue_mode
	rogue_effects_label.visible = is_rogue_mode

	if not is_rogue_mode:
		rogue_status_label.text = ""
		rogue_effects_label.text = ""
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

	var active_carry_text := "无"
	if rogue_active_carry_over_upgrade_display_name != "":
		active_carry_text = rogue_active_carry_over_upgrade_display_name

	var next_carry_text := "本局结束后生成"
	if rogue_next_run_carry_over_upgrade_display_name != "":
		next_carry_text = rogue_next_run_carry_over_upgrade_display_name

	rogue_status_label.text = "已选强化：%s\n本局带入：%s\n下一局带入：%s" % [
		upgrade_summary,
		active_carry_text,
		next_carry_text,
	]
	rogue_effects_label.text = "强化效果：\n%s\n出生保护：%s" % [effects_text, protection_text]


func _update_focus_behavior(is_paused: bool, is_game_over: bool, is_choice_prompt_visible: bool) -> void:
	var allow_session_button_focus := is_paused or is_game_over
	_set_button_focus_enabled(pause_button, allow_session_button_focus and not pause_button.disabled)
	_set_button_focus_enabled(restart_button, allow_session_button_focus and not restart_button.disabled)
	_set_button_focus_enabled(menu_button, allow_session_button_focus and not menu_button.disabled)
	_set_button_focus_enabled(help_button, allow_session_button_focus or help_panel.visible)

	_set_button_focus_enabled(rogue_hard_drop_button, is_choice_prompt_visible)
	_set_button_focus_enabled(rogue_line_clear_button, is_choice_prompt_visible)
	_set_button_focus_enabled(rogue_spawn_protection_button, is_choice_prompt_visible)

	if is_choice_prompt_visible:
		rogue_hard_drop_button.grab_focus()
		return

	if allow_session_button_focus:
		if not pause_button.disabled:
			pause_button.grab_focus()
		elif not restart_button.disabled:
			restart_button.grab_focus()
		elif not menu_button.disabled:
			menu_button.grab_focus()
		return

	_release_hud_button_focus()


func _set_button_focus_enabled(button: Button, is_enabled: bool) -> void:
	if button == null:
		return

	button.focus_mode = Control.FOCUS_ALL if is_enabled else Control.FOCUS_NONE
	if not is_enabled and button.has_focus():
		button.release_focus()


func _release_hud_button_focus() -> void:
	for button in [
		pause_button,
		restart_button,
		menu_button,
		help_button,
		rogue_hard_drop_button,
		rogue_line_clear_button,
		rogue_spawn_protection_button,
	]:
		if button != null and button.has_focus():
			button.release_focus()


func _set_rogue_choice_buttons_visible(is_visible: bool) -> void:
	rogue_hard_drop_button.visible = is_visible
	rogue_line_clear_button.visible = is_visible
	rogue_spawn_protection_button.visible = is_visible


func _get_runtime_system_text(is_falling: bool, mode_note: String) -> String:
	if current_mode_id == &"rogue" and rogue_hard_drop_button.visible:
		return "Rogue 强化进行中"

	if not is_falling:
		return "等待锁定结算"

	return "游戏进行中"


func _set_help_visibility(is_visible: bool, text: String = "") -> void:
	hint_header.visible = is_visible
	hint_label.visible = is_visible

	if is_visible:
		hint_label.text = text


func _set_help_panel_visible(is_visible: bool) -> void:
	help_panel.visible = is_visible
	if not is_visible:
		help_text.text = ""
		_update_focus_behavior(is_session_paused, is_session_game_over, is_choice_prompt_open)
		return

	help_text.text = _get_help_panel_text()
	help_button.grab_focus()
	_update_focus_behavior(is_session_paused, is_session_game_over, is_choice_prompt_open)


func _get_help_panel_text() -> String:
	var sections: Array[String] = [
		"操作：← → 移动，↑ 旋转，↓ 软降，Space 硬降，C Hold，Esc 暂停。",
		"流程：方块下落、锁定、消行、继续生成；游戏结束后可 Restart 或返回主菜单。",
	]

	if current_mode_id == &"rogue":
		sections.append("Rogue：开局前与局内会触发 3 选 1；已选强化与带入结果会显示在 Rogue 信息区。")
	else:
		sections.append("经典模式：保持标准主循环，不包含 Rogue 强化与局间带入。")

	return "\n\n".join(sections)
