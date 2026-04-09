extends MarginContainer

const GameManagerScript := preload("res://scripts/game/game_manager.gd")
const PRIMARY_BUTTON_HEIGHT := 58.0
const PRIMARY_BUTTON_HEIGHT_COMPACT := 52.0
const PRIMARY_BUTTON_HEIGHT_ULTRA_NARROW := 48.0
const SECONDARY_BUTTON_HEIGHT := 46.0
const SECONDARY_BUTTON_HEIGHT_COMPACT := 40.0
const SECONDARY_BUTTON_HEIGHT_ULTRA_NARROW := 36.0
const UTILITY_BUTTON_HEIGHT_COMPACT := 30.0
const UTILITY_BUTTON_HEIGHT_ULTRA_NARROW := 28.0
const UTILITY_BUTTON_WIDTH_COMPACT := 56.0
const UTILITY_BUTTON_WIDTH_ULTRA_NARROW := 44.0

@onready var touch_controls_panel: PanelContainer = $TouchControlsPanel
@onready var touch_controls_margin: MarginContainer = $TouchControlsPanel/TouchControlsMargin
@onready var touch_controls_layout: VBoxContainer = $TouchControlsPanel/TouchControlsMargin/TouchControlsLayout
@onready var move_row: HBoxContainer = $TouchControlsPanel/TouchControlsMargin/TouchControlsLayout/MoveRow
@onready var action_row: HBoxContainer = $TouchControlsPanel/TouchControlsMargin/TouchControlsLayout/ActionRow
@onready var touch_input_bridge: Node = $"../TouchInputBridge"
@onready var left_button: Button = $TouchControlsPanel/TouchControlsMargin/TouchControlsLayout/MoveRow/LeftButton
@onready var soft_drop_button: Button = $TouchControlsPanel/TouchControlsMargin/TouchControlsLayout/MoveRow/SoftDropButton
@onready var right_button: Button = $TouchControlsPanel/TouchControlsMargin/TouchControlsLayout/MoveRow/RightButton
@onready var rotate_button: Button = $TouchControlsPanel/TouchControlsMargin/TouchControlsLayout/ActionRow/RotateButton
@onready var hard_drop_button: Button = $TouchControlsPanel/TouchControlsMargin/TouchControlsLayout/ActionRow/HardDropButton
@onready var hold_button: Button = $TouchControlsPanel/TouchControlsMargin/TouchControlsLayout/ActionRow/HoldButton
@onready var pause_button: Button = $TouchControlsPanel/TouchControlsMargin/TouchControlsLayout/ActionRow/PauseButton

var is_overlay_enabled: bool = false
var is_compact_layout: bool = false
var utility_row: HBoxContainer


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	_ensure_utility_row()
	_bind_continuous_button(left_button, GameManagerScript.INPUT_ACTION_MOVE_LEFT)
	_bind_continuous_button(soft_drop_button, GameManagerScript.INPUT_ACTION_SOFT_DROP)
	_bind_continuous_button(right_button, GameManagerScript.INPUT_ACTION_MOVE_RIGHT)
	_bind_instant_button(rotate_button, GameManagerScript.INPUT_ACTION_ROTATE)
	_bind_instant_button(hard_drop_button, GameManagerScript.INPUT_ACTION_HARD_DROP)
	_bind_instant_button(hold_button, GameManagerScript.INPUT_ACTION_HOLD)
	_bind_instant_button(pause_button, GameManagerScript.INPUT_ACTION_PAUSE_BACK)
	_refresh_button_labels(false)
	_refresh_button_hints(false)
	_apply_density(false)
	_apply_visual_style(false)


func sync_overlay_state(is_compact_layout: bool, is_ultra_narrow: bool, overlay_state: Dictionary) -> void:
	var should_hide_for_state := bool(overlay_state.get("is_help_open", false)) \
		or bool(overlay_state.get("is_paused", false)) \
		or bool(overlay_state.get("is_game_over", false)) \
		or bool(overlay_state.get("is_choice_prompt_open", false))
	var should_show := is_compact_layout and not should_hide_for_state
	is_overlay_enabled = should_show
	self.is_compact_layout = is_compact_layout
	visible = should_show

	if not should_show:
		_release_all_touch_actions()
		_set_buttons_disabled(true)
		return

	_set_buttons_disabled(false)
	_refresh_button_labels(is_ultra_narrow)
	_refresh_button_hints(is_ultra_narrow)
	_apply_density(is_ultra_narrow)
	_apply_action_layout(is_ultra_narrow)
	_apply_visual_style(is_ultra_narrow)


