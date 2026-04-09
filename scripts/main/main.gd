extends Control

const GAME_ROOT_SCENE := preload("res://scenes/game/game_root.tscn")
const ULTRA_NARROW_MENU_MAX_WIDTH := 360.0
const MENU_PANEL_MIN_WIDTH := 320.0
const MENU_PANEL_COMFORTABLE_WIDTH := 420.0
const MENU_OUTER_MARGIN := 16.0

@onready var menu_overlay: Control = $MenuOverlay
@onready var mode_host: Control = $ModeHost
@onready var menu_panel: PanelContainer = $MenuOverlay/MenuScroll/MenuCenter/MenuPanel
@onready var menu_margin: MarginContainer = $MenuOverlay/MenuScroll/MenuCenter/MenuPanel/MenuMargin
@onready var menu_content: VBoxContainer = $MenuOverlay/MenuScroll/MenuCenter/MenuPanel/MenuMargin/MenuContent
@onready var title_label: Label = $MenuOverlay/MenuScroll/MenuCenter/MenuPanel/MenuMargin/MenuContent/TitleLabel
@onready var subtitle_label: Label = $MenuOverlay/MenuScroll/MenuCenter/MenuPanel/MenuMargin/MenuContent/SubtitleLabel
@onready var mode_select_group: VBoxContainer = $MenuOverlay/MenuScroll/MenuCenter/MenuPanel/MenuMargin/MenuContent/ModeSelectGroup
@onready var rogue_select_group: VBoxContainer = $MenuOverlay/MenuScroll/MenuCenter/MenuPanel/MenuMargin/MenuContent/RogueSelectGroup
@onready var rogue_select_title: Label = $MenuOverlay/MenuScroll/MenuCenter/MenuPanel/MenuMargin/MenuContent/RogueSelectGroup/RogueSelectTitle
@onready var rogue_select_hint: Label = $MenuOverlay/MenuScroll/MenuCenter/MenuPanel/MenuMargin/MenuContent/RogueSelectGroup/RogueSelectHint
@onready var classic_button: Button = $MenuOverlay/MenuScroll/MenuCenter/MenuPanel/MenuMargin/MenuContent/ModeSelectGroup/ClassicButton
@onready var rogue_button: Button = $MenuOverlay/MenuScroll/MenuCenter/MenuPanel/MenuMargin/MenuContent/ModeSelectGroup/RogueButton
@onready var hard_drop_bonus_button: Button = $MenuOverlay/MenuScroll/MenuCenter/MenuPanel/MenuMargin/MenuContent/RogueSelectGroup/HardDropBonusButton
@onready var line_clear_bonus_button: Button = $MenuOverlay/MenuScroll/MenuCenter/MenuPanel/MenuMargin/MenuContent/RogueSelectGroup/LineClearBonusButton
@onready var spawn_protection_button: Button = $MenuOverlay/MenuScroll/MenuCenter/MenuPanel/MenuMargin/MenuContent/RogueSelectGroup/SpawnProtectionButton
@onready var back_button: Button = $MenuOverlay/MenuScroll/MenuCenter/MenuPanel/MenuMargin/MenuContent/RogueSelectGroup/BackButton
@onready var note_label: Label = $MenuOverlay/MenuScroll/MenuCenter/MenuPanel/MenuMargin/MenuContent/NoteLabel


func _ready() -> void:
	_show_mode_select()
	_apply_menu_layout()
	classic_button.pressed.connect(_on_classic_button_pressed)
	rogue_button.pressed.connect(_on_rogue_button_pressed)
	hard_drop_bonus_button.pressed.connect(_on_hard_drop_bonus_button_pressed)
	line_clear_bonus_button.pressed.connect(_on_line_clear_bonus_button_pressed)
	spawn_protection_button.pressed.connect(_on_spawn_protection_button_pressed)
	back_button.pressed.connect(_on_back_button_pressed)


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_apply_menu_layout()


func _on_classic_button_pressed() -> void:
	_launch_mode(&"classic", &"")


func _on_rogue_button_pressed() -> void:
	_show_rogue_select()


func _on_hard_drop_bonus_button_pressed() -> void:
	_launch_mode(&"rogue", &"hard_drop_bonus")


func _on_line_clear_bonus_button_pressed() -> void:
	_launch_mode(&"rogue", &"line_clear_bonus")


