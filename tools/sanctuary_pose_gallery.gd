extends SceneTree
## v0.32.0 · CodexAI: comparable Godot frames of all six sanctuary poses.
## --before reconstructs only the historical v0.30/v0.31 atlas presentation.
func _initialize() -> void: run.call_deferred()

func run() -> void:
	var before := "--before" in OS.get_cmdline_user_args()
	var w = load("res://scenes/campaign.tscn").instantiate()
	root.add_child(w)
	w._enter(w.Beat.ECHO, 0, 0, false, false, false, false, 2)
	w.cutscene.abort()
	w.cutscene.begin()
	w.cutscene.hide()
	w.set_process(false)
	w.ui.hide()
	for actor in w.actors.get_children(): actor.set_physics_process(false)
	var t = w.sanctuary_tableau
	var old_regions := [Rect2(0,0,512,512),Rect2(512,0,512,512),Rect2(1024,0,512,512),Rect2(0,512,450,512),Rect2(480,512,544,512),Rect2(1024,512,512,512)]
	var old_anchors := [Vector2(250,507),Vector2(185,507),Vector2(185,507),Vector2(220,491),Vector2(270,382),Vector2(280,382)]
	for index in 6:
		w.sanctuary_stage = 2 if index < 3 else 0
		w._set_sanctuary_room()
		t.set_pose(index)
		t.sprite.show()
		w.raven.visible = index == 0
		w.raven.position = Vector2(580,346)
		w.raven.facing = Vector2.DOWN
		w.raven.animate("idle", 0.0)
		w.camera.position = Vector2(528,310) if index == 0 else (Vector2(528,296) if index < 3 else Vector2(603,273))
		w.camera.zoom = Vector2.ONE * (1.75 if index == 0 else (2.1 if index < 3 else 2.15))
		w.camera.force_update_scroll()
		if before:
			var atlas := AtlasTexture.new()
			atlas.atlas = load("res://assets/story/sanctuary/poses-seated.png")
			atlas.region = old_regions[index]
			t.sprite.texture = atlas
			t.sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			var cutout := ShaderMaterial.new()
			cutout.shader = load("res://shaders/pixel_cutout.gdshader")
			t.sprite.material = cutout
			t.sprite.position = (atlas.region.size * 0.5 - old_anchors[index]) * t.sprite.scale
			if index >= 3: t.sprite.position += Vector2(604,269 if index == 3 else 246) - t.SEAT
		w.scene_atmosphere.sync_profile()
		w.scene_atmosphere.elapsed = 9.0
		w.scene_atmosphere.set_process(false)
		w.scene_atmosphere.queue_redraw()
		w.queue_redraw()
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("/tmp/sanctuary-v032-%s-%d.png" % ["before" if before else "after", index])
	w.queue_free()
	await process_frame
	quit()