func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED and not visible:
		_release_all_touch_actions()


func _input(event: InputEvent) -> void:
	if not is_overlay_enabled:
		return

	if event is InputEventScreenTouch and not event.pressed:
		_release_all_touch_actions()


func _bind_continuous_button(button: Button, action_id: StringName) -> void:
	if button == null:
		return

	button.button_down.connect(_on_continuous_button_down.bind(action_id))
	button.button_up.connect(_on_continuous_button_up.bind(action_id))


func _bind_instant_button(button: Button, action_id: StringName) -> void:
	if button == null:
		return

	button.pressed.connect(_on_instant_button_pressed.bind(action_id))


func _on_continuous_button_down(action_id: StringName) -> void:
	if not is_overlay_enabled or touch_input_bridge == null:
		return

	touch_input_bridge.call("set_touch_action_pressed", action_id, true)


func _on_continuous_button_up(action_id: StringName) -> void:
	if touch_input_bridge == null:
		return

	touch_input_bridge.call("set_touch_action_pressed", action_id, false)


func _on_instant_button_pressed(action_id: StringName) -> void:
	if not is_overlay_enabled or touch_input_bridge == null:
		return

	touch_input_bridge.call("tap_action", action_id)


func _release_all_touch_actions() -> void:
	if touch_input_bridge == null:
		return

	touch_input_bridge.call("release_all_touch_actions")


func _set_buttons_disabled(is_disabled: bool) -> void:
	for button in [
		left_button,
		soft_drop_button,
		right_button,
		rotate_button,
		hard_drop_button,
		hold_button,
		pause_button,
	]:
		if button == null:
			continue
		button.disabled = is_disabled


func _refresh_button_labels(is_ultra_narrow: bool) -> void:
	left_button.text = "←"
	soft_drop_button.text = "↓"
	right_button.text = "→"
	rotate_button.text = "转" if is_ultra_narrow else "旋转"
	hard_drop_button.text = "落" if is_ultra_narrow else "硬降"
	hold_button.text = "Hold" if is_ultra_narrow else "暂存"
	pause_button.text = "停" if is_ultra_narrow else "暂停"


func _refresh_button_hints(is_ultra_narrow: bool) -> void:
	left_button.tooltip_text = "按住后持续左移"
	soft_drop_button.tooltip_text = "按住后持续软降"
	right_button.tooltip_text = "按住后持续右移"
	rotate_button.tooltip_text = "点击后旋转当前方块"
	hard_drop_button.tooltip_text = "点击后执行 Hard Drop"
	hold_button.tooltip_text = "点击后执行 Hold"
	pause_button.tooltip_text = "点击后暂停或返回"

	if is_ultra_narrow:
		rotate_button.tooltip_text = "点击后旋转"
		hard_drop_button.tooltip_text = "点击后硬降"


