extends SceneTree

func _initialize() -> void:
	run.call_deferred()

func capture(scene: Node2D, name: String, dialogue: bool = false) -> Image:
	scene.process_mode = Node.PROCESS_MODE_DISABLED
	if not dialogue:
		scene.ui.clear_dialogue()
	scene.ui._process(0.0)
	scene.ui.fit_hud_text()
	scene.camera.position = Vector2(512, 320)
	scene.camera.zoom = Vector2.ONE * 0.5625
	scene.camera.limit_left = -57
	scene.camera.limit_right = 1081
	scene.camera.force_update_scroll()
	scene.queue_redraw()
	await process_frame
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	image.save_png("user://audit-" + name + ".png")
	return image

func run() -> void:
	root.size = Vector2i(1280, 720)
	root.content_scale_size = Vector2i(640, 360)
	var gallery := Image.create_empty(2560, 1440, false, Image.FORMAT_RGBA8)
	var index := 0
	var two = load("res://scenes/chapter_two.tscn").instantiate()
	root.add_child(two)
	for section in [two.Section.YARD, two.Section.HIDEOUT, two.Section.DIVE, two.Section.RECOVERY]:
		two._enter(section)
		var frame := await capture(two, "chapter2-" + str(section))
		frame.resize(640, 360)
		gallery.blit_rect(frame, Rect2i(0, 0, 640, 360), Vector2i(index % 4 * 640, index / 4 * 360))
		index += 1
	two.queue_free()
	await process_frame
	var scene = load("res://scenes/campaign.tscn").instantiate()
	root.add_child(scene)
	for beat in range(12):
		scene._enter(beat)
		var frame := await capture(scene, "beat-" + str(beat))
		frame.resize(640, 360)
		gallery.blit_rect(frame, Rect2i(0, 0, 640, 360), Vector2i(index % 4 * 640, index / 4 * 360))
		index += 1
	gallery.save_png("user://story-audit-gallery.png")
	scene._enter(scene.Beat.ESCAPE)
	scene.ui.advance_dialogue()
	scene.ui.advance_dialogue()
	await capture(scene, "dialogue", true)
	scene._enter(scene.Beat.ECHO)
	scene.ui.clear_dialogue()
	scene._start_echo()
	scene._enter_echo()
	await capture(scene, "memory")
	scene.queue_free()
	await process_frame
	quit()
