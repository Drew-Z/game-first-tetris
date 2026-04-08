extends Control

const STACK_LAYOUT_BREAKPOINT_WIDTH: float = 920.0
const ULTRA_NARROW_COMPACT_MAX_WIDTH: float = 360.0
const ANDROID_PORTRAIT_MAX_WIDTH: float = 430.0
const NARROW_ANDROID_PORTRAIT_MAX_WIDTH: float = 400.0
const ANDROID_PORTRAIT_MIN_HEIGHT: float = 800.0
const DESKTOP_LAYOUT_MIN_SIZE := Vector2(704, 672)
const STACK_LAYOUT_MIN_SIZE := Vector2(400, 1080)
const ULTRA_NARROW_STACK_LAYOUT_MIN_SIZE := Vector2(280, 760)
const PORTRAIT_STACK_LAYOUT_MIN_SIZE := Vector2(320, 860)
const NARROW_PORTRAIT_STACK_LAYOUT_MIN_SIZE := Vector2(300, 820)
const PLAYFIELD_PANEL_MIN_SIZE := Vector2(400, 672)
const ULTRA_NARROW_PLAYFIELD_PANEL_MIN_SIZE := Vector2(248, 432)
const PORTRAIT_PLAYFIELD_PANEL_MIN_SIZE := Vector2(304, 520)
const NARROW_PORTRAIT_PLAYFIELD_PANEL_MIN_SIZE := Vector2(284, 484)
const SIDEBAR_PANEL_MIN_WIDTH := 280.0
const DEFAULT_BOARD_CELL_SIZE := 32
const ULTRA_NARROW_BOARD_CELL_SIZE := 18
const PORTRAIT_BOARD_CELL_SIZE := 24
const NARROW_PORTRAIT_BOARD_CELL_SIZE := 22
const DEFAULT_PLAYFIELD_MARGIN_LEFT := 24
const DEFAULT_PLAYFIELD_MARGIN_TOP := 16
const DEFAULT_PLAYFIELD_MARGIN_RIGHT := 24
const DEFAULT_PLAYFIELD_MARGIN_BOTTOM := 16
const PORTRAIT_PLAYFIELD_MARGIN_LEFT := 12
const PORTRAIT_PLAYFIELD_MARGIN_TOP := 12
const PORTRAIT_PLAYFIELD_MARGIN_RIGHT := 12
const PORTRAIT_PLAYFIELD_MARGIN_BOTTOM := 12
const DEFAULT_PLAYFIELD_OFFSET := Vector2(16, 16)
const PORTRAIT_PLAYFIELD_OFFSET := Vector2(8, 8)

@onready var layout: BoxContainer = $ViewportScroll/Layout
@onready var viewport_scroll: ScrollContainer = $ViewportScroll
@onready var playfield_panel: PanelContainer = $ViewportScroll/Layout/PlayfieldPanel
@onready var playfield_margin: MarginContainer = $ViewportScroll/Layout/PlayfieldPanel/PlayfieldMargin
@onready var playfield: Node2D = $ViewportScroll/Layout/PlayfieldPanel/PlayfieldMargin/Playfield
@onready var board: Node2D = $ViewportScroll/Layout/PlayfieldPanel/PlayfieldMargin/Playfield/Board
@onready var active_piece: Node2D = $ViewportScroll/Layout/PlayfieldPanel/PlayfieldMargin/Playfield/ActivePiece
@onready var sidebar_panel: PanelContainer = $ViewportScroll/Layout/SidebarPanel
@onready var game_ui: VBoxContainer = $ViewportScroll/Layout/SidebarPanel/GameUI
@onready var touch_controls: MarginContainer = $TouchControls


func _ready() -> void:
	if game_ui != null and game_ui.has_signal("help_visibility_changed"):
		if not game_ui.is_connected("help_visibility_changed", Callable(self, "_on_help_visibility_changed")):
			game_ui.connect("help_visibility_changed", Callable(self, "_on_help_visibility_changed"))
	if game_ui != null and game_ui.has_signal("touch_controls_state_changed"):
		if not game_ui.is_connected("touch_controls_state_changed", Callable(self, "_on_touch_controls_state_changed")):
			game_ui.connect("touch_controls_state_changed", Callable(self, "_on_touch_controls_state_changed"))
	_apply_responsive_layout()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_apply_responsive_layout()


