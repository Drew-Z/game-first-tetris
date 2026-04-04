extends Control

const GAME_ROOT_SCENE := preload("res://scenes/game/game_root.tscn")

@onready var menu_overlay: CenterContainer = $MenuOverlay
@onready var mode_host: Control = $ModeHost
@onready var mode_select_group: VBoxContainer = $MenuOverlay/MenuPanel/MenuMargin/MenuContent/ModeSelectGroup
@onready var rogue_select_group: VBoxContainer = $MenuOverlay/MenuPanel/MenuMargin/MenuContent/RogueSelectGroup
@onready var classic_button: Button = $MenuOverlay/MenuPanel/MenuMargin/MenuContent/ModeSelectGroup/ClassicButton
@onready var rogue_button: Button = $MenuOverlay/MenuPanel/MenuMargin/MenuContent/ModeSelectGroup/RogueButton
@onready var hard_drop_bonus_button: Button = $MenuOverlay/MenuPanel/MenuMargin/MenuContent/RogueSelectGroup/HardDropBonusButton
@onready var line_clear_bonus_button: Button = $MenuOverlay/MenuPanel/MenuMargin/MenuContent/RogueSelectGroup/LineClearBonusButton
@onready var steady_start_button: Button = $MenuOverlay/MenuPanel/MenuMargin/MenuContent/RogueSelectGroup/SteadyStartButton
@onready var back_button: Button = $MenuOverlay/MenuPanel/MenuMargin/MenuContent/RogueSelectGroup/BackButton


func _ready() -> void:
	_show_mode_select()
	classic_button.pressed.connect(_on_classic_button_pressed)
	rogue_button.pressed.connect(_on_rogue_button_pressed)
	hard_drop_bonus_button.pressed.connect(_on_hard_drop_bonus_button_pressed)
	line_clear_bonus_button.pressed.connect(_on_line_clear_bonus_button_pressed)
	steady_start_button.pressed.connect(_on_steady_start_button_pressed)
	back_button.pressed.connect(_on_back_button_pressed)


func _on_classic_button_pressed() -> void:
	_launch_mode(&"classic", &"")


func _on_rogue_button_pressed() -> void:
	_show_rogue_select()


func _on_hard_drop_bonus_button_pressed() -> void:
	_launch_mode(&"rogue", &"hard_drop_bonus")


func _on_line_clear_bonus_button_pressed() -> void:
	_launch_mode(&"rogue", &"line_clear_bonus")


func _on_steady_start_button_pressed() -> void:
	_launch_mode(&"rogue", &"steady_start")


func _on_back_button_pressed() -> void:
	_show_mode_select()


func _launch_mode(mode_id: StringName, rogue_upgrade_id: StringName) -> void:
	for child in mode_host.get_children():
		child.queue_free()

	var game_root := GAME_ROOT_SCENE.instantiate()
	var game_manager: Node = game_root.get_node("GameManager")
	if game_manager != null:
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


func _show_mode_select() -> void:
	menu_overlay.visible = true
	mode_select_group.visible = true
	rogue_select_group.visible = false


func _show_rogue_select() -> void:
	menu_overlay.visible = true
	mode_select_group.visible = false
	rogue_select_group.visible = true
