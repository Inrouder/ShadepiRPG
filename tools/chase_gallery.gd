extends SceneTree
## Plays the motorcycle chase with scripted input and the garage arrival;
## frames go to /tmp/shadepi-chase-*.png (needs a display, e.g. xvfb-run).
var n := 0

func _initialize() -> void:
	run.call_deferred()

func shot(tag: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("/tmp/shadepi-chase-%02d-%s.png" % [n, tag])
	n += 1

func hold(action: String, seconds: float) -> void:
	Input.action_press(action)
	await create_timer(seconds).timeout
	Input.action_release(action)

func run() -> void:
	root.size = Vector2i(1280, 720)
	var c = load("res://scenes/campaign.tscn").instantiate()
	root.add_child(c)
	await create_timer(0.3).timeout
	c.close_menu(); c.started = true
	c._enter(c.Beat.CHASE)
	while c.in_cinematic(): c.cutscene.skip(); await process_frame
	var d = c.drive
	d.health = 1000
	Input.action_press("attack")
	await hold("move_up", 1.5)
	await shot("forward")
	await hold("move_right", 0.6)
	await create_timer(1.5).timeout
	await shot("right")
	await hold("move_down", 1.2)
	d.drones.append({"p": Vector2(d.x, 92.0), "state": "hover", "t": 0.0, "drops": 0, "spin": 0.0})
	await create_timer(2.2).timeout
	await shot("drone")
	d.hack_cooldown = 0.0
	await hold("hack", 0.05)
	await create_timer(0.35).timeout
	await shot("drone-hacked")
	d.objects.append({"k": "boost", "p": Vector2(d.x, d.bike_y - 60), "done": false, "r": 0.0})
	d.objects.append({"k": "wreck", "p": Vector2(236, d.bike_y - 120), "done": false, "r": 0.3})
	d.objects.append({"k": "slick", "p": Vector2(404, d.bike_y - 90), "done": false, "r": 0.0})
	await create_timer(0.35).timeout
	await shot("objects")
	Input.action_release("attack")
	d.armour = 0
	await create_timer(0.5).timeout
	await shot("victory")
	await create_timer(1.2).timeout
	for i in 26:
		await create_timer(0.45).timeout
		if c.cutscene.waiting_input:
			await shot("garage-say")
			c.cutscene.advance()
		else:
			await shot("garage")
	quit()
