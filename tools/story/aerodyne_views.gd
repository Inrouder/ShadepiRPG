extends SceneTree
## v0.48.0 · ClaudeHelper: derselbe Aerodyne in Hangar, Flug, Dach und am See.
## xvfb-run -a godot --rendering-driver opengl3 --script res://tools/story/aerodyne_views.gd
func _initialize() -> void:
	run.call_deferred()

func shot(name: String) -> void:
	for i in 4: await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("/tmp/shadepi-aero-%s.png" % name)

func run() -> void:
	root.size = Vector2i(1280, 720)
	var c = load("res://scenes/campaign.tscn").instantiate()
	root.add_child(c)
	await create_timer(0.3).timeout
	c.close_menu(); c.started = true
	for entry in [[c.Beat.HANGAR, "hangar"], [c.Beat.FLIGHT, "flight"], [c.Beat.ROOF, "roof"]]:
		c.fresh_entry = false
		c._enter(entry[0])
		for i in 240:
			await process_frame
			if c.cutscene.running: c.cutscene.skip()
		if entry[1] == "hangar":
			c.set_process(false)
			c.camera.position = Vector2(880, 330); c.camera.zoom = Vector2.ONE * 1.2
		await shot(entry[1])
		c.set_process(true)
	quit()
