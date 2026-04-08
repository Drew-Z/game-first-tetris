extends MarginContainer

const GameManagerScript := preload("res://scripts/game/game_manager.gd")

@onready var touch_input_bridge: Node = $"../TouchInputBridge"
@onready var left_button: Button = $TouchControlsPanel/TouchControlsMargin/TouchControlsLayout/MoveRow/LeftButton
@onready var soft_drop_button: Button = $TouchControlsPanel/TouchControlsMargin/TouchControlsLayout/MoveRow/SoftDropButton
@onready var right_button: Button = $TouchControlsPanel/TouchControlsMargin/TouchControlsLayout/MoveRow/RightButton
@onready var rotate_button: Button = $TouchControlsPanel/TouchControlsMargin/TouchControlsLayout/ActionRow/RotateButton
@onready var hard_drop_button: Button = $TouchControlsPanel/TouchControlsMargin/TouchControlsLayout/ActionRow/HardDropButton
@onready var hold_button: Button = $TouchControlsPanel/TouchControlsMargin/TouchControlsLayout/ActionRow/HoldButton
@onready var pause_button: Button = $TouchControlsPanel/TouchControlsMargin/TouchControlsLayout/ActionRow/PauseButton

var is_overlay_enabled: bool = false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	_bind_continuous_button(left_button, GameManagerScript.INPUT_ACTION_MOVE_LEFT)
	_bind_continuous_button(soft_drop_button, GameManagerScript.INPUT_ACTION_SOFT_DROP)
	_bind_continuous_button(right_button, GameManagerScript.INPUT_ACTION_MOVE_RIGHT)
	_bind_instant_button(rotate_button, GameManagerScript.INPUT_ACTION_ROTATE)
	_bind_instant_button(hard_drop_button, GameManagerScript.INPUT_ACTION_HARD_DROP)
	_bind_instant_button(hold_button, GameManagerScript.INPUT_ACTION_HOLD)
	_bind_instant_button(pause_button, GameManagerScript.INPUT_ACTION_PAUSE_BACK)


func sync_overlay_state(is_compact_layout: bool, is_ultra_narrow: bool, overlay_state: Dictionary) -> void:
	var should_hide_for_state := bool(overlay_state.get("is_help_open", false)) \
		or bool(overlay_state.get("is_paused", false)) \
		or bool(overlay_state.get("is_game_over", false)) \
		or bool(overlay_state.get("is_choice_prompt_open", false))
	var should_show := is_compact_layout and not should_hide_for_state
	is_overlay_enabled = should_show
	visible = should_show

	if not should_show:
		_release_all_touch_actions()
		_set_buttons_disabled(true)
		return

	_set_buttons_disabled(false)
	pause_button.text = "暂停"
	_apply_density(is_ultra_narrow)


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


func _apply_density(is_ultra_narrow: bool) -> void:
	var font_size := 15 if is_ultra_narrow else 16
	var button_height := 46.0 if is_ultra_narrow else 52.0
	var row_separation := 8 if is_ultra_narrow else 10
	var side_margin := 8 if is_ultra_narrow else 12
	var bottom_margin := 8 if is_ultra_narrow else 12

	add_theme_constant_override("margin_left", side_margin)
	add_theme_constant_override("margin_right", side_margin)
	add_theme_constant_override("margin_bottom", bottom_margin)

	var layout: VBoxContainer = $TouchControlsPanel/TouchControlsMargin/TouchControlsLayout
	var move_row: HBoxContainer = $TouchControlsPanel/TouchControlsMargin/TouchControlsLayout/MoveRow
	var action_row: HBoxContainer = $TouchControlsPanel/TouchControlsMargin/TouchControlsLayout/ActionRow

	layout.add_theme_constant_override("separation", row_separation)
	move_row.add_theme_constant_override("separation", row_separation)
	action_row.add_theme_constant_override("separation", row_separation)

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

		button.custom_minimum_size.y = button_height
		button.add_theme_font_size_override("font_size", font_size)
