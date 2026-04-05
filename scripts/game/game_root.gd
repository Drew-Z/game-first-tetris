extends Control

const COMPACT_LAYOUT_BREAKPOINT_WIDTH: float = 920.0

@onready var layout: BoxContainer = $ViewportScroll/Layout
@onready var playfield_panel: PanelContainer = $ViewportScroll/Layout/PlayfieldPanel
@onready var sidebar_panel: PanelContainer = $ViewportScroll/Layout/SidebarPanel
@onready var game_ui: VBoxContainer = $ViewportScroll/Layout/SidebarPanel/GameUI


func _ready() -> void:
	_apply_responsive_layout()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_apply_responsive_layout()


func _apply_responsive_layout() -> void:
	if layout == null:
		return

	var is_compact := size.x < COMPACT_LAYOUT_BREAKPOINT_WIDTH
	layout.vertical = is_compact
	layout.custom_minimum_size = Vector2(400, 1080) if is_compact else Vector2(704, 672)
	playfield_panel.custom_minimum_size = Vector2(400, 672)
	sidebar_panel.custom_minimum_size = Vector2(280, 0)

	if game_ui != null and game_ui.has_method("set_compact_layout"):
		game_ui.call("set_compact_layout", is_compact)
