extends SceneTree
const Pilot = preload("res://tools/legacy_pilot.gd")
func _initialize() -> void: run.call_deferred()
func capture(tag: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("/tmp/report8-" + tag + ".png")
func run() -> void:
	Engine.time_scale = 3
	Engine.max_fps = 60
	var w = load("res://scenes/campaign.tscn").instantiate()
	root.add_child(w)
	w._enter(w.Beat.ECHO)
	var seen := {}
	for i in 1100:
		await process_frame
		var t = w.sanctuary_tableau
		if t.speech.visible and not seen.has("bubble"):
			await capture("door-bubble")
			seen.bubble = true
		if t.sprite.visible and t.frame_index in [3,4,5] and w.cutscene.overlay.color.a < 0.01 and not seen.has(t.frame_index):
			await capture("sleep-%d" % t.frame_index)
			seen[t.frame_index] = true
		if w.cutscene.waiting_input: w.cutscene.advance()
		if not w.cutscene.running and w.sanctuary_stage == 1: break
	print("SLEEP GALLERY: stage=",w.sanctuary_stage," running=",w.cutscene.running," poses=",seen)
	if "--sleep-only" in OS.get_cmdline_user_args():
		var ok: bool = seen.has(5) and w.sanctuary_stage == 1
		w.queue_free()
		await process_frame
		quit(0 if ok else 1)
		return
	w.fresh_entry = true
	w._enter(w.Beat.FLIGHT)
	for i in 1500:
		await process_frame
		if not is_instance_valid(w.departure): break
		var d = w.departure
		var tag: String = "departure-" + d.stage
		if w.cutscene.overlay.color.a < 0.01 and not seen.has(tag):
			await capture(tag)
			seen[tag] = true
		if d.stage == "takeoff" and d.lift > 0.45 and not seen.has("lift"):
			await capture("departure-lift")
			seen.lift = true
		if w.cutscene.waiting_input: w.cutscene.advance()
	w._enter(w.Beat.ECHO, 0, 2, true, true, true, false)
	w.raven.position = w.Painted.ECHO_POINTS[2]
	w.interact()
	var scene = w.memory_scene
	for i in 4500:
		await process_frame
		if not is_instance_valid(scene) or scene.closed: break
		var tag: String = "legacy-" + scene.phase
		if scene.cutscene.overlay.color.a < 0.01 and not seen.has(tag):
			await capture(tag)
			seen[tag] = true
		if scene.cutscene.waiting_input: scene.cutscene.advance()
		if scene.phase == "final_battle" and scene.battle != null: Pilot.step(scene)
	print("REPORT8 GALLERY: ", seen)
	w.queue_free()
	await process_frame
	quit()
