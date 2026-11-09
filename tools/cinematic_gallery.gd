extends SceneTree
## v0.35.1 · CodexAI. Roof pad first, then descent past the lower balcony.
var seen := {}
var frames := 0
var film := false
var escape_only := false

func _initialize() -> void: run.call_deferred()

func capture(tag: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("/tmp/shadepi-v0351/"+tag+".png")
	seen[tag] = true

func run() -> void:
	if DisplayServer.get_name()=="headless":
		push_error("Rendering display required")
		quit(1)
		return
	DirAccess.make_dir_recursive_absolute("/tmp/shadepi-v0351/film")
	film = "--film" in OS.get_cmdline_user_args()
	escape_only = "--escape-only" in OS.get_cmdline_user_args()
	var w = load("res://scenes/campaign.tscn").instantiate()
	root.add_child(w)
	w.set_visual_quality(2)
	Engine.time_scale = 1
	Engine.max_fps = 60
	w.fresh_entry = true
	w._enter(w.Beat.BOSS)
	var waiting := 0.0
	var opening_frames := 0 if escape_only else 2200
	for i in opening_frames:
		await process_frame
		if not seen.has("penthouse-entry") and not w.cutscene.waiting_input: await capture("penthouse-entry")
		if not seen.has("raven-approach") and w.raven.position.x>485 and not is_instance_valid(w.tower_grip): await capture("raven-approach")
		if is_instance_valid(w.tower_grip) and not seen.has("kenzo-grip"): await capture("kenzo-grip")
		if w.player.visible and w.player.position.x>380 and w.player.position.x<465 and not seen.has("shadepi-running"): await capture("shadepi-running")
		if w.cutscene.waiting_input:
			waiting += w.get_process_delta_time()
			if waiting>0.9:
				w.cutscene.advance()
				waiting = 0
		else: waiting = 0
		if not w.cutscene.running: break
	w._enter(w.Beat.ESCAPE,0,3)
	w._complete_point()
	waiting = 0
	for i in 2200:
		await process_frame
		if not is_instance_valid(w.tower_departure): break
		var d = w.tower_departure
		var tag: String = "escape-"+d.stage
		if not seen.has(tag) and (d.stage!="launch" or d.craft.distance_to(d.park)>40) and (d.stage!="ignition" or d.power>0.65) and (d.stage!="blast" or d.blast>0.45): await capture(tag)
		if d.stage=="fall":
			if d.craft.y>40 and d.craft.y<100 and not seen.has("facade-above"): await capture("facade-above")
			if d.craft.y>130 and d.craft.y<180 and not seen.has("facade-passing"): await capture("facade-passing")
		if d.stage=="ignition" and d.craft.y>230 and d.power>0.65 and not seen.has("facade-below"): await capture("facade-below")
		if film and i%2==0:
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png("/tmp/shadepi-v0351/film/frame-%04d.png"%frames)
			frames += 1
		if w.cutscene.waiting_input:
			waiting += w.get_process_delta_time()
			if waiting>0.9:
				w.cutscene.advance()
				waiting = 0
		else: waiting = 0
		if w.beat==w.Beat.LAKE: break
	w.fresh_entry = true
	w.flight_intro_pending = true
	w._enter(w.Beat.FLIGHT)
	waiting = 0
	var hangar_frames := 0 if escape_only else 3500
	for i in hangar_frames:
		await process_frame
		if not is_instance_valid(w.departure): break
		var d = w.departure
		if d.stage=="boarding" and w.cutscene.overlay.color.a<0.01:
			if not seen.has("hangar-entry"): await capture("hangar-entry")
			if d.squad[0].position.x>570 and d.squad[0].position.x<660 and not seen.has("hangar-aisle"): await capture("hangar-aisle")
			if d.squad[1].modulate.a<0.45 and d.squad[0].modulate.a>0.9 and not seen.has("hangar-boarding"): await capture("hangar-boarding")
		if d.stage=="takeoff" and d.lift>0.15 and d.lift<0.4 and not seen.has("hangar-takeoff"): await capture("hangar-takeoff")
		if w.cutscene.waiting_input:
			waiting += w.get_process_delta_time()
			if waiting>0.9:
				w.cutscene.advance()
				waiting = 0
		else: waiting = 0
	var required := ["penthouse-entry","raven-approach","kenzo-grip","shadepi-running","escape-run","escape-board","escape-tip","escape-fall","escape-ignition","escape-blast","hangar-entry","hangar-aisle","hangar-boarding","hangar-takeoff"]
	if escape_only: required = ["escape-run","escape-board","escape-launch","escape-tip","facade-above","facade-passing","facade-below","escape-ignition","escape-blast"]
	print("CINEMATIC GALLERY: ",seen,"; film frames=",frames)
	var ok := true
	for tag in required:
		if not seen.has(tag):
			push_error("Missing scene view: "+tag)
			ok = false
	w.queue_free()
	await process_frame
	quit(0 if ok else 1)