func _apply_density(is_ultra_narrow: bool) -> void:
	var primary_font_size := 18 if is_ultra_narrow else (20 if is_compact_layout else 24)
	var secondary_font_size := 11 if is_ultra_narrow else (13 if is_compact_layout else 15)
	var utility_font_size := 10 if is_ultra_narrow else (12 if is_compact_layout else 15)
	var primary_button_height := PRIMARY_BUTTON_HEIGHT_ULTRA_NARROW if is_ultra_narrow else (PRIMARY_BUTTON_HEIGHT_COMPACT if is_compact_layout else PRIMARY_BUTTON_HEIGHT)
	var secondary_button_height := SECONDARY_BUTTON_HEIGHT_ULTRA_NARROW if is_ultra_narrow else (SECONDARY_BUTTON_HEIGHT_COMPACT if is_compact_layout else SECONDARY_BUTTON_HEIGHT)
	var utility_button_height := UTILITY_BUTTON_HEIGHT_ULTRA_NARROW if is_ultra_narrow else (UTILITY_BUTTON_HEIGHT_COMPACT if is_compact_layout else SECONDARY_BUTTON_HEIGHT)
	var layout_separation := 3 if is_ultra_narrow else (6 if is_compact_layout else 8)
	var move_row_separation := 6 if is_ultra_narrow else 8
	var action_row_separation := 4 if is_ultra_narrow else (6 if is_compact_layout else 8)
	var side_margin := 5 if is_ultra_narrow else (8 if is_compact_layout else 12)
	var bottom_margin := 4 if is_ultra_narrow else (6 if is_compact_layout else 12)
	var panel_padding_side := 5 if is_ultra_narrow else (8 if is_compact_layout else 10)
	var panel_padding_top := 5 if is_ultra_narrow else (8 if is_compact_layout else 10)
	var panel_padding_bottom := 2 if is_ultra_narrow else (6 if is_compact_layout else 10)

	add_theme_constant_override("margin_left", side_margin)
	add_theme_constant_override("margin_right", side_margin)
	add_theme_constant_override("margin_bottom", bottom_margin)

	touch_controls_margin.add_theme_constant_override("margin_left", panel_padding_side)
	touch_controls_margin.add_theme_constant_override("margin_top", panel_padding_top)
	touch_controls_margin.add_theme_constant_override("margin_right", panel_padding_side)
	touch_controls_margin.add_theme_constant_override("margin_bottom", panel_padding_bottom)

	touch_controls_layout.add_theme_constant_override("separation", layout_separation)
	move_row.add_theme_constant_override("separation", move_row_separation)
	action_row.add_theme_constant_override("separation", action_row_separation)
	if utility_row != null:
		utility_row.add_theme_constant_override("separation", 4 if is_ultra_narrow else (6 if is_compact_layout else 8))

	_apply_button_density(left_button, primary_font_size, primary_button_height, 0.0 if is_ultra_narrow else 6.0)
	_apply_button_density(soft_drop_button, primary_font_size, primary_button_height, 0.0 if is_ultra_narrow else 6.0)
	_apply_button_density(right_button, primary_font_size, primary_button_height, 0.0 if is_ultra_narrow else 6.0)
	_apply_button_density(rotate_button, secondary_font_size, secondary_button_height, 0.0)
	_apply_button_density(hard_drop_button, secondary_font_size, secondary_button_height, 0.0)
	_apply_button_density(hold_button, utility_font_size, utility_button_height, 0.0)
	_apply_button_density(pause_button, utility_font_size, utility_button_height, 0.0)
	_apply_move_layout(is_ultra_narrow)


func _apply_button_density(button: Button, font_size: int, button_height: float, min_width: float = 0.0) -> void:
	if button == null:
		return

	button.custom_minimum_size.x = min_width
	button.custom_minimum_size.y = button_height
	button.add_theme_font_size_override("font_size", font_size)


func _apply_move_layout(is_ultra_narrow: bool) -> void:
	var edge_ratio := 1.0
	var center_ratio := 1.0
	if is_compact_layout:
		edge_ratio = 0.9
		center_ratio = 1.25
	if is_ultra_narrow:
		edge_ratio = 0.85
		center_ratio = 1.3

	for button in [left_button, soft_drop_button, right_button]:
		if button == null:
			continue
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	left_button.size_flags_stretch_ratio = edge_ratio
	soft_drop_button.size_flags_stretch_ratio = center_ratio
	right_button.size_flags_stretch_ratio = edge_ratio


func _apply_action_layout(is_ultra_narrow: bool) -> void:
	if not is_compact_layout:
		_reparent_to_action_row(hold_button)
		_reparent_to_action_row(pause_button)
		if utility_row != null:
			utility_row.visible = false
		for button in [rotate_button, hard_drop_button, hold_button, pause_button]:
			if button == null:
				continue
			button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			button.size_flags_stretch_ratio = 1.0
			button.custom_minimum_size.x = 0.0
		return

	_reparent_to_utility_row(hold_button)
	_reparent_to_utility_row(pause_button)
	if utility_row != null:
		utility_row.visible = true

	rotate_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hard_drop_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rotate_button.size_flags_stretch_ratio = 1.0
	hard_drop_button.size_flags_stretch_ratio = 1.0
	hold_button.size_flags_horizontal = Control.SIZE_FILL
	pause_button.size_flags_horizontal = Control.SIZE_FILL

	rotate_button.custom_minimum_size.x = 0.0
	hard_drop_button.custom_minimum_size.x = 0.0
	hold_button.custom_minimum_size.x = UTILITY_BUTTON_WIDTH_ULTRA_NARROW if is_ultra_narrow else UTILITY_BUTTON_WIDTH_COMPACT
	pause_button.custom_minimum_size.x = UTILITY_BUTTON_WIDTH_ULTRA_NARROW if is_ultra_narrow else UTILITY_BUTTON_WIDTH_COMPACT

	hold_button.size_flags_stretch_ratio = 0.0
	pause_button.size_flags_stretch_ratio = 0.0


