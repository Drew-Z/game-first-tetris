extends SceneTree

const MAIN_SCENE := preload("res://scenes/main/main.tscn")
const OUTPUT_ROOT := "res://artifacts/screenshot_regression"

const SIZE_CASES := [
	{"name": "web_360x640", "size": Vector2i(360, 640)},
	{"name": "android_393x852", "size": Vector2i(393, 852)},
	{"name": "android_412x915", "size": Vector2i(412, 915)},
	{"name": "windows_960x640", "size": Vector2i(960, 640)},
	{"name": "windows_1024x768", "size": Vector2i(1024, 768)},
	{"name": "windows_1280x720", "size": Vector2i(1280, 720)},
]


func _initialize() -> void:
	await _run()
	quit()


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_ROOT))

	for case_data in SIZE_CASES:
		var case_name := String(case_data["name"])
		var viewport_size: Vector2i = case_data["size"]
		var case_dir := "%s/%s" % [OUTPUT_ROOT, case_name]
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(case_dir))

		await _capture_main_menu(case_dir, viewport_size)
		await _capture_classic_game(case_dir, viewport_size)
		await _capture_rogue_game(case_dir, viewport_size)
		await _capture_help_panel(case_dir, viewport_size)
		await _compose_contact_sheet(case_dir, viewport_size)


func _capture_main_menu(case_dir: String, viewport_size: Vector2i) -> void:
	var menu_scene: Control = await _spawn_main_scene(viewport_size)
	await _save_viewport_png("%s/main_menu.png" % case_dir)
	_clear_scene(menu_scene)


func _capture_classic_game(case_dir: String, viewport_size: Vector2i) -> void:
	var menu_scene: Control = await _spawn_main_scene(viewport_size)
	menu_scene.call("_launch_mode", &"classic", &"")
	await _settle_frames(4)
	await _save_viewport_png("%s/classic_game.png" % case_dir)
	_clear_scene(menu_scene)


func _capture_rogue_game(case_dir: String, viewport_size: Vector2i) -> void:
	var menu_scene: Control = await _spawn_main_scene(viewport_size)
	menu_scene.call("_launch_mode", &"rogue", &"hard_drop_bonus")
	await _settle_frames(4)
	await _save_viewport_png("%s/rogue_game.png" % case_dir)
	_clear_scene(menu_scene)


func _capture_help_panel(case_dir: String, viewport_size: Vector2i) -> void:
	var menu_scene: Control = await _spawn_main_scene(viewport_size)
	menu_scene.call("_launch_mode", &"rogue", &"hard_drop_bonus")
	await _settle_frames(4)

	var mode_host: Node = menu_scene.get_node("ModeHost")
	if mode_host.get_child_count() > 0:
		var game_root: Node = mode_host.get_child(0)
		var game_ui: Node = game_root.get_node("ViewportScroll/Layout/SidebarPanel/GameUI")
		if game_ui != null and game_ui.has_method("set_help_panel_open"):
			game_ui.call("set_help_panel_open", true)
			await _settle_frames(2)
		var viewport_scroll := game_root.get_node("ViewportScroll")
		if viewport_scroll is ScrollContainer:
			var scroll_bar: ScrollBar = viewport_scroll.get_v_scroll_bar()
			if scroll_bar != null:
				viewport_scroll.scroll_vertical = int(scroll_bar.max_value)
				await _settle_frames(2)
				viewport_scroll.scroll_vertical = int(scroll_bar.max_value)
				await _settle_frames(2)

	await _save_viewport_png("%s/help_panel.png" % case_dir)
	_clear_scene(menu_scene)


func _spawn_main_scene(viewport_size: Vector2i) -> Control:
	_set_viewport_size(viewport_size)

	for child in get_root().get_children():
		child.queue_free()
	await _settle_frames(2)

	var scene: Control = MAIN_SCENE.instantiate()
	scene.set_anchors_preset(Control.PRESET_FULL_RECT)
	scene.offset_left = 0.0
	scene.offset_top = 0.0
	scene.offset_right = 0.0
	scene.offset_bottom = 0.0
	get_root().add_child(scene)
	await _settle_frames(4)
	return scene


func _clear_scene(scene: Node) -> void:
	if scene != null:
		scene.queue_free()


func _set_viewport_size(viewport_size: Vector2i) -> void:
	DisplayServer.window_set_size(viewport_size)
	get_root().size = viewport_size


func _settle_frames(frame_count: int) -> void:
	for _i in range(frame_count):
		await process_frame
		await RenderingServer.frame_post_draw


func _save_viewport_png(output_path: String) -> void:
	var image := get_root().get_texture().get_image()
	if image.get_format() != Image.FORMAT_RGBA8:
		image.convert(Image.FORMAT_RGBA8)
	image.save_png(ProjectSettings.globalize_path(output_path))


func _compose_contact_sheet(case_dir: String, viewport_size: Vector2i) -> void:
	var image_names := [
		"main_menu.png",
		"classic_game.png",
		"rogue_game.png",
		"help_panel.png",
	]
	var images: Array[Image] = []

	for image_name in image_names:
		var image := Image.load_from_file(ProjectSettings.globalize_path("%s/%s" % [case_dir, image_name]))
		images.append(image)

	var sheet_height := viewport_size.y * images.size()
	var sheet := Image.create(viewport_size.x, sheet_height, false, Image.FORMAT_RGBA8)
	sheet.fill(Color(0.08, 0.09, 0.12, 1.0))

	for index in range(images.size()):
		var image: Image = images[index]
		if image.get_format() != Image.FORMAT_RGBA8:
			image.convert(Image.FORMAT_RGBA8)
		sheet.blit_rect(image, Rect2i(Vector2i.ZERO, image.get_size()), Vector2i(0, viewport_size.y * index))

	sheet.save_png(ProjectSettings.globalize_path("%s/contact_sheet.png" % case_dir))
