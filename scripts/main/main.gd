extends Control

const GAME_ROOT_SCENE := preload("res://scenes/game/game_root.tscn")

@onready var menu_overlay: CenterContainer = $MenuOverlay
@onready var mode_host: Control = $ModeHost
@onready var classic_button: Button = $MenuOverlay/MenuPanel/MenuMargin/MenuContent/ClassicButton
@onready var rogue_button: Button = $MenuOverlay/MenuPanel/MenuMargin/MenuContent/RogueButton


func _ready() -> void:
	classic_button.pressed.connect(_on_classic_button_pressed)
	rogue_button.pressed.connect(_on_rogue_button_pressed)


func _on_classic_button_pressed() -> void:
	_launch_mode(&"classic")


func _on_rogue_button_pressed() -> void:
	_launch_mode(&"rogue")


func _launch_mode(mode_id: StringName) -> void:
	for child in mode_host.get_children():
		child.queue_free()

	var game_root := GAME_ROOT_SCENE.instantiate()
	var game_manager: Node = game_root.get_node("GameManager")
	if game_manager != null:
		if game_manager.has_method("set_entry_mode"):
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
