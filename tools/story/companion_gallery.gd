extends SceneTree
## v0.53.0 · ClaudeHelper: Aufnahmen der beiden Begleiter. Schreibt nach /tmp.
## xvfb-run -a godot --rendering-driver opengl3 --script res://tools/story/companion_gallery.gd
func _initialize() -> void:
	run.call_deferred()

func shot(name: String) -> void:
	for i in 6: await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("/tmp/shadepi-companion-%s.png" % name)

func run() -> void:
	root.size = Vector2i(1920, 1080)
	var c = load("res://scenes/campaign.tscn").instantiate()
	root.add_child(c)
	await create_timer(0.4).timeout
	c.close_menu(); c.started = true
	c.fresh_entry = false
	c._enter(c.Beat.ROOF)
	for i in 80: await process_frame
	c.companion.claim()
	await shot("drone")
	c.companion.attack()
	await shot("drone-shot")
	c.set_coop(true)
	c._enter(c.Beat.AMBUSH)
	for i in 80:
		await process_frame
		if c.cutscene.running: c.cutscene.skip()
	print("LEAD ", c.companion.kind, " ", c.companion.presence)
	c.companion.claim()
	await shot("nanites")
	c.companion.position = c.special_targets()[0].position + Vector2(-30, -20) if not c.special_targets().is_empty() else c.companion.position
	c.companion.attack()
	for i in 4: await process_frame
	await shot("nanites-bite")
	c.companion.hack()
	for i in 30: await process_frame
	await shot("nanites-shield")
	quit()
