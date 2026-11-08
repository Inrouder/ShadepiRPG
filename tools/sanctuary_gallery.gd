extends SceneTree
## v0.29.0 · CodexAI: real in-engine frames, no artwork compositing.
func _initialize() -> void: run.call_deferred()
func capture(tag: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("/tmp/shadepi-sanctuary-" + tag + ".png")
func run() -> void:
	var w = load("res://scenes/campaign.tscn").instantiate()
	root.add_child(w)
	w._enter(w.Beat.ECHO, 0, 0, false, false, false, false, 2)
	w.raven.position = Vector2(580, 346)
	w.camera.position = Vector2(528, 310)
	w.camera.zoom = Vector2.ONE * 1.75
	w.sanctuary_tableau.show_room(true)
	await capture("chair")
	w.sanctuary_stage = 0
	w._set_sanctuary_room()
	w.raven.hide()
	w.sanctuary_tableau.set_pose(3)
	w.sanctuary_tableau.sprite.show()
	w.camera.position = w.Painted.CHAMBER_CAMERA
	w.camera.zoom = Vector2.ONE * 1.15
	await capture("sleep")
	w._enter(w.Beat.ECHO, 0, 0, false, false, false, false, 2)
	w.raven.position = w._target()
	w._start_echo()
	Engine.time_scale = 3
	Engine.max_fps = 60
	var seen := {}
	for i in 900:
		await process_frame
		if w.cutscene.waiting_input:
			if w.cutscene.line_label.text == "Mach das nicht." and not seen.has("hand"):
				await capture("hand")
				seen.hand = true
			w.cutscene.advance()
		if not seen.has("transfer") and w.sanctuary_tableau.transfer_power > 0.75:
			await capture("transfer")
			seen.transfer = true
		if w.echo_ready: break
	Engine.time_scale = 1
	print("SANCTUARY GALLERY: ", seen)
	w.queue_free()
	await process_frame
	quit()
