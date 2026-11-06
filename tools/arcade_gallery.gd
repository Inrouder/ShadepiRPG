extends SceneTree
## Run with a real display. Screenshots are kept outside the project.
func _initialize() -> void:
	run.call_deferred()

func capture(scene: Node2D, name: String) -> void:
	scene.ui._process(0)
	scene.ui.fit_hud_text()
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("/tmp/shadepi-arcade-" + name + ".png")

func run() -> void:
	if DisplayServer.get_name() == "headless":
		quit(1)
		return
	var scene = load("res://scenes/campaign.tscn").instantiate()
	root.add_child(scene)
	scene._enter(scene.Beat.AMBUSH)
	scene.ui.clear_dialogue()
	scene.close_menu()
	scene.set_visual_quality(2)
	scene.player.position = Vector2(210, 420)
	scene.raven.position = Vector2(180, 435)
	scene.player.facing = Vector2.RIGHT
	scene.process_mode = Node.PROCESS_MODE_DISABLED
	scene.camera.position = Vector2(320, 360)
	scene.camera.force_update_scroll()
	await capture(scene, "fight")
	for foe in scene.encounter.fighters:
		foe.take_damage(1000)
	scene.encounter._process(0)
	await capture(scene, "break")
	for step in 5:
		scene.encounter._process(2)
		for foe in scene.encounter.fighters:
			foe.take_damage(1000)
		scene.encounter._process(0)
		if scene.encounter.waiting:
			break
	await capture(scene, "forward")
	scene.queue_free()
	await process_frame
	quit()
