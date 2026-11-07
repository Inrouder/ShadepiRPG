extends SceneTree
## Renders Ravens Apartment, a melee combo with hit feedback and the net fight
## to /tmp/shadepi-feedback-*.png (needs a display, e.g. xvfb-run).
var n := 0

func _initialize() -> void:
	run.call_deferred()

func shot(tag: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("/tmp/shadepi-feedback-%02d-%s.png" % [n, tag])
	n += 1

func run() -> void:
	root.size = Vector2i(1280, 720)
	var one = load("res://scenes/chapter_one.tscn").instantiate()
	root.add_child(one)
	await create_timer(0.3).timeout
	one.close_menu(); one.started = true
	one.new_game(false)
	await create_timer(4.0).timeout
	one.cutscene.advance(); await create_timer(0.2).timeout
	await shot("apartment")
	one.cutscene.advance(); await create_timer(2.5).timeout
	await shot("apartment-terminal")
	one.queue_free(); await process_frame
	var c = load("res://scenes/campaign.tscn").instantiate()
	root.add_child(c)
	await create_timer(0.3).timeout
	c.close_menu(); c.started = true
	c._enter(c.Beat.AMBUSH)
	while c.in_cinematic(): c.cutscene.skip(); await process_frame
	await create_timer(0.4).timeout
	var foe = c.foes[0]
	c.player.position = foe.position + Vector2(-34, 4)
	c.player.facing = Vector2.RIGHT
	for i in 3:
		Input.action_press("attack"); await physics_frame; Input.action_release("attack")
		await create_timer(0.17).timeout
		await shot("combo%d" % i)
		await create_timer(0.2).timeout
	await create_timer(0.3).timeout
	await shot("after-combo")
	c.queue_free(); await process_frame
	var two = load("res://scenes/chapter_two.tscn").instantiate()
	root.add_child(two)
	await create_timer(0.3).timeout
	two.close_menu(); two.started = true
	two._enter(two.Section.DIVE, 1)
	await create_timer(0.5).timeout
	var v = two.threats[0]
	two.raven.position = v.position + Vector2(-70, 14)
	two.raven.facing = Vector2.RIGHT
	v.elapsed = 0.3
	two.raven_shot()
	await create_timer(0.08).timeout
	await shot("net-crack")
	quit()
