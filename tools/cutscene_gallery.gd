extends SceneTree
## Plays every scripted cutscene in real time and saves frames to /tmp/shadepi-cutscene-*.png.
## xvfb-run godot --rendering-driver opengl3 --script res://tools/cutscene_gallery.gd
var out := "/tmp/shadepi-cutscene-"
var n := 0
func _initialize() -> void:
	run.call_deferred()
func shot(tag: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(out + "%02d-%s.png" % [n, tag]); n += 1
func play(scene, tag: String, every: int) -> void:
	var frames := 0
	while scene.in_cinematic() and frames < 3000:
		await process_frame
		frames += 1
		if scene.cutscene.waiting_input:
			await shot(tag)
			scene.cutscene.advance()
		elif frames % every == 0:
			await shot(tag + "_m")
func run() -> void:
	root.size = Vector2i(1280, 720)
	var c = load("res://scenes/campaign.tscn").instantiate()
	root.add_child(c)
	await create_timer(0.3).timeout
	c.close_menu(); c.started = true
	c.fresh_entry = true; c._enter(c.Beat.BOSS)
	await play(c, "penthouse", 45)
	await create_timer(0.8).timeout
	await shot("boss_fight")
	c.foes.back().take_damage(1000)
	await process_frame; await process_frame
	await play(c, "kenzo", 30)
	await create_timer(1.0).timeout
	await shot("lift_fight")
	c.fresh_entry = true; c._enter(c.Beat.END)
	await play(c, "finale", 40)
	c.queue_free(); await process_frame
	var one = load("res://scenes/chapter_one.tscn").instantiate()
	root.add_child(one)
	await create_timer(0.3).timeout
	one.close_menu(); one.started = true
	one._enter_checkpoint(one.Phase.HUNT)
	one._clear_encounter(); for p in one.patrol: p.health = 0
	one.trail_index = one.TRAIL.size(); one.set_gate(true); one.raven.position = one.ARENA_ENTRY + Vector2(10, 0)
	one._begin_duel()
	await play(one, "jackal", 40)
	one._lose_duel(); await create_timer(1.0).timeout
	while one.ui.dialogue_open: one.ui.advance_dialogue()
	await play(one, "landing", 8)
	await create_timer(0.5).timeout
	await shot("rescue_fight")
	quit()
