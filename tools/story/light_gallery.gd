extends SceneTree
## v0.52.0 · ClaudeHelper: Spielansichten für Spiegelungen und Licht. Schreibt nach /tmp.
## xvfb-run -a godot --rendering-driver opengl3 --script res://tools/story/light_gallery.gd
func _initialize() -> void:
	run.call_deferred()

func shot(name: String) -> void:
	for i in 20: await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("/tmp/shadepi-light-%s.png" % name)

func run() -> void:
	root.size = Vector2i(1920, 1080)
	var c = load("res://scenes/campaign.tscn").instantiate()
	root.add_child(c)
	await create_timer(0.4).timeout
	c.close_menu(); c.started = true
	for entry in [["AMBUSH", Vector2(300, 330), Vector2(345, 345)], ["ROOF", Vector2(300, 400), Vector2(350, 410)], ["BOSS", Vector2(420, 330), Vector2(470, 345)], ["GARAGE", Vector2(520, 380), Vector2(570, 392)]]:
		c.fresh_entry = false
		c._enter(c.Beat[entry[0]])
		for i in 60:
			await process_frame
			if c.cutscene.running: c.cutscene.skip()
		c.player.position = entry[1]; c.raven.position = entry[2]
		c.player.facing = Vector2.RIGHT; c.raven.facing = Vector2.LEFT
		await shot(String(entry[0]).to_lower())
	c.fresh_entry = true
	c._enter(c.Beat.PACT)
	for i in 400:
		await process_frame
		if c.cutscene.waiting_input: break
	await shot("cinema")
	quit()
