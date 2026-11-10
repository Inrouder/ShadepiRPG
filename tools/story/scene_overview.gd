extends SceneTree
## v0.52.0 · ClaudeHelper: Gesamtansicht jeder Kampagnenszene zum Prüfen von Requisiten,
## Türen und Laufwegen. Schreibt nur nach /tmp.
## xvfb-run -a godot --rendering-driver opengl3 --script res://tools/story/scene_overview.gd -- [beat ...]
func _initialize() -> void:
	run.call_deferred()

func run() -> void:
	root.size = Vector2i(1920, 1080)
	var c = load("res://scenes/campaign.tscn").instantiate()
	root.add_child(c)
	await create_timer(0.4).timeout
	c.close_menu(); c.started = true
	var wanted := OS.get_cmdline_user_args()
	for name: String in c.Beat.keys():
		if not wanted.is_empty() and name.to_lower() not in wanted: continue
		c.fresh_entry = false
		c._enter(c.Beat[name])
		for i in 90:
			await process_frame
			if c.cutscene.running: c.cutscene.skip()
		c.set_process(false)
		var size: Vector2 = c.map_size() if c.has_method("map_size") else Vector2(1024, 640)
		c.camera.limit_left = -10000; c.camera.limit_top = -10000; c.camera.limit_right = 10000; c.camera.limit_bottom = 10000
		c.camera.position = size * 0.5
		c.camera.zoom = Vector2.ONE * minf(640.0 / size.x, 360.0 / size.y)
		c.camera.reset_smoothing()
		for i in 6: await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("/tmp/shadepi-scene-%s.png" % name.to_lower())
		c.set_process(true)
	quit()
