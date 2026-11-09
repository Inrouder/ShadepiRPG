extends SceneTree
## v0.43.0 · CodexAI. Actual unskipped Chapter-1 scenes, native renderer.
const OUT := "/tmp/shadepi-chapter1-v043"
var frames := {"intro":0,"rescue":0}
var clip := "intro"
var seen := {}
var delay := 0.0
var stage_time := 0.0
var previous := ""
func _initialize(): run.call_deferred()
func capture(tag: String):
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OUT+"/"+tag+".png")
	seen[tag] = true
func play(w):
	for i in 6500:
		await process_frame
		if w.cutscene.waiting_input:
			delay += w.get_process_delta_time()
			if delay > 1.05:
				w.cutscene.advance()
				delay = 0
		else: delay = 0
		var stage: String = w.intro.stage
		if stage != previous:
			previous = stage
			stage_time = 0
		else: stage_time += w.get_process_delta_time()
		if stage != "idle" and not seen.has(stage) and stage_time > (0.7 if stage.begins_with("roof") else 0.08):
			await capture(stage)
		if i%4==0:
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png(OUT+"/"+clip+"/frame-%04d.png"%frames[clip])
			frames[clip] += 1
		if not w.cutscene.running: return
	push_error("Chapter-1 capture exceeded limit")
func run():
	set_meta("shadepi_admin_testing",true)
	for c in frames: DirAccess.make_dir_recursive_absolute(OUT+"/"+c)
	Engine.max_fps = 60
	var w = load("res://scenes/chapter_one.tscn").instantiate()
	root.add_child(w)
	w.restore_dressing_state({})
	w.new_game(false)
	await play(w)
	await capture("hunt")
	clip = "rescue"
	w._enter_checkpoint(w.Phase.ROOFTOP)
	w.phase = w.Phase.ROOFTOP
	w.raven.position = w.DOWNED_SPOT
	w.enemy.position = w.DOWNED_SPOT+Vector2(70,-10)
	w.enemy.show()
	w.raven.show()
	w.feedback_time = INF
	w._rooftop_dialogue()
	await play(w)
	await capture("rescue-ready")
	print("CHAPTER1_FILM_FRAMES ",frames," STAGES ",seen.keys())
	w.cutscene.abort()
	await process_frame
	w.free()
	await process_frame
	quit()
