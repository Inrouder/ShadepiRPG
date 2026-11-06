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
	scene.ui.start_backdrop.aim_at(Vector2(70, 300))
	for i in 50:
		await process_frame
	await capture("/tmp/shadepi-menu-wind.png")
	scene.ui.visual_button.grab_focus()
	for i in 12:
		await process_frame
	await capture("/tmp/shadepi-menu-focus.png")
	scene.set_visual_quality(0)
	await capture("/tmp/shadepi-menu-reduced.png")
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