func _apply_responsive_layout() -> void:
	if layout == null:
		return

	var is_compact := size.x < STACK_LAYOUT_BREAKPOINT_WIDTH
	var is_ultra_narrow_compact := is_compact and size.x <= ULTRA_NARROW_COMPACT_MAX_WIDTH
	var is_android_portrait := is_compact and size.x <= ANDROID_PORTRAIT_MAX_WIDTH and size.y >= ANDROID_PORTRAIT_MIN_HEIGHT
	var is_narrow_android_portrait := is_android_portrait and size.x <= NARROW_ANDROID_PORTRAIT_MAX_WIDTH
	layout.vertical = is_compact
	layout.custom_minimum_size = ULTRA_NARROW_STACK_LAYOUT_MIN_SIZE if is_ultra_narrow_compact else (NARROW_PORTRAIT_STACK_LAYOUT_MIN_SIZE if is_narrow_android_portrait else (PORTRAIT_STACK_LAYOUT_MIN_SIZE if is_android_portrait else (STACK_LAYOUT_MIN_SIZE if is_compact else DESKTOP_LAYOUT_MIN_SIZE)))
	playfield_panel.custom_minimum_size = ULTRA_NARROW_PLAYFIELD_PANEL_MIN_SIZE if is_ultra_narrow_compact else (NARROW_PORTRAIT_PLAYFIELD_PANEL_MIN_SIZE if is_narrow_android_portrait else (PORTRAIT_PLAYFIELD_PANEL_MIN_SIZE if is_android_portrait else PLAYFIELD_PANEL_MIN_SIZE))
	sidebar_panel.custom_minimum_size = Vector2(SIDEBAR_PANEL_MIN_WIDTH, 0)
	_apply_playfield_density(is_ultra_narrow_compact, is_android_portrait, is_narrow_android_portrait)

	if game_ui != null and game_ui.has_method("set_compact_layout"):
		game_ui.call("set_compact_layout", is_compact, is_android_portrait, is_ultra_narrow_compact)
	_sync_touch_controls_overlay(is_compact, is_ultra_narrow_compact)


func _apply_playfield_density(is_ultra_narrow_compact: bool, is_android_portrait: bool, is_narrow_android_portrait: bool) -> void:
	_set_playfield_margin(is_android_portrait or is_ultra_narrow_compact)
	var board_cell_size := DEFAULT_BOARD_CELL_SIZE
	if is_ultra_narrow_compact:
		board_cell_size = ULTRA_NARROW_BOARD_CELL_SIZE
	elif is_android_portrait:
		board_cell_size = NARROW_PORTRAIT_BOARD_CELL_SIZE if is_narrow_android_portrait else PORTRAIT_BOARD_CELL_SIZE
	_set_playfield_cell_size(board_cell_size)
	if playfield != null:
		playfield.position = PORTRAIT_PLAYFIELD_OFFSET if (is_android_portrait or is_ultra_narrow_compact) else DEFAULT_PLAYFIELD_OFFSET


func _set_playfield_margin(is_android_portrait: bool) -> void:
	if playfield_margin == null:
		return

	playfield_margin.add_theme_constant_override(
		"margin_left",
		PORTRAIT_PLAYFIELD_MARGIN_LEFT if is_android_portrait else DEFAULT_PLAYFIELD_MARGIN_LEFT
	)
	playfield_margin.add_theme_constant_override(
		"margin_top",
		PORTRAIT_PLAYFIELD_MARGIN_TOP if is_android_portrait else DEFAULT_PLAYFIELD_MARGIN_TOP
	)
	playfield_margin.add_theme_constant_override(
		"margin_right",
		PORTRAIT_PLAYFIELD_MARGIN_RIGHT if is_android_portrait else DEFAULT_PLAYFIELD_MARGIN_RIGHT
	)
	playfield_margin.add_theme_constant_override(
		"margin_bottom",
		PORTRAIT_PLAYFIELD_MARGIN_BOTTOM if is_android_portrait else DEFAULT_PLAYFIELD_MARGIN_BOTTOM
	)


func _set_playfield_cell_size(cell_size: int) -> void:
	if board != null:
		board.set("cell_size", cell_size)
		board.queue_redraw()

	if active_piece != null:
		active_piece.set("cell_size", cell_size)
		active_piece.queue_redraw()


func _on_help_visibility_changed(is_visible: bool) -> void:
	if not is_visible:
		return

	if viewport_scroll == null:
		return

	call_deferred("_scroll_to_help_context")


func _scroll_to_help_context() -> void:
	if viewport_scroll == null or sidebar_panel == null:
		return

	if layout != null and layout.vertical:
		viewport_scroll.scroll_vertical = int(sidebar_panel.position.y)
		return

	viewport_scroll.scroll_vertical = 0


func _on_touch_controls_state_changed() -> void:
	_sync_touch_controls_overlay(
		layout != null and layout.vertical,
		size.x <= ULTRA_NARROW_COMPACT_MAX_WIDTH
	)


func _sync_touch_controls_overlay(is_compact: bool, is_ultra_narrow_compact: bool) -> void:
	if touch_controls == null or not touch_controls.has_method("sync_overlay_state"):
		return

	var overlay_state := {
		"is_help_open": false,
		"is_paused": false,
		"is_game_over": false,
		"is_choice_prompt_open": false,
	}
	if game_ui != null and game_ui.has_method("get_touch_controls_overlay_state"):
		overlay_state = game_ui.call("get_touch_controls_overlay_state")

	touch_controls.call("sync_overlay_state", is_compact, is_ultra_narrow_compact, overlay_state)
