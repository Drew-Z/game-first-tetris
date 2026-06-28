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
	_install_showcase_background()
	_apply_showcase_skin()
	_show_mode_select()
	_apply_menu_layout()
	classic_button.pressed.connect(_on_classic_button_pressed)
	rogue_button.pressed.connect(_on_rogue_button_pressed)
	hard_drop_bonus_button.pressed.connect(_on_hard_drop_bonus_button_pressed)
	line_clear_bonus_button.pressed.connect(_on_line_clear_bonus_button_pressed)
	spawn_protection_button.pressed.connect(_on_spawn_protection_button_pressed)
	back_button.pressed.connect(_on_back_button_pressed)
	if OS.get_cmdline_user_args().has("--autoplay"):
		call_deferred("_launch_mode", &"classic", &"")


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
	title_label.text = "FIRST TETRIS"
	note_label.text = "选择一条试玩路线。经典模式用于展示核心规则，Rogue 模式展示轻量强化入口。"


func _show_rogue_select() -> void:
	menu_overlay.visible = true
	mode_select_group.visible = false
	rogue_select_group.visible = true
	title_label.text = "ROGUE ROUTE"
	note_label.text = "先选一个开局强化，再进入同一套俄罗斯方块核心循环。"


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
		subtitle_label.text = "经典规则与轻量 Rogue 强化，压缩成一局可试玩展示。" if is_ultra_narrow else "经典规则、Hold、Next 预览与轻量 Rogue 强化，压缩成一局可试玩展示。"

	if rogue_select_hint != null:
		rogue_select_hint.text = "三选一开局强化；经典模式不受影响。" if is_ultra_narrow else "三选一开局强化，只改变得分与保护节奏，不改写经典主循环。"

	if note_label != null:
		note_label.add_theme_font_size_override("font_size", 14 if is_ultra_narrow else 16)

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


func _install_showcase_background() -> void:
	var backdrop := ColorRect.new()
	backdrop.name = "ShowcaseBackdrop"
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	backdrop.color = Color(0.025, 0.035, 0.065, 1.0)
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(backdrop)
	move_child(backdrop, 0)

	for i in range(10):
		var strip := ColorRect.new()
		strip.name = "ShowcaseSignal%02d" % i
		strip.mouse_filter = Control.MOUSE_FILTER_IGNORE
		strip.color = Color(0.16, 0.70, 0.88, 0.08 + float(i % 3) * 0.025)
		strip.set_anchors_preset(Control.PRESET_TOP_WIDE)
		strip.offset_left = -40.0 + float(i * 38)
		strip.offset_right = strip.offset_left + 2.0
		strip.offset_top = 0.0
		strip.offset_bottom = 720.0
		add_child(strip)
		move_child(strip, 1)


func _apply_showcase_skin() -> void:
	if menu_panel != null:
		menu_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.055, 0.075, 0.12, 0.96), Color(0.35, 0.78, 0.92, 0.78), 2))

	if title_label != null:
		title_label.add_theme_color_override("font_color", Color(0.96, 0.98, 1.0))
		title_label.add_theme_font_size_override("font_size", 32)

	for label in [subtitle_label, rogue_select_hint, note_label]:
		if label == null:
			continue
		label.add_theme_color_override("font_color", Color(0.76, 0.84, 0.92))

	if rogue_select_title != null:
		rogue_select_title.add_theme_color_override("font_color", Color(1.0, 0.82, 0.42))

	_apply_button_style(classic_button, Color(0.24, 0.66, 0.84), true)
	_apply_button_style(rogue_button, Color(0.72, 0.55, 0.96), false)
	_apply_button_style(hard_drop_bonus_button, Color(0.92, 0.74, 0.36), true)
	_apply_button_style(line_clear_bonus_button, Color(0.42, 0.78, 0.58), false)
	_apply_button_style(spawn_protection_button, Color(0.70, 0.70, 1.0), false)
	_apply_button_style(back_button, Color(0.46, 0.58, 0.72), false)


func _apply_button_style(button: Button, accent: Color, primary: bool) -> void:
	if button == null:
		return

	var base := Color(0.08, 0.11, 0.16, 1.0).lerp(accent, 0.22 if primary else 0.10)
	button.add_theme_stylebox_override("normal", _panel_style(base, accent, 1))
	button.add_theme_stylebox_override("hover", _panel_style(base.lerp(accent, 0.18), accent, 1))
	button.add_theme_stylebox_override("pressed", _panel_style(Color(0.035, 0.045, 0.07, 1.0).lerp(accent, 0.18), accent, 1))
	button.add_theme_stylebox_override("focus", _panel_style(base.lerp(accent, 0.26), accent, 2))
	button.add_theme_color_override("font_color", Color(0.96, 0.98, 1.0))
	button.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 1.0))
	button.add_theme_color_override("font_pressed_color", Color(0.04, 0.05, 0.08))
	button.add_theme_font_size_override("font_size", 17 if primary else 16)
	button.custom_minimum_size.y = 48.0


func _panel_style(fill: Color, border: Color, border_width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.content_margin_left = 16.0
	style.content_margin_top = 12.0
	style.content_margin_right = 16.0
	style.content_margin_bottom = 12.0
	return style
