extends SceneTree
## v0.36.0 · CodexAI. Actual arrival, four ritual steps and privacy-preserving kiss.
var seen := {}
var frames := 0
var film := false
var wait_time := 0.0

func _initialize() -> void: run.call_deferred()

func capture(tag: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("/tmp/shadepi-lake/"+tag+".png")
	seen[tag] = true

func frame(w, i: int) -> void:
	if film and i%3==0:
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("/tmp/shadepi-lake/film/frame-%04d.png"%frames)
		frames += 1
	if w.cutscene.waiting_input:
		wait_time += w.get_process_delta_time()
		if wait_time>0.9:
			w.cutscene.advance()
			wait_time = 0
	else: wait_time = 0

func run() -> void:
	if DisplayServer.get_name()=="headless":
		push_error("Lake gallery needs a real renderer")
		quit(1)
		return
	DirAccess.make_dir_recursive_absolute("/tmp/shadepi-lake/film")
	film = "--film" in OS.get_cmdline_user_args()
	var w = load("res://scenes/campaign.tscn").instantiate()
	root.add_child(w)
	w.set_visual_quality(2)
	Engine.time_scale = 1
	Engine.max_fps = 60
	w.fresh_entry = true
	w._enter(w.Beat.LAKE)
	for i in 3200:
		await process_frame
		var d = w.lake_sequence
		var tag: String = "arrival-"+d.stage
		if not seen.has(tag) and w.cutscene.overlay.color.a<0.01:
			var ready: bool = d.stage!="approach" or d.craft.x<850
			if d.stage=="exit_raven": ready = w.raven.modulate.a>0.99 and w.raven.position.distance_to(d.PARK+Vector2(58,0))>35
			if d.stage=="exit_shadepi": ready = w.player.modulate.a>0.99 and w.player.position.distance_to(d.PARK+Vector2(58,0))>45
			if ready: await capture(tag)
		await frame(w,i)
		if not w.cutscene.running: break
	for step in 4:
		w.player.position = w._target()
		w.interact()
		for i in 1600:
			await process_frame
			if w.beat==w.Beat.END: break
			if w.cutscene.waiting_input and not seen.has("ritual-"+str(step)): await capture("ritual-"+str(step))
			await frame(w,i)
			if not w.cutscene.running: break
		if w.beat==w.Beat.END: break
	for i in 2400:
		await process_frame
		var d = w.lake_sequence
		var tag: String = "finale-"+d.stage
		if not seen.has(tag):
			if d.stage in ["hands","rest"] or (d.stage=="mask" and d.tableau.pose==1) or (d.stage=="kiss" and d.tableau.pose==2) or (d.stage=="embrace" and d.tableau.pose==3) or (d.stage=="dragon" and d.dragon_passage>0.4): await capture(tag)
		await frame(w,i)
		if not w.cutscene.running: break
	await capture("finale-rest")
	# Compare the exact same new source pose beside regular game sprites.
	w.player.visual.show()
	w.player.cast_shadow.show()
	w.player.position = w.lake_sequence.tableau.position+Vector2(-65,0)
	w.raven.visual.show()
	w.raven.cast_shadow.show()
	w.raven.position = w.lake_sequence.tableau.position+Vector2(75,0)
	await process_frame
	await capture("pose-neighbors")
	print("LAKE GALLERY: ",seen,"; film frames=",frames)
	var ok := true
	for tag in ["arrival-approach","arrival-touchdown","arrival-exit_raven","arrival-exit_shadepi","arrival-shore","finale-mask","finale-kiss","finale-dragon","finale-embrace"]:
		if not seen.has(tag):
			push_error("Missing scene view: "+tag)
			ok = false
	w.queue_free()
	await process_frame
	quit(0 if ok else 1)
