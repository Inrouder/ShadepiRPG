extends SceneTree
## v0.48.0 · ClaudeHelper: Tower-Flucht mit Alarmlicht (Gesamtansicht und Spielkamera).
## xvfb-run -a godot --rendering-driver opengl3 --script res://tools/story/alarm_gallery.gd
func _initialize() -> void:
	run.call_deferred()

func shot(name: String) -> void:
	for i in 3: await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("/tmp/shadepi-alarm-%s.png" % name)

func run() -> void:
	root.size = Vector2i(1280, 720)
	var c = load("res://scenes/campaign.tscn").instantiate()
	root.add_child(c)
	await create_timer(0.3).timeout
	c.close_menu(); c.started = true
	c.fresh_entry = false
	c._enter(c.Beat.ESCAPE, 0, 1, false, false, false, false, 0, false, 2)
	await create_timer(0.4).timeout
	c.camera.position = Vector2(512, 330); c.camera.zoom = Vector2.ONE * 0.625
	c.set_process(false)
	await shot("overview-a")
	print("alarm lights: ", c.tower_alarm.lights.map(func(l): return [l.energy, l.is_visible_in_tree(), l.global_position]), " clock ", c.tower_alarm.clock)
	c.clock += 0.26; c.queue_redraw()
	await shot("overview-b")
	c.set_process(true)
	await create_timer(1.15).timeout
	await shot("play")
	quit()