func _ensure_utility_row() -> void:
	if utility_row != null:
		return

	utility_row = HBoxContainer.new()
	utility_row.name = "UtilityRow"
	utility_row.alignment = BoxContainer.ALIGNMENT_END
	utility_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	utility_row.visible = false
	touch_controls_layout.add_child(utility_row)


func _reparent_to_action_row(button: Button) -> void:
	if button == null or action_row == null:
		return
	if button.get_parent() == action_row:
		return

	var parent := button.get_parent()
	if parent != null:
		parent.remove_child(button)
	action_row.add_child(button)


func _reparent_to_utility_row(button: Button) -> void:
	if button == null:
		return

	_ensure_utility_row()
	if button.get_parent() == utility_row:
		return

	var parent := button.get_parent()
	if parent != null:
		parent.remove_child(button)
	utility_row.add_child(button)


func _apply_visual_style(is_ultra_narrow: bool) -> void:
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.05, 0.08, 0.12, 0.88)
	panel_style.border_color = Color(0.25, 0.42, 0.62, 0.75)
	panel_style.set_border_width_all(1)
	panel_style.set_corner_radius_all(18 if not is_ultra_narrow else 14)
	touch_controls_panel.add_theme_stylebox_override("panel", panel_style)

	_apply_button_style(left_button, Color(0.13, 0.27, 0.47, 0.96), Color(0.19, 0.37, 0.63, 1.0), true, false, false)
	_apply_button_style(soft_drop_button, Color(0.10, 0.33, 0.35, 0.96), Color(0.16, 0.48, 0.50, 1.0), true, false, false)
	_apply_button_style(right_button, Color(0.13, 0.27, 0.47, 0.96), Color(0.19, 0.37, 0.63, 1.0), true, false, false)
	_apply_button_style(rotate_button, Color(0.17, 0.24, 0.36, 0.96), Color(0.27, 0.39, 0.56, 1.0), false, is_ultra_narrow, false)
	_apply_button_style(hard_drop_button, Color(0.42, 0.22, 0.08, 0.97), Color(0.74, 0.40, 0.13, 1.0), false, is_ultra_narrow, false)
	_apply_button_style(hold_button, Color(0.18, 0.21, 0.26, 0.90), Color(0.30, 0.35, 0.42, 1.0), false, is_ultra_narrow, is_compact_layout)
	_apply_button_style(pause_button, Color(0.25, 0.18, 0.14, 0.90), Color(0.42, 0.28, 0.22, 1.0), false, is_ultra_narrow, is_compact_layout)


func _apply_button_style(button: Button, base_color: Color, border_color: Color, is_primary: bool, is_ultra_narrow_secondary: bool, is_utility: bool) -> void:
	if button == null:
		return

	var normal := StyleBoxFlat.new()
	normal.bg_color = base_color
	normal.border_color = border_color
	normal.set_border_width_all(1)
	normal.set_corner_radius_all(18 if is_primary else (9 if is_ultra_narrow_secondary else (12 if is_utility else 14)))
	normal.content_margin_left = 8 if is_primary else (4 if is_ultra_narrow_secondary else (6 if is_utility else 8))
	normal.content_margin_top = 6 if is_primary else (3 if is_ultra_narrow_secondary else (4 if is_utility else 6))
	normal.content_margin_right = 8 if is_primary else (4 if is_ultra_narrow_secondary else (6 if is_utility else 8))
	normal.content_margin_bottom = 6 if is_primary else (3 if is_ultra_narrow_secondary else (4 if is_utility else 6))

	var hover: StyleBoxFlat = normal.duplicate()
	hover.bg_color = base_color.lightened(0.06)

	var pressed: StyleBoxFlat = normal.duplicate()
	pressed.bg_color = base_color.darkened(0.12)

	var disabled: StyleBoxFlat = normal.duplicate()
	disabled.bg_color = base_color.darkened(0.22)
	disabled.border_color = border_color.darkened(0.25)

	var focus: StyleBoxFlat = normal.duplicate()
	focus.border_color = Color(0.92, 0.96, 1.0, 0.95)
	focus.set_border_width_all(2)

	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("disabled", disabled)
	button.add_theme_stylebox_override("focus", focus)
