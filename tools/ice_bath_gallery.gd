extends SceneTree
## v0.38.0 · CodexAI. Real entry, return, walking to the spray and complete rescue.
var frames := {"entry":0,"rescue":0}
var clip := "entry"
var seen := {}
var wait_time := 0.0
var out := "/tmp/shadepi-ice-v038"
func _initialize(): run.call_deferred()
func capture(tag: String):
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(out+"/"+tag+".png")
	seen[tag] = true
func frame(w, i: int):
	if i%3==0:
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(out+"/"+clip+"/frame-%04d.png"%frames[clip])
		frames[clip] += 1
	if w.cutscene.waiting_input:
		wait_time += w.get_process_delta_time()
		if wait_time>0.75:
			w.cutscene.advance()
			wait_time = 0
	else: wait_time = 0
func play(w, prefix: String):
	for i in 5000:
		await process_frame
		if is_instance_valid(w.ice_bath):
			var d = w.ice_bath
			var key: String = prefix+"-"+d.stage
			if d.visible and not seen.has(key) and (d.mix_value>0.85 or d.pose==d.target_pose): await capture(key)
		await frame(w,i)
		if not w.cutscene.running: return
	push_error("Gallery scene failed to finish: "+prefix)
func walk(w, targets: Array):
	var cs = w.begin_cutscene()
	for point in targets:
		cs.walk(w.player,point,82)
		for i in 1200:
			await process_frame
			await frame(w,i)
			if w.player.position.distance_to(point)<0.05: break
	cs.end()
	await play(w,"fetch")
func run():
	DirAccess.make_dir_recursive_absolute(out+"/entry")
	DirAccess.make_dir_recursive_absolute(out+"/rescue")
	var w = load("res://scenes/chapter_two.tscn").instantiate()
	root.add_child(w)
	Engine.max_fps = 60
	Engine.time_scale = 1
	w._enter(w.Section.COOLING)
	w.raven.position = w.IceBath.APPROACH
	w.player.position = w.IceBath.PLAYER_WAIT
	w._scene_dive()
	await play(w,"entry")
	await capture("network")
	# QA ends the data segment here. It is deliberately absent from both clips.
	clip = "rescue"
	w._finish_download()
	await play(w,"return")
	await capture("waiting-spray")
	await walk(w,[Vector2(610,432),Vector2(530,432)])
	w.interact()
	await capture("spray-picked")
	await walk(w,[Vector2(610,432),Vector2(636,392)])
	w.interact()
	await play(w,"rescue")
	await capture("chapter-end")
	var comparison = w.IceBath.new()
	comparison.world = w
	w.actors.add_child(comparison)
	comparison.set_pose(7)
	comparison.show()
	w.raven.position = w.IceBath.SEAT+Vector2(55,20)
	w.player.position = w.IceBath.SEAT+Vector2(-58,20)
	w.camera.position = Vector2(656,346)
	w.camera.zoom = Vector2.ONE*2.0
	await process_frame
	await capture("pose-neighbors")
	print("ICE BATH GALLERY: ",seen,"; film frames=",frames,"; end=",w.section)
	w.queue_free()
	await process_frame
	quit()