func _on_spawn_protection_button_pressed() -> void:
	_launch_mode(&"rogue", &"spawn_protection")


func _on_back_button_pressed() -> void:
	_show_mode_select()


func _launch_mode(mode_id: StringName, rogue_upgrade_id: StringName) -> void:
	for child in mode_host.get_children():
		child.queue_free()

	var game_root := GAME_ROOT_SCENE.instantiate()
	var game_manager: Node = game_root.get_node("GameManager")
	if game_manager != null:
		if game_manager.has_signal("return_to_menu_requested") and not game_manager.is_connected("return_to_menu_requested", Callable(self, "_on_return_to_menu_requested")):
			game_manager.connect("return_to_menu_requested", Callable(self, "_on_return_to_menu_requested"))
		if game_manager.has_method("set_mode_setup"):
			game_manager.call("set_mode_setup", mode_id, rogue_upgrade_id)
		elif game_manager.has_method("set_entry_mode"):
			game_manager.call("set_entry_mode", mode_id)
		else:
			game_manager.set("entry_mode", mode_id)

	if game_root is Control:
		game_root.set_anchors_preset(Control.PRESET_FULL_RECT)
		game_root.offset_left = 0.0
		game_root.offset_top = 0.0
		game_root.offset_right = 0.0
		game_root.offset_bottom = 0.0

	mode_host.add_child(game_root)
	menu_overlay.visible = false


func _on_return_to_menu_requested() -> void:
	for child in mode_host.get_children():
		child.queue_free()

	_show_mode_select()


func _show_mode_select() -> void:
	menu_overlay.visible = true
	mode_select_group.visible = true
	rogue_select_group.visible = false


func _show_rogue_select() -> void:
	menu_overlay.visible = true
	mode_select_group.visible = false
	rogue_select_group.visible = true


func _apply_menu_layout() -> void:
	if menu_panel == null:
		return

	var is_ultra_narrow := size.x <= ULTRA_NARROW_MENU_MAX_WIDTH
	var available_width := maxf(size.x - MENU_OUTER_MARGIN * 2.0, 0.0)
	var target_width := clampf(
		available_width,
		MENU_PANEL_MIN_WIDTH,
		MENU_PANEL_COMFORTABLE_WIDTH
	)
	menu_panel.custom_minimum_size.x = target_width

	if menu_margin != null:
		var side_margin := 16 if is_ultra_narrow else 24
		var vertical_margin := 16 if is_ultra_narrow else 24
		menu_margin.add_theme_constant_override("margin_left", side_margin)
		menu_margin.add_theme_constant_override("margin_top", vertical_margin)
		menu_margin.add_theme_constant_override("margin_right", side_margin)
		menu_margin.add_theme_constant_override("margin_bottom", vertical_margin)

	if menu_content != null:
		menu_content.add_theme_constant_override("separation", 12 if is_ultra_narrow else 16)

	if title_label != null:
		title_label.add_theme_font_size_override("font_size", 24 if is_ultra_narrow else 28)

	if rogue_select_title != null:
		rogue_select_title.add_theme_font_size_override("font_size", 18 if is_ultra_narrow else 20)

	if subtitle_label != null:
		subtitle_label.text = "请选择进入方式。经典模式保持标准体验；Rogue 模式继续承接实验内容。" if is_ultra_narrow else "请选择进入方式。经典模式保持当前标准俄罗斯方块体验，Rogue 模式继续承载实验内容。"

	if rogue_select_hint != null:
		rogue_select_hint.text = "当前是最小强化入口；经典模式不受影响，Rogue 每局开局前先选 1 项。" if is_ultra_narrow else "当前只落第一批最小强化入口。经典模式不受影响，Rogue 模式每局开始前先选一项。"

	if note_label != null:
		note_label.text = "当前 Rogue 不改经典主循环，只先落最小强化入口。" if is_ultra_narrow else "当前 Rogue 模式不会改写经典模式主循环，只先落最小可用强化入口。"

	for button in [
		classic_button,
		rogue_button,
		hard_drop_bonus_button,
		line_clear_bonus_button,
		spawn_protection_button,
		back_button,
	]:
		if button == null:
			continue
		button.custom_minimum_size.y = 44.0 if is_ultra_narrow else 0.0
