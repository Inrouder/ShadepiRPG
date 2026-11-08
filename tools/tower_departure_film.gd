extends SceneTree
## v0.33.0 · CodexAI: real engine frames, encoded separately without compositing.
func _initialize() -> void: run.call_deferred()
func run() -> void:
	if DisplayServer.get_name()=="headless":
		push_error("Tower film requires a real renderer.")
		quit(1)
		return
	DirAccess.make_dir_recursive_absolute("/tmp/tower-film")
	var w = load("res://scenes/campaign.tscn").instantiate()
	root.add_child(w)
	Engine.time_scale = 1
	Engine.max_fps = 60
	w._enter(w.Beat.ESCAPE,0,3)
	w._complete_point()
	var frames := 0
	var waiting := 0
	for i in 1600:
		await process_frame
		if w.cutscene.waiting_input:
			waiting += 1
			if waiting>=42:
				w.cutscene.advance()
				waiting = 0
		else: waiting = 0
		if i%5==0:
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png("/tmp/tower-film/frame-%04d.png"%frames)
			frames += 1
		if w.beat==w.Beat.LAKE: break
	print("TOWER FILM: ",frames," actual frames, reached lake=",w.beat==w.Beat.LAKE)
	w.queue_free()
	await process_frame
	quit()
