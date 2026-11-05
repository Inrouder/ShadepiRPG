## Run with a graphical display: godot --script res://tools/action_gallery.gd
extends SceneTree

func _initialize() -> void:
	run.call_deferred()

func capture(scene: Node2D, filename: String) -> void:
	scene.process_mode = Node.PROCESS_MODE_DISABLED
	scene.ui._process(0.0)
	scene.ui.fit_hud_text()
	if scene.drive != null:
		scene.drive.queue_redraw()
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://docs/" + filename + ".png")

func run() -> void:
	root.size = Vector2i(1280, 720)
	root.content_scale_size = Vector2i(640, 360)
	var scene = load("res://scenes/campaign.tscn").instantiate()
	root.add_child(scene)
	scene._enter(scene.Beat.FLIGHT)
	scene.ui.clear_dialogue()
	scene.close_menu()
	scene.process_mode = Node.PROCESS_MODE_DISABLED
	scene.drive.elapsed = 3.2
	scene.drive.start_engine_failure()
	for i in 30: scene.drive._process(1.0 / 60.0)
	for i in 5: scene.drive.knock_engine()
	await capture(scene, "hq-anflug")
	scene.ui.message_time = 0.0
	scene._enter(scene.Beat.CHASE)
	scene.ui.clear_dialogue()
	scene.close_menu()
	scene.drive.elapsed = 8.0
	scene.drive.armour = 38
	scene.drive.impact(Vector2(324, 295), true)
	scene.drive.bullets.append(Vector2(320, 257))
	scene.drive.rear_shots.append(Vector2(230, 264))
	scene.drive.hazards.append(Vector2(410, 160))
	for i in 8: scene.drive._process(1.0 / 60.0)
	await capture(scene, "hq-verfolgung")
	scene.ui.message_time = 0.0
	scene._enter(scene.Beat.AMBUSH)
	scene.ui.clear_dialogue()
	scene.close_menu()
	scene.camera.position = Vector2(512, 320)
	scene.camera.force_update_scroll()
	await capture(scene, "hq-weltobjekte")
	scene.queue_free()
	await process_frame
	quit()
