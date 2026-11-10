extends SceneTree
## v0.34.0 · CodexAI. Real viewport/input regression coverage for display options.
const Settings = preload("res://scripts/display_settings.gd")
var checks := 0
var failures := 0
var settings: Node

func _initialize() -> void:
	run.call_deferred()

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("FAIL: " + message)

func key(code: Key, alt: bool = false, echo: bool = false) -> void:
	for pressed in [true, false]:
		var event := InputEventKey.new()
		event.keycode = code
		event.alt_pressed = alt
		event.pressed = pressed
		event.echo = echo
		Input.parse_input_event(event)
		await process_frame

func pad(button: JoyButton) -> void:
	for pressed in [true, false]:
		var event := InputEventJoypadButton.new()
		event.button_index = button
		event.device = 77
		event.pressed = pressed
		Input.parse_input_event(event)
		await process_frame

func click(control: Control) -> void:
	for pressed in [true, false]:
		var event := InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.position = root.get_final_transform() * control.get_global_rect().get_center()
		event.pressed = pressed
		Input.parse_input_event(event)
		await process_frame

func run() -> void:
	settings = root.get_node("DisplaySettings")
	settings.preferences_path = "user://display-validation.cfg"
	DirAccess.remove_absolute(settings.preferences_path)
	settings.load_preferences()
	check(settings.hq_enabled,"new installs enable capped HQ")
	check(settings.mode == Settings.Mode.BORDERLESS and not settings.integer_scaling, "new install defaults to desktop fullscreen and filling scale")
	var invalid := ConfigFile.new()
	invalid.set_value("display", "mode", "broken")
	invalid.set_value("display", "resolution", 9000)
	invalid.set_value("display", "last_fullscreen", -4)
	invalid.set_value("display", "integer_scaling", "true")
	invalid.save(settings.preferences_path)
	settings.load_preferences()
	check(settings.mode == Settings.Mode.BORDERLESS and settings.resolution_index == 0 and not settings.integer_scaling, "bad preference types/values fall back safely")
	settings.set_hq(false) # Existing pixel-mode/input coverage; HQ has its own native suite.
	settings.set_mode(Settings.Mode.WINDOWED)
	settings.set_resolution(4)
	settings.set_integer_scaling(true)
	var restored := Settings.new()
	restored.load_preferences(settings.preferences_path)
	check(restored.mode == Settings.Mode.WINDOWED and restored.resolution_index == 4 and restored.integer_scaling, "display preferences round trip separately from game saves")
	restored.free()
	settings.set_mode(-50)
	settings.set_resolution(999)
	check(settings.mode == Settings.Mode.WINDOWED and settings.resolution_index == 4, "invalid API values do not change preferences")
	for monitor in [Vector2i(1280, 720), Vector2i(1920, 1080), Vector2i(2560, 1440), Vector2i(3840, 2160)]:
		for requested in Settings.RESOLUTIONS:
			var fitted := Settings.fit_window(requested, monitor)
			check(fitted.x * 9 == fitted.y * 16 and fitted.x <= monitor.x - 48 and fitted.y <= monitor.y - 80, "window stays on screen with exact 16:9: %s on %s" % [requested, monitor])
	settings.set_integer_scaling(false)
	await key(KEY_F11)
	check(settings.mode == Settings.Mode.BORDERLESS, "F11 returns to preferred fullscreen mode")
	await key(KEY_F11, false, true)
	check(settings.mode == Settings.Mode.BORDERLESS, "key repeat cannot toggle repeatedly")
	await key(KEY_ENTER, true)
	check(settings.mode == Settings.Mode.WINDOWED, "Alt+Enter returns to window")
	settings.set_mode(Settings.Mode.FULLSCREEN)
	await key(KEY_F11)
	await key(KEY_F11)
	check(settings.mode == Settings.Mode.FULLSCREEN, "toggle remembers exclusive versus desktop fullscreen")
	settings.set_mode(Settings.Mode.WINDOWED)
	settings.set_resolution(0)
	var world = load("res://scenes/chapter_one.tscn").instantiate()
	root.add_child(world)
	# Preserve the synthetic pad assignment while no physical device is attached.
	world.set_process(false)
	var devices: Array[int] = [77]
	world.gamepads.assign(devices, false)
	await process_frame
	var options = world.ui.display_panel
	# Verify actual window-to-viewport transformation, both menu and game.
	for opening in [true, false]:
		settings.set_menu_context(opening)
		for extent in [Vector2i(1280, 720), Vector2i(1920, 1080), Vector2i(2560, 1440), Vector2i(3840, 2160), Vector2i(1920, 1000), Vector2i(2560, 1080), Vector2i(1024, 768)]:
			root.size = extent
			await process_frame
			await process_frame
			var transform := root.get_final_transform()
			var expected := minf(extent.x / 640.0, extent.y / 360.0)
			check(absf(transform.x.x - expected) * 640.0 <= 1.0 and absf(transform.y.y - expected) * 360.0 <= 1.0, "menu=%s fills output within one output pixel: %s" % [opening, extent])
			var image_rect := transform * Rect2(Vector2.ZERO, Vector2(640, 360))
			check((image_rect.position - (Vector2(extent) - image_rect.size) * 0.5).length() <= 1.0, "16:9 image centered within one output pixel on %s" % extent)
	root.size = Vector2i(1920, 1000)
	settings.set_integer_scaling(true)
	await process_frame
	check(is_equal_approx(root.get_final_transform().x.x, 2.0), "optional integer scale preserves the requested whole pixel steps")
	settings.set_integer_scaling(false)
	world.ui.show_menu()
	await process_frame
	await click(world.ui.display_button)
	check(options.visible and root.gui_get_focus_owner() == options.mode_select, "scaled mouse coordinates open the options and focus the mode")
	check(options.status_label.get_minimum_size().x <= 304.0, "display help fits inside its pixel frame")
	check(not options.resolution_select.disabled, "window size is editable in windowed mode")
	await pad(JOY_BUTTON_DPAD_DOWN)
	check(root.gui_get_focus_owner() == options.resolution_select, "controller navigates to window size")
	await pad(JOY_BUTTON_A)
	check(options.resolution_select.get_popup().visible, "controller opens the resolution dropdown")
	await pad(JOY_BUTTON_B)
	check(options.visible and not options.resolution_select.get_popup().visible and world.menu_open, "B closes dropdown first without leaving options")
	await pad(JOY_BUTTON_A)
	await pad(JOY_BUTTON_DPAD_DOWN)
	await pad(JOY_BUTTON_A)
	check(settings.resolution_index == 1, "controller selects a resolution through actual popup input")
	await key(KEY_F11)
	check(options.resolution_select.disabled and root.gui_get_focus_owner() == options.mode_select, "fullscreen shortcut transfers focus from disabled window size")
	await key(KEY_F11)
	await pad(JOY_BUTTON_B)
	check(not options.visible and world.menu_open and root.gui_get_focus_owner() == world.ui.display_button, "B closes options only and restores menu focus")
	world.ui._open_display_panel()
	settings.set_mode(Settings.Mode.BORDERLESS)
	check(options.resolution_select.disabled, "desktop fullscreen uses native display resolution")
	options.mode_select.grab_focus()
	await pad(JOY_BUTTON_DPAD_DOWN)
	check(root.gui_get_focus_owner() == options.scaling_select, "controller skips disabled window size in fullscreen")
	await key(KEY_ESCAPE)
	check(not options.visible and world.menu_open, "Escape dismisses only display options")
	world.started = true
	world.ui.show_menu()
	world.ui._open_display_panel()
	await key(KEY_F11)
	check(options.visible and world.menu_open, "fullscreen shortcut works without closing pause options")
	options.dismiss()
	world.ui.hide_menu()
	check(root.content_scale_mode == Window.CONTENT_SCALE_MODE_VIEWPORT and root.content_scale_stretch == Window.CONTENT_SCALE_STRETCH_FRACTIONAL, "resuming restores pixel game rendering with filling scale")
	world.queue_free()
	await process_frame
	var chapter = load("res://scenes/campaign.tscn").instantiate()
	root.add_child(chapter)
	await process_frame
	check(chapter.ui.display_button != null and not chapter.ui.display_panel.visible, "options available after Tower chapter change without opening a modal")
	check(settings.mode == Settings.Mode.WINDOWED and not settings.integer_scaling, "display choice survives chapter changes")
	chapter.queue_free()
	await process_frame
	settings.set_mode(Settings.Mode.WINDOWED)
	DirAccess.remove_absolute(settings.preferences_path)
	print("Display settings: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
