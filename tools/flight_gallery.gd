## Requires a graphical display. Captures the Aerodyne flight phases and the
## landed craft on the roof: /tmp/shadepi-flight-*.png and docs/flug-*.png.
extends SceneTree

const Flight = preload("res://scripts/aerodyne_flight.gd")
const DOCS := ["schlucht", "abwehr", "kalibrierung", "landung", "dach"]

func _initialize() -> void:
	run.call_deferred()

func capture(name: String) -> void:
	for i in 3:
		await process_frame
	await RenderingServer.frame_post_draw
	var image: Image = root.get_texture().get_image()
	image.save_png("/tmp/shadepi-flight-%s.png" % name)
	if name in DOCS:
		image.save_png("res://docs/flug-%s.png" % name)

func settle(drive, seconds: float) -> void:
	var n := int(seconds * 60.0)
	for i in n:
		drive._process(1.0 / 60.0)

func run() -> void:
	root.size = Vector2i(1280, 720)
	var world = load("res://scenes/campaign.tscn").instantiate()
	root.add_child(world)
	await process_frame
	world.close_menu()
	world.started = true
	world._enter(world.Beat.FLIGHT)
	world.cutscene.abort()
	world.ui.clear_toast()
	var d = world.drive
	d.set_process(false)
	d.engine_repaired = true
	d.elapsed = 12.0
	d.next_spawn = 12.0
	settle(d, 1.4)
	d.hazards.clear()
	d.hazards.append({"k": "bridge", "p": Vector2(0, 150), "gap": 360.0, "w": 122.0, "near": false, "narrow": false})
	d.hazards.append({"k": "cargo", "p": Vector2(250, 92), "vx": 10.0, "near": false})
	d.hazards.append({"k": "cargo", "p": Vector2(410, 40), "vx": -10.0, "near": false})
	d.pos = Vector2(352, 262)
	d.roll = 0.32
	d.roll_dir = 1.0
	d.near_misses = 3
	d.say("KNAPP! · STUNT x3", 1.0)
	d.queue_redraw()
	await capture("schlucht")
	d.roll = 0.0
	d.hazards.clear()
	d.elapsed = d.DEFENCE_AT
	settle(d, 1.6)
	d.lasers.clear()
	d.lasers.append({"x": d.pos.x + 70.0, "warn": 0.5, "fire": 0.3, "src": d.sentries[1].p + Vector2(0, 12), "hit": false})
	d.lasers.append({"x": d.pos.x - 90.0, "warn": 0.0, "fire": 0.2, "src": d.sentries[0].p + Vector2(0, 12), "hit": true})
	d.queue_redraw()
	await capture("abwehr")
	d.lasers.clear()
	d.elapsed = d.SCAN_AT
	d._process(0.01)
	settle(d, 1.2)
	var c = d.calibration
	c.steps[0].locked = true
	c.index = 1
	var w: Vector2 = c.window()
	c.marker = (w.x + w.y) * 0.5
	settle(d, 0.02)
	d.queue_redraw()
	await capture("kalibrierung")
	c.marker = 0.1
	d.queue_redraw()
	await capture("kalibrierung-warten")
	d._scan_accepted()
	settle(d, 2.5)
	d.queue_redraw()
	await capture("anflug")
	d.approach_left = 0.0
	d.drifted = true
	d._process(0.01)
	settle(d, 1.2)
	d.shadow = d.pad_screen() + Vector2(40, -10)
	d.altitude = 0.35
	d.brake_held = true
	d.queue_redraw()
	await capture("landung")
	d.shadow = d.pad_screen() + Vector2(6, 2)
	d.altitude = 0.001
	d.descent = 0.2
	d._process(0.01)
	d._process(2.0)
	await process_frame
	world.cutscene.abort()
	world.ui.clear_toast()
	world.ui.clear_dialogue()
	world.player.show()
	world.camera.zoom = Vector2.ONE * Flight.ROOF_ZOOM
	world.camera.position = Flight.ROOF_CAMERA
	for i in 20:
		await process_frame
	await capture("dach")
	print("FLIGHT GALLERY: done")
	quit()
