extends SceneTree
## v0.52.0 · ClaudeHelper: Gesamtansichten von Kapitel 1 (Straße) und Kapitel 2 (Hof, Versteck, Netz).
## xvfb-run -a godot --rendering-driver opengl3 --script res://tools/story/chapter_overview.gd
func _initialize() -> void:
	run.call_deferred()

func shot(c, center: Vector2, zoom: float, name: String) -> void:
	c.set_process(false)
	c.camera.limit_left = -10000; c.camera.limit_top = -10000; c.camera.limit_right = 10000; c.camera.limit_bottom = 10000
	c.camera.position = center
	c.camera.zoom = Vector2.ONE * zoom
	c.camera.reset_smoothing()
	for i in 6: await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("/tmp/shadepi-chapter-%s.png" % name)
	c.set_process(true)

func settle(c) -> void:
	for i in 120:
		await process_frame
		if c.cutscene != null and c.cutscene.running: c.cutscene.skip()

func run() -> void:
	root.size = Vector2i(1920, 1080)
	var one = load("res://scenes/chapter_one.tscn").instantiate()
	root.add_child(one)
	await create_timer(0.4).timeout
	one.close_menu(); one.started = true
	one.set_painted_solids("street") if one.painted_layout != "street" else null
	one.set_dressing("street")
	await settle(one)
	await shot(one, Vector2(-330, 330), 0.9, "one-west")
	await shot(one, Vector2(330, 330), 0.9, "one-mid")
	await shot(one, Vector2(700, 330), 0.9, "one-east")
	one.queue_free()
	await process_frame
	var two = load("res://scenes/chapter_two.tscn").instantiate()
	root.add_child(two)
	await create_timer(0.4).timeout
	two.close_menu(); two.started = true
	await settle(two)
	await shot(two, Vector2(512, 320), 0.5625, "two-yard")
	quit()
