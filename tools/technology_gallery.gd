extends SceneTree
## v0.42.0 · CodexAI. Actual idle objects, real power puzzle and decoder failure feedback.
const OUT := "/tmp/shadepi-technology-v042"
var frames := 0
var seen := {}
func _initialize(): run.call_deferred()
func capture(tag: String):
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OUT+"/"+tag+".png")
	seen[tag] = true
func device(w,id: String):
	for p in w.destructibles:
		if p.prop_id==id:return p
	return null
func film_frame():
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OUT+"/film/frame-%04d.png"%frames)
	frames += 1
func run():
	set_meta("shadepi_admin_testing",true)
	DirAccess.make_dir_recursive_absolute(OUT+"/film")
	Engine.max_fps = 60
	Engine.time_scale = 1
	var w = load("res://scenes/campaign.tscn").instantiate()
	root.add_child(w)
	w.restore_dressing_state({})
	w._enter(w.Beat.PACT)
	w.set_process(false)
	w.player.position = Vector2(650,480)
	w.raven.position = Vector2(677,490)
	w.camera.position = Vector2(660,420)
	w.camera.zoom = Vector2.ONE*1.8
	w.camera.force_update_scroll()
	for i in 15: await process_frame
	await capture("hideout-idle")
	w._enter(w.Beat.HANGAR)
	w.set_process(false)
	w.raven.position = w._target()
	w.camera.position = Vector2(220,290)
	w.camera.zoom = Vector2.ONE*1.3
	w.camera.force_update_scroll()
	var clock := 0.0
	var started := false
	var completed := false
	var source_frames := {}
	while clock<4.3:
		await process_frame
		clock += root.get_process_delta_time()
		var p = device(w,"spare_server")
		source_frames[p.sprite.frame] = true
		if clock>1.2 and not started:
			w.interact()
			started = true
		if started and not completed and clock>1.65:
			if not preload("res://tests/terminal_solver.gd").complete(w):
				quit(1)
				return
			completed = true
		if p.sprite.frame==6 and not seen.has("server-confirmed"): await capture("server-confirmed")
		if Engine.get_process_frames()%3==0: await film_frame()
	w._enter(w.Beat.GARAGE,0,1)
	w.set_process(false)
	w.player.position = w._target()
	w.raven.position = w._target()+Vector2(-28,10)
	w.camera.position = Vector2(540,290)
	w.camera.zoom = Vector2.ONE*2
	w.camera.force_update_scroll()
	w.interact()
	var panel = w.terminal
	panel.puzzle.filter = panel.puzzle.filter_target
	for i in panel.puzzle.WORDS.size():
		if panel.puzzle.WORDS[i]!=panel.puzzle.secret: panel.puzzle.guess(i)
		if panel.puzzle.failed:break
	for i in 2: await process_frame
	panel.finish(false)
	await capture("cabinet-fault")
	var box = device(w,"tool_case")
	box.take_damage(box.max_health/2)
	for i in 20: await process_frame
	await capture("cabinet-damaged")
	box.take_damage(box.max_health)
	await capture("cabinet-destroyed")
	print("TECHNOLOGY GALLERY: ",seen,"; server frames=",source_frames,"; film frames=",frames)
	w.queue_free()
	await process_frame
	quit(0 if seen.size()==5 and source_frames.size()==7 else 1)
