extends SceneTree
## v0.31.0 · CodexAI: record actual frames; no composited artwork.
func _initialize() -> void: run.call_deferred()
func run() -> void:
	var w = load("res://scenes/campaign.tscn").instantiate()
	root.add_child(w)
	w.set_visual_quality(2)
	w.set_process(false)
	var index := 0
	for beat in [w.Beat.HANGAR,w.Beat.END]:
		w._enter(beat)
		w.cutscene.abort()
		w.close_menu()
		w.ui.hide()
		for actor in w.actors.get_children(): actor.set_physics_process(false)
		w.camera.position = Vector2(512,350)
		w.camera.zoom = Vector2.ONE*0.85
		w.camera.force_update_scroll()
		w.scene_atmosphere.sync_profile()
		for frame in 36:
			w.scene_atmosphere.elapsed = 8.0+frame/12.0
			w.scene_atmosphere._process(0)
			if w.scene_atmosphere.water_material != null: w.scene_atmosphere.water_material.set_shader_parameter("clock",w.scene_atmosphere.elapsed)
			await process_frame
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png("/tmp/atmosphere-film-%03d.png" % index)
			index += 1
	w.queue_free()
	await process_frame
	var scene = load("res://scenes/memories/attack.tscn").instantiate()
	scene.autoplay = false
	root.add_child(scene)
	scene.ui.hide()
	scene.camera.position = Vector2(512,330)
	scene.camera.zoom = Vector2.ONE*0.75
	for frame in 36:
		scene.scene_atmosphere.elapsed = 8.0+frame/12.0
		scene.scene_atmosphere.queue_redraw()
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("/tmp/atmosphere-film-%03d.png" % index)
		index += 1
	scene.queue_free()
	await process_frame
	print("ATMOSPHERE FILM: ",index," real frames")
	quit()
