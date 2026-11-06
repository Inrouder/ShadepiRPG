extends SceneTree
## Plays every scripted cutscene in real time and saves one frame per subtitle
## (plus a few motion frames) to /tmp/shadepi-cutscene-*.png.
## xvfb-run godot --rendering-driver opengl3 --script res://tools/cutscene_gallery.gd [-- filter]
var out := "/tmp/shadepi-cutscene-"
var n := 0
var filter := ""

func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	filter = args[0] if not args.is_empty() else ""
	run.call_deferred()

func shot(tag: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(out + "%03d-%s.png" % [n, tag])
	n += 1

func play(scene, tag: String, every: int = 90) -> void:
	if not filter.is_empty() and not tag.contains(filter):
		while scene.in_cinematic():
			scene.cutscene.skip()
			await process_frame
		return
	var frames := 0
	while frames < 6000:
		await process_frame
		frames += 1
		if not scene.in_cinematic():
			await process_frame
			if not scene.in_cinematic():
				break
		if scene.cutscene.waiting_input:
			await shot(tag)
			scene.cutscene.advance()
		elif frames % every == 0:
			await shot(tag + "_m")

func run() -> void:
	root.size = Vector2i(1280, 720)
	var one = load("res://scenes/chapter_one.tscn").instantiate()
	root.add_child(one)
	await create_timer(0.3).timeout
	one.close_menu(); one.started = true
	one.new_game(false)
	await play(one, "c1-apartment")
	one._clear_encounter(); for p in one.patrol: p.health = 0
	one.trail_index = one.TRAIL.size(); one.set_gate(true); one.raven.position = one.ARENA_ENTRY + Vector2(10, 0)
	one._begin_duel()
	await play(one, "c1-jackal")
	one._lose_duel(); await create_timer(1.0).timeout
	await play(one, "c1-rooftop")
	await play(one, "c1-landing", 20)
	one._clear_encounter(); for p in one.patrol: p.health = 0
	one.set_gate(true); one.player.position = one.raven.position + Vector2(-90, 10)
	one.phase = one.Phase.REVIVE; one._scene_revive()
	await play(one, "c1-revive")
	one.raven.health = 100; one.raven.reset_visual_pose(); one.raven_joined = true
	one.enemy.health = 0; one.enemy.active = false
	one._begin_epilogue()
	await play(one, "c1-epilogue", 40)
	one.queue_free(); await process_frame
	var two = load("res://scenes/chapter_two.tscn").instantiate()
	root.add_child(two)
	await create_timer(0.3).timeout
	two.close_menu(); two.started = true
	two.new_game(false)
	await play(two, "c2-arrival", 30)
	two.scan_index = 3; two.player.position = two.DOOR; two.interact()
	await play(two, "c2-knock")
	await play(two, "c2-hideout")
	two.player.position = two.WORKBENCH; two.interact()
	await play(two, "c2-fragment")
	two.player.position = two.BATH; two.interact()
	await play(two, "c2-dive")
	two._finish_download()
	await play(two, "c2-return")
	two._finish_chapter()
	await play(two, "c2-oath")
	await play(two, "c2-end")
	two.queue_free(); await process_frame
	var c = load("res://scenes/campaign.tscn").instantiate()
	root.add_child(c)
	await create_timer(0.3).timeout
	c.close_menu(); c.started = true
	for beat in [c.Beat.PACT, c.Beat.AMBUSH, c.Beat.GARAGE, c.Beat.HANGAR, c.Beat.ECHO, c.Beat.ROOF, c.Beat.BOSS]:
		c.fresh_entry = true; c._enter(beat)
		await play(c, "c%d-beat%d" % [c.Story.CHAPTERS[beat], beat])
	c.foes.back().take_damage(1000)
	await process_frame; await process_frame
	await play(c, "c6-kenzo")
	c.fresh_entry = true; c._enter(c.Beat.LAKE)
	await play(c, "c7-lake")
	c.fresh_entry = true; c._enter(c.Beat.END)
	await play(c, "c7-finale", 50)
	print("cutscene frames: ", n)
	quit()
