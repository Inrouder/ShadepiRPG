extends SceneTree
## v0.45.0 · CodexAI. Unskipped reported scenes; actual gameplay render timing.
const OUT:="/tmp/shadepi-report-v045-film"
var frames:=0
var tick_count:=0
var wait_time:=0.0
func _initialize():run.call_deferred()
func frame(w):
	await process_frame
	if w.cutscene.waiting_input:
		wait_time+=w.get_process_delta_time()
		if wait_time>0.6:w.cutscene.advance();wait_time=0
	else:wait_time=0
	tick_count+=1
	if tick_count%4==0:
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(OUT+"/frame-%04d.png"%frames)
		frames+=1
func play(w):
	for i in 5000:
		await frame(w)
		if not w.cutscene.running:return
	push_error("Reported scene did not complete")
func run():
	set_meta("shadepi_admin_testing",true)
	DirAccess.make_dir_recursive_absolute(OUT)
	Engine.max_fps=60
	var w=load("res://scenes/chapter_one.tscn").instantiate();root.add_child(w)
	w._enter_checkpoint(w.Phase.HUNT);w._clear_encounter();w.cutscene.abort()
	w.raven.position=Vector2(636,365);w.enemy.position=Vector2(700,360);w.enemy.show()
	w._lose_duel()
	for i in 70:await frame(w)
	w.cutscene.abort()
	w._enter_checkpoint(w.Phase.TEAM);w.cutscene.abort();w._raven_rejoins()
	w.enemy.health=1;w.enemy.min_health=0
	w.player.position=Vector2(720,420);w.raven.position=Vector2(760,435);w.enemy.position=Vector2(790,420)
	w.enemy.take_damage(100,w.player.position)
	for i in 100:await frame(w)
	w.cutscene.abort();w.free();await process_frame
	w=load("res://scenes/chapter_two.tscn").instantiate();root.add_child(w)
	w._enter(w.Section.HIDEOUT);w.cutscene.abort();w._scene_hideout()
	await play(w)
	w.free();await process_frame
	w=load("res://scenes/campaign.tscn").instantiate();root.add_child(w)
	w.restore_dressing_state({});w.fresh_entry=true;w._enter(w.Beat.GARAGE)
	await play(w)
	w.player.position=w._target();w.interact()
	preload("res://tests/terminal_solver.gd").complete(w)
	await play(w)
	w._enter(w.Beat.ECHO,0,0,false,false,false,false,2);w.cutscene.abort()
	w.SanctuaryStory.aftermath(w)
	await play(w)
	w.cutscene.abort();w.free();await process_frame
	print("REPORT_FILM_FRAMES ",frames)
	quit()
