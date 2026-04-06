extends Control

const STACK_LAYOUT_BREAKPOINT_WIDTH: float = 920.0
const DESKTOP_LAYOUT_MIN_SIZE := Vector2(704, 672)
const STACK_LAYOUT_MIN_SIZE := Vector2(400, 1080)
const PLAYFIELD_PANEL_MIN_SIZE := Vector2(400, 672)
const SIDEBAR_PANEL_MIN_WIDTH := 280.0

@onready var layout: BoxContainer = $ViewportScroll/Layout
@onready var viewport_scroll: ScrollContainer = $ViewportScroll
@onready var playfield_panel: PanelContainer = $ViewportScroll/Layout/PlayfieldPanel
@onready var sidebar_panel: PanelContainer = $ViewportScroll/Layout/SidebarPanel
@onready var game_ui: VBoxContainer = $ViewportScroll/Layout/SidebarPanel/GameUI


func _ready() -> void:
	if game_ui != null and game_ui.has_signal("help_visibility_changed"):
		if not game_ui.is_connected("help_visibility_changed", Callable(self, "_on_help_visibility_changed")):
			game_ui.connect("help_visibility_changed", Callable(self, "_on_help_visibility_changed"))
	_apply_responsive_layout()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_apply_responsive_layout()


func _apply_responsive_layout() -> void:
	if layout == null:
		return

	var is_compact := size.x < STACK_LAYOUT_BREAKPOINT_WIDTH
	layout.vertical = is_compact
	layout.custom_minimum_size = STACK_LAYOUT_MIN_SIZE if is_compact else DESKTOP_LAYOUT_MIN_SIZE
	playfield_panel.custom_minimum_size = PLAYFIELD_PANEL_MIN_SIZE
	sidebar_panel.custom_minimum_size = Vector2(SIDEBAR_PANEL_MIN_WIDTH, 0)

	if game_ui != null and game_ui.has_method("set_compact_layout"):
		game_ui.call("set_compact_layout", is_compact)


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
