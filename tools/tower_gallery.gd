extends SceneTree
## v0.33.0 · CodexAI: actual in-engine sequence and branding review frames.
var seen := {}
func _initialize() -> void: run.call_deferred()
func capture(tag: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("/tmp/tower-"+tag+".png")
	seen[tag] = true
func run() -> void:
	var w = load("res://scenes/campaign.tscn").instantiate()
	root.add_child(w)
	w.set_visual_quality(2)
	Engine.time_scale = 3
	Engine.max_fps = 60
	w.fresh_entry = true
	w._enter(w.Beat.BOSS)
	for i in 1500:
		await process_frame
		if is_instance_valid(w.tower_grip) and not seen.has("grip") and w.cutscene.waiting_input:
			await capture("grip")
		if w.cutscene.waiting_input: w.cutscene.advance()
		if not w.cutscene.running: break
	w.foes.back().take_damage(1000)
	for i in 1500:
		await process_frame
		if w.beat!=w.Beat.ESCAPE: continue
		if not seen.has("kneel") and w.cutscene.waiting_input:
			await capture("kneel")
		if w.cutscene.waiting_input: w.cutscene.advance()
		if is_instance_valid(w.tower) and w.tower.active: break
	for f in w.foes: f.set_physics_process(false)
	w.camera.position = w.boss_spot+Vector2(-85,-35)
	w.camera.zoom = Vector2.ONE*1.4
	w.set_process(false)
	await capture("protect")
	w.set_process(true)
	w.tower.elapsed = w.tower.TRANSFER_SECONDS
	for i in 300:
		for f in w.foes:
			if f.health>0:
				f.front_shield = false
				f.take_damage(1000)
		if is_instance_valid(w.encounter): w.encounter._process(4)
		await process_frame
		if w.tower_stage==1: break
	for i in 1500:
		await process_frame
		if w.cutscene.waiting_input:
			if not seen.has("truth"): await capture("truth")
			w.cutscene.advance()
		if w.tower.tableau.mode=="dead" and not seen.has("shutdown"):
			await capture("shutdown")
		if w.tower_stage==2 and not w.cutscene.running: break
	w.point_index = 3
	w._complete_point()
	for i in 2000:
		await process_frame
		if not is_instance_valid(w.tower_departure): break
		var d = w.tower_departure
		var tag: String = "departure-"+d.stage
		if not seen.has(tag) and (d.stage!="blast" or d.blast>0.5) and w.cutscene.overlay.color.a<0.01:
			await capture(tag)
		if w.cutscene.waiting_input: w.cutscene.advance()
		if w.beat==w.Beat.LAKE: break
	w._enter(w.Beat.HANGAR)
	w.cutscene.abort()
	w.ui.hide()
	w.set_process(false)
	w.camera.position = Vector2(600,230)
	w.camera.zoom = Vector2.ONE*0.85
	w.camera.force_update_scroll()
	w.queue_redraw()
	await capture("koban-hangar")
	w.fresh_entry = true
	w._enter(w.Beat.FLIGHT)
	await capture("koban-departure")
	print("TOWER GALLERY: ",seen)
	var ok: bool = seen.has("grip") and seen.has("kneel") and seen.has("protect") and seen.has("truth") and seen.has("departure-blast")
	w.queue_free()
	await process_frame
	quit(0 if ok else 1)
