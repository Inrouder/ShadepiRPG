extends SceneTree
## v0.31.0 · CodexAI: comparable real game frames for the visual audit.
var suffix := "before"
func _initialize() -> void: run.call_deferred()
func stop(w) -> void:
	w.cutscene.abort()
	w.close_menu()
	w.ui.clear_dialogue()
	w.set_process(false)
	for actor in w.actors.get_children():
		actor.set_physics_process(false)
	for node in w.ui.game_hud_nodes: node.hide()
	w.ui.controls.hide()
	w.ui.hide()
	if w.get("drive") != null: w.drive.set_process(false)
func capture(w, tag: String, center: Vector2, zoom: float = 1.0) -> void:
	stop(w)
	w.camera.position = center
	w.camera.zoom = Vector2.ONE * zoom
	w.camera.force_update_scroll()
	if w.get("scene_atmosphere") != null:
		w.scene_atmosphere.sync_profile()
		w.scene_atmosphere.elapsed = 9.0
		w.scene_atmosphere.queue_redraw()
	w.queue_redraw()
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("/tmp/atmosphere-" + suffix + "-" + tag + ".png")
func run() -> void:
	if "--after" in OS.get_cmdline_user_args(): suffix = "after"
	var one = load("res://scenes/chapter_one.tscn").instantiate()
	root.add_child(one)
	one.set_visual_quality(2)
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("/tmp/atmosphere-" + suffix + "-menu.png")
	one._enter_checkpoint(one.Phase.APARTMENT)
	await capture(one, "apartment", one.APARTMENT_CAMERA, one.APARTMENT_ZOOM)
	one._enter_checkpoint(one.Phase.HUNT)
	await capture(one, "market", Vector2(-320, 350))
	await capture(one, "alley", Vector2(320, 350))
	one._enter_checkpoint(one.Phase.TEAM)
	await capture(one, "jackal", Vector2(770, 350))
	one.queue_free()
	await process_frame
	var two = load("res://scenes/chapter_two.tscn").instantiate()
	root.add_child(two)
	two.set_visual_quality(2)
	for item in [[two.Section.YARD,"industry"],[two.Section.HIDEOUT,"hideout"],[two.Section.DIVE,"dive"],[two.Section.RECOVERY,"recovery"]]:
		two._enter(item[0])
		await capture(two, item[1], Vector2(512, 350), 0.85)
	two.queue_free()
	await process_frame
	var w = load("res://scenes/campaign.tscn").instantiate()
	root.add_child(w)
	w.set_visual_quality(2)
	for item in [[w.Beat.PACT,"pact"],[w.Beat.AMBUSH,"ambush"],[w.Beat.CHASE,"chase"],[w.Beat.GARAGE,"garage"],[w.Beat.HANGAR,"hangar"],[w.Beat.FLIGHT,"flight"],[w.Beat.ROOF,"roof"],[w.Beat.BOSS,"suite"],[w.Beat.ESCAPE,"escape"],[w.Beat.LAKE,"lake"],[w.Beat.END,"ending"]]:
		w._enter(item[0])
		await capture(w, item[1], Vector2(512, 350), 0.8)
	w._enter(w.Beat.ECHO,0,0,false,false,false,false,1)
	await capture(w, "living", w.Painted.CHAMBER_CAMERA, 1.15)
	w._enter(w.Beat.ECHO,0,0,false,false,false,false,2)
	w.raven.position = Vector2(590, 349)
	await capture(w, "compensator", Vector2(530, 320), 1.6)
	w._enter(w.Beat.ECHO,0,0,true)
	await capture(w, "echo", Vector2(600, 350), 0.85)
	w._enter(w.Beat.HANGAR)
	w.cutscene.abort()
	w.open_terminal("transponder", func(): pass)
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("/tmp/atmosphere-" + suffix + "-hack.png")
	w.cancel_terminal()
	w.queue_free()
	await process_frame
	for name in ["attack","sacrifice","legacy"]:
		var memory = load("res://scenes/memories/" + name + ".tscn").instantiate()
		memory.autoplay = false
		root.add_child(memory)
		memory.camera.position = Vector2(512, 330)
		memory.camera.zoom = Vector2.ONE * 0.7
		memory.ui.hide()
		memory.map.elapsed = 9.0
		if memory.get("scene_atmosphere") != null:
			memory.scene_atmosphere.sync_profile()
			memory.scene_atmosphere.elapsed = 9.0
			memory.scene_atmosphere.queue_redraw()
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("/tmp/atmosphere-" + suffix + "-memory-" + name + ".png")
		memory.queue_free()
		await process_frame
	print("ATMOSPHERE GALLERY: ", suffix, " · seven chapters, menu, hack and three memories captured")
	quit()
