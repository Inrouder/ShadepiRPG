extends SceneTree

func _initialize() -> void:
	run.call_deferred()

func capture(scene: Node2D, name: String) -> void:
	scene.ui.clear_dialogue()
	scene.ui._process(0)
	scene.ui.fit_hud_text()
	scene.queue_redraw()
	scene.camera.force_update_scroll()
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("/tmp/shadepi-map-" + name + ".png")

func run() -> void:
	if DisplayServer.get_name() == "headless":
		quit(1)
		return
	var street = load("res://scenes/chapter_one.tscn").instantiate()
	root.add_child(street)
	street._enter_checkpoint(street.Phase.HUNT, 1)
	street.process_mode = Node.PROCESS_MODE_DISABLED
	street.set_visual_quality(2)
	for x in [-64, 0, 64]:
		street.raven.position = Vector2(x, 412)
		street.raven.animate("idle", 0)
		street.camera.position = Vector2(x, 350)
		await capture(street, "street-%d" % x)
	street.queue_free()
	await process_frame
	var room = load("res://scenes/campaign.tscn").instantiate()
	root.add_child(room)
	room._enter(room.Beat.ECHO)
	room.process_mode = Node.PROCESS_MODE_DISABLED
	room.set_visual_quality(2)
	room.player.position = Vector2(486, 328)
	room.raven.position = Vector2(414, 320)
	room.player.facing = Vector2.UP
	room.raven.facing = Vector2.RIGHT
	room.player.animate("idle", 0)
	room.raven.animate("idle", 0)
	await capture(room, "chamber")
	room.queue_free()
	await process_frame
	quit()
