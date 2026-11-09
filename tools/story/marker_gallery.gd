extends SceneTree
## v0.48.0 · ClaudeHelper: Pixelmarker und kompakte Aktionszeile in drei Lagen.
## xvfb-run -a godot --rendering-driver opengl3 --script res://tools/story/marker_gallery.gd
func _initialize() -> void:
	run.call_deferred()

func shot(name: String) -> void:
	for i in 3: await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("/tmp/shadepi-marker-%s.png" % name)

func run() -> void:
	root.size = Vector2i(1280, 720)
	var c = load("res://scenes/campaign.tscn").instantiate()
	root.add_child(c)
	await create_timer(0.3).timeout
	c.close_menu(); c.started = true
	c.fresh_entry = false
	c._enter(c.Beat.PACT)
	var actor = c.raven if c.raven_leads() else c.player
	actor.position = c._target() + Vector2(-90, 50)
	await shot("pact-far")
	actor.position = c._target() + Vector2(-20, 14)
	await shot("pact-near")
	c.fresh_entry = false
	c.sanctuary_stage = 2
	c._enter(c.Beat.ECHO, 0, 0, false, false, false, false, 2)
	c.raven.position = c._target() + Vector2(-16, 10)
	await shot("compensator")
	quit()
