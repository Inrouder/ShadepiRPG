extends SceneTree
## v0.39.0 · CodexAI. Actual decoder callback, platform trip and playable hangar.
var seen := {}
var frames := 0
var wait_time := 0.0
const OUT := "/tmp/shadepi-hangar-v039"
func _initialize(): run.call_deferred()
func capture(tag: String):
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OUT+"/"+tag+".png")
	seen[tag] = true
func run():
	DirAccess.make_dir_recursive_absolute(OUT+"/film")
	var w = load("res://scenes/campaign.tscn").instantiate()
	root.add_child(w)
	Engine.time_scale = 1
	Engine.max_fps = 60
	w._enter(w.Beat.GARAGE,0,1)
	w.player.position = w._target()
	w.raven.position = w._target()+Vector2(-28,10)
	w.interact()
	if not preload("res://tests/terminal_solver.gd").complete(w):
		push_error("Gallery could not complete the actual garage decoder")
		quit(1)
		return
	for i in 8000:
		await process_frame
		if is_instance_valid(w.hangar_discovery):
			var d = w.hangar_discovery
			var key: String = d.stage
			var ready: bool = w.cutscene.overlay.color.a<0.01
			if key=="switch": ready = ready and d.switch_pose.visible and d.switch_pose.frame==2
			if key=="unlock": ready = ready and d.deck_frame>=3
			if key=="descent": ready = ready and d.travel>0.4 and d.travel<0.65
			if key=="aircraft": ready = ready and w.camera.position.distance_to(w.HangarArt.CRAFT)<8
			if key=="reaction": ready = ready and w.cutscene.waiting_input
			if ready and not seen.has(key): await capture(key)
		if i%3==0:
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png(OUT+"/film/frame-%04d.png"%frames)
			frames += 1
		if w.cutscene.waiting_input:
			wait_time += w.get_process_delta_time()
			if wait_time>0.9:
				w.cutscene.advance()
				wait_time = 0
		else: wait_time = 0
		if not w.cutscene.running: break
	await capture("playable-hangar")
	print("HANGAR DISCOVERY GALLERY: ",seen,"; film frames=",frames,"; beat=",w.beat)
	var ok: bool = w.beat==w.Beat.HANGAR and not w.discovery_pending
	for key in ["switch","unlock","descent","dock","opening","aircraft","reaction","briefing","shadepi_leaves"]: ok = ok and seen.has(key)
	w.queue_free()
	await process_frame
	quit(0 if ok else 1)
