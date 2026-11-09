extends SceneTree
## v0.48.0 · ClaudeHelper: Aufnahmen der drei Towerplan-Prüfungen und der Planbesprechung.
## xvfb-run -a godot --rendering-driver opengl3 --script res://tools/story/pact_plan_gallery.gd
var n := 0

func _initialize() -> void:
	run.call_deferred()

func shot(tag: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("/tmp/shadepi-plan-%02d-%s.png" % [n, tag])
	n += 1

func run() -> void:
	root.size = Vector2i(1280, 720)
	var c = load("res://scenes/campaign.tscn").instantiate()
	root.add_child(c)
	await create_timer(0.3).timeout
	c.close_menu(); c.started = true
	c.fresh_entry = true; c._enter(c.Beat.PACT)
	for i in 4000:
		await process_frame
		if c.cutscene.waiting_input: c.cutscene.advance()
		if not c.in_cinematic(): break
	for step in 3:
		c._complete_point()
		await create_timer(0.6).timeout
		if step < 2: await shot("check%d" % step)
	for i in 6000:
		await process_frame
		if c.cutscene.waiting_input:
			await shot("plan")
			c.cutscene.advance()
		if c.beat != c.Beat.PACT: break
	print("plan frames: ", n)
	quit()
