extends SceneTree
## v0.34.0 · CodexAI. Run on a real desktop (4K for every capture), not headless.
## Physical window captures prove gameplay fills HD output despite its pixel viewport.
const Settings = preload("res://scripts/display_settings.gd")
var failures := 0
var checks := 0

func _initialize() -> void:
	run.call_deferred()

func check(ok: bool, description: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("FAIL: " + description)

func settle() -> void:
	for i in 10:
		await process_frame
	await RenderingServer.frame_post_draw

func capture(name: String) -> void:
	await settle()
	var path := "/tmp/shadepi-display/" + name + ".png"
	var image := DisplayServer.screen_get_image_rect(Rect2i(root.position, root.size))
	# Godot's screen-capture API is unavailable on some X11 builds. Capture the
	# actual client window there; never enlarge a 640×360 viewport screenshot.
	if image == null and OS.has_feature("linux"):
		var output: Array = []
		var window_id := str(DisplayServer.window_get_native_handle(DisplayServer.WINDOW_HANDLE))
		if OS.execute("import", PackedStringArray(["-window", window_id, path]), output) == 0:
			image = Image.load_from_file(path)
	check(image != null and image.get_size() == root.size, "physical screenshot matches " + str(root.size))
	if image != null:
		image.save_png(path)

func run() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("A rendering desktop is required.")
		quit(1)
		return
	DirAccess.make_dir_recursive_absolute("/tmp/shadepi-display")
	var settings := root.get_node("DisplaySettings")
	settings.preferences_path = "user://display-gallery.cfg"
	settings.set_mode(Settings.Mode.WINDOWED)
	settings.set_resolution(2)
	settings.set_integer_scaling(false)
	var world = load("res://scenes/chapter_one.tscn").instantiate()
	root.add_child(world)
	await settle()
	check(root.size == Vector2i(1920, 1080), "Full HD window is 1920 × 1080")
	await capture("menu-1080p")
	for pressed in [true, false]:
		var click := InputEventMouseButton.new()
		click.button_index = MOUSE_BUTTON_LEFT
		click.position = root.get_final_transform() * world.ui.display_button.get_global_rect().get_center()
		click.pressed = pressed
		Input.parse_input_event(click)
		await process_frame
	check(world.ui.display_panel.visible, "actual Full HD mouse input opens display options")
	await capture("options-1080p")
	world.ui.display_panel.dismiss()
	if "--options-only" in OS.get_cmdline_user_args():
		world.queue_free()
		await process_frame
		print("Display menu captures: %d checks, %d failures" % [checks, failures])
		quit(1 if failures else 0)
		return
	world._enter_checkpoint(world.Phase.HUNT)
	world.cutscene.abort()
	await capture("game-1080p")
	for index in [3, 4]:
		settings.set_resolution(index)
		await settle()
		var requested: Vector2i = Settings.RESOLUTIONS[index]
		var expected := Settings.fit_window(requested, DisplayServer.screen_get_usable_rect(root.current_screen).size)
		check(root.size == expected, "large window fits current monitor: " + str(requested))
		await capture("game-window-%dp" % requested.y)
	settings.set_mode(Settings.Mode.BORDERLESS)
	await settle()
	check(root.mode == Window.MODE_FULLSCREEN and root.size == DisplayServer.screen_get_size(root.current_screen), "desktop fullscreen covers the complete native monitor")
	await capture("game-desktop-fullscreen")
	settings.set_mode(Settings.Mode.FULLSCREEN)
	await settle()
	check(root.mode == Window.MODE_EXCLUSIVE_FULLSCREEN and root.size == DisplayServer.screen_get_size(root.current_screen), "exclusive fullscreen covers the complete native monitor")
	await capture("game-exclusive-fullscreen")
	settings.set_mode(Settings.Mode.WINDOWED)
	settings.set_resolution(2)
	await settle()
	root.size = Vector2i(1920, 1000)
	await settle()
	var image_rect := root.get_final_transform() * Rect2(0, 0, 640, 360)
	check(absf(image_rect.size.y - 1000.0) <= 1.0 and absf(image_rect.position.x - 71.0) <= 1.0, "resized gameplay fills all available height with narrow 16:9 side bars")
	await capture("game-resized-window")
	world.menu_open = true
	world.ui.show_menu()
	world.ui._open_display_panel()
	await capture("options-paused")
	world.queue_free()
	await process_frame
	DirAccess.remove_absolute(settings.preferences_path)
	print("Display desktop: %d checks, %d failures; images /tmp/shadepi-display/" % [checks, failures])
	quit(1 if failures else 0)
