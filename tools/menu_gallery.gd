extends SceneTree

# Run with a real renderer (for example DISPLAY=:91 godot --script ...).
# Images go outside the project so a visual check never changes shipped assets.
func _initialize() -> void:
	run.call_deferred()

func run() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Menu capture requires a rendering display.")
		quit(1)
		return
	var scene = load("res://scenes/chapter_one.tscn").instantiate()
	root.add_child(scene)
	scene.set_visual_quality(2)
	for i in 12:
		await process_frame
	await capture("/tmp/shadepi-menu-neutral.png")
	root.size = Vector2i(1920, 1080)
	await capture("/tmp/shadepi-menu-1080p.png")
	if root.get_texture().get_image().get_size() != Vector2i(1920, 1080):
		push_error("HQ menu must render at full window resolution.")
		quit(1)
		return
	# Verify actual window-coordinate input still reaches the scaled menu.
	var original_mode: bool = scene.ui.requested_coop
	for pressed in [true, false]:
		var click := InputEventMouseButton.new()
		click.button_index = MOUSE_BUTTON_LEFT
		click.position = root.get_final_transform() * scene.ui.mode_button.get_global_rect().get_center()
		click.pressed = pressed
		Input.parse_input_event(click)
		await process_frame
	if scene.ui.requested_coop == original_mode:
		push_error("Full HD menu mouse input did not reach the mode button.")
		quit(1)
		return
	scene.ui._switch_mode()
	var next_focus := InputEventAction.new()
	next_focus.action = "ui_down"
	next_focus.pressed = true
	Input.parse_input_event(next_focus)
	await process_frame
	if root.gui_get_focus_owner() == null:
		push_error("Full HD menu lost keyboard/controller focus.")
		quit(1)
		return
	next_focus.pressed = false
	Input.parse_input_event(next_focus)
	print("HQ MENU: Full HD render, scaled mouse click and UI focus passed")
	root.size = Vector2i(1280, 720)
	scene.ui.start_backdrop.pulse_at(Vector2(70, 300))
	for i in 50:
		await process_frame
	await capture("/tmp/shadepi-menu-weather.png")
	scene.ui.visual_button.grab_focus()
	for i in 12:
		await process_frame
	await capture("/tmp/shadepi-menu-focus.png")
	# Pointer corners must no longer move either the figures or the roof.
	var corners := [Vector2.ZERO, Vector2(640, 0), Vector2(0, 360), Vector2(640, 360)]
	for i in corners.size():
		var motion := InputEventMouseMotion.new()
		motion.position = corners[i]
		scene.ui.start_backdrop._input(motion)
		await capture("/tmp/shadepi-menu-corner-%d.png" % i)
	scene.set_visual_quality(0)
	await capture("/tmp/shadepi-menu-reduced.png")
	if "--animate" in OS.get_cmdline_user_args():
		scene.set_visual_quality(2)
		var animated_backdrop = scene.ui.start_backdrop
		animated_backdrop.set_process(false)
		for i in 48:
			animated_backdrop._process(1.0 / 12.0)
			await capture("/tmp/shadepi-menu-frame-%02d.png" % i)
	# Isolate two wind phases for pixel comparison of moving tips and fixed feet.
	scene.set_visual_quality(2)
	var backdrop = scene.ui.start_backdrop
	backdrop.set_process(false)
	backdrop.weather.hide()
	backdrop.atmosphere.hide()
	for i in 2:
		backdrop.wind_material.set_shader_parameter("clock", [0.4, 1.8][i])
		await capture("/tmp/shadepi-menu-wind-%d.png" % i)
	scene.new_game(false)
	scene.ui.clear_dialogue()
	scene.menu_open = true
	scene.ui.show_menu()
	await capture("/tmp/shadepi-menu-pause.png")
	quit()

func capture(path: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(path)
	print("MENU CAPTURE: ", path)
