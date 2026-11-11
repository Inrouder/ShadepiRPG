extends SceneTree
## Aerodyne flight (v0.21.2): canyon dodging, roll, engine repair, tower defence,
## sequence calibration with visible window, alarm retry, drift and landing.
const Flight = preload("res://scripts/aerodyne_flight.gd")
const Calibration = preload("res://scripts/sequence_calibration.gd")
var checks := 0
var failures := 0

class World extends Node2D:
	var busy := false
	var visual_quality := 2
	var terminal: CanvasLayer
	var god := false
	var sounds: Array[String] = []
	func open_terminal(context: String, callback: Callable) -> void:
		if busy: return
		busy = true
		terminal = preload("res://scripts/terminal_ui.gd").new()
		terminal.context = context
		add_child(terminal)
		terminal.finished.connect(func(success):
			terminal.queue_free()
			terminal = null
			busy = false
			if success: callback.call()
		)
	func is_busy() -> bool: return busy
	func admin_enabled(key: String) -> bool: return god and key == "god_mode"
	func sound(key: String) -> void: sounds.append(key)
	func toast(_text: String) -> void: pass

func _initialize() -> void:
	run.call_deferred()

func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("FAIL: " + label)

func make(world: World) -> Node2D:
	var flight = Flight.new()
	flight.world = world
	world.add_child(flight)
	flight.set_process(false)
	return flight

func repaired(world: World, flight) -> void:
	flight.start_engine_failure()
	check(preload("res://tests/terminal_solver.gd").complete(world), "jumper repair accepted")

func step(flight, seconds: float, fps: float = 60.0) -> void:
	var n := int(seconds * fps)
	for i in n:
		flight._process(1.0 / fps)

func solve_calibration(flight) -> void:
	var c = flight.calibration
	var guard := 0
	while c.state == "run" and guard < 4000:
		guard += 1
		if c.in_window():
			flight.calibration_input(int(c.current().dir))
		else:
			flight._process(1.0 / 120.0)

func run() -> void:
	for action in ["move_left", "move_right", "move_up", "move_down", "attack", "hack", "dash"]:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
	var world := World.new()
	root.add_child(world)
	await process_frame

	# --- Calibration logic on its own.
	var c = Calibration.new(5, 5)
	check(c.steps.size() == 5 and c.state == "run", "calibration builds a five-step code")
	c.marker = 0.0
	check(c.press(int(c.current().dir)) == "early" and c.errors == 1, "input outside the hull window is an error")
	var w: Vector2 = c.window()
	c.marker = (w.x + w.y) * 0.5
	check(c.press((int(c.current().dir) + 1) % 4) == "wrong" and c.errors == 2, "wrong direction is an error")
	check(c.press(int(c.current().dir)) == "lock" and c.index == 1, "right direction inside the window locks the step")
	c.marker = 0.0
	c.press(0)
	check(c.state == "failed", "three deviations reject the ID")
	var slow = Calibration.new(9, 5)
	for i in 100: slow.tick(0.2)
	check(slow.state == "failed" and slow.time_left == 0.0, "scanner pass ends after its time budget")
	var ping = Calibration.new(3, 5)
	var low := 1.0
	var high := 0.0
	for i in 400:
		ping.tick(0.01)
		low = minf(low, ping.marker)
		high = maxf(high, ping.marker)
	check(low < 0.05 and high > 0.95, "beam sweeps over the whole scanner range")

	# --- Canyon: steering, throttle, roll, hazards and near misses.
	var f = make(world)
	repaired(world, f)
	f.elapsed = 9.0
	Input.action_press("move_right")
	step(f, 0.6)
	Input.action_release("move_right")
	check(f.pos.x > 380.0, "free steering crosses the canyon")
	Input.action_press("move_up")
	step(f, 0.8)
	Input.action_release("move_up")
	check(f.speed > 1.2 and f.pos.y < 250.0, "thrust speeds up and moves the Aerodyne forward")
	var before_x: float = f.pos.x
	Input.action_press("dash")
	f._process(1.0 / 60.0)
	Input.action_release("dash")
	check(f.roll > 0.0 and f.roll_cooldown > 0.0, "dash starts the evasive roll")
	step(f, 0.2)
	check(absf(f.pos.x - before_x) > 30.0, "the roll throws the Aerodyne sideways")
	step(f, 1.2)
	f.hazards.clear()
	f.hurt = 0.0
	f.health = 100
	f.hazards.append({"k": "cargo", "p": Vector2(f.pos.x, f.pos.y - 30.0), "vx": 0.0, "near": false})
	step(f, 0.3)
	check(f.health < 100, "cargo drone collision damages the hull")
	f.hazards.clear()
	f.hurt = 0.0
	f.pos.x = 320.0
	f.vel = Vector2.ZERO
	var health_before: int = f.health
	f.hazards.append({"k": "cargo", "p": Vector2(f.pos.x + 48.0, f.pos.y - 30.0), "vx": 0.0, "near": false})
	step(f, 0.3)
	check(f.near_misses >= 1 and f.health >= health_before, "close passes count as stunts and do not hurt")
	f.hazards.clear()
	f.hurt = 0.0
	f.health = 100
	f.pos.x = 320.0
	f.vel = Vector2.ZERO
	f.hazards.append({"k": "bridge", "p": Vector2(0, f.pos.y - 30.0), "gap": 320.0, "w": 50.0, "near": false, "narrow": true})
	step(f, 0.3)
	check(f.health < 100, "a narrow bridge gap clips the wings without a roll")
	f.hazards.clear()
	f.hurt = 0.0
	f.health = 100
	f.pos.x = 320.0
	f.vel = Vector2.ZERO
	f.roll = 0.5
	f.hazards.append({"k": "bridge", "p": Vector2(0, f.pos.y - 12.0), "gap": 320.0, "w": 50.0, "near": false, "narrow": true})
	f.roll_dir = 0.0
	f.roll = 0.5
	for i in 8:
		f.vel.x = 0.0
		f.pos.x = 320.0
		f._process(1.0 / 60.0)
	check(f.health == 100, "rolling slips through a narrow gap")

	# --- Tower defence: telegraphed lasers, roll dodges them.
	f.elapsed = f.DEFENCE_AT
	f.hazards.clear()
	f._process(1.0 / 60.0)
	check(f.phase == "defence" and f.sentries.size() == 2, "tower defence drones arrive")
	f.lasers.clear()
	f.hurt = 0.0
	f.health = 100
	f.roll = 0.0
	f.lasers.append({"x": f.pos.x, "warn": 0.2, "fire": 0.3, "src": Vector2(320, 50), "hit": false})
	step(f, 0.1)
	check(f.health == 100, "the warning line alone does no damage")
	step(f, 0.25)
	check(f.health < 100, "a fired laser hits when the Aerodyne stays in the line")
	f.lasers.clear()
	f.hurt = 0.0
	f.health = 100
	f.roll = 0.5
	f.lasers.append({"x": f.pos.x, "warn": 0.0, "fire": 0.3, "src": Vector2(320, 50), "hit": false})
	f._process(1.0 / 60.0)
	check(f.health == 100, "rolling through a laser avoids the hit")

	# v0.59.0 · ClaudeHelper: längere Turmabwehr mit Verstärkung vor dem Scanner.
	check(f.DEFENCE_AT < f.REINFORCE_AT and f.REINFORCE_AT < f.SCAN_AT and f.SCAN_AT - f.DEFENCE_AT >= 18.0, "the tower defence lasts long enough for a second wave")
	f.lasers.clear()
	f.elapsed = f.REINFORCE_AT
	f._process(1.0 / 60.0)
	check(f.phase == "defence" and f.reinforced and f.sentries.size() == 3, "a third laser drone reinforces the tower defence")
	f._process(1.0 / 60.0)
	check(f.sentries.size() == 3, "reinforcements arrive only once")

	# --- Sequenzkalibrierung at the scanner.
	await process_frame   # clear the "just pressed" state of earlier inputs
	f.elapsed = f.SCAN_AT
	f.lasers.clear()
	f._process(1.0 / 60.0)
	check(f.phase == "scan" and f.calibration != null and f.lasers.is_empty(), "scanner range opens the calibration and silences the guns")
	step(f, 1.5)
	var cw: Vector2 = f.calibration.window()
	var window_y := lerpf(f.BEAM_RANGE.x, f.BEAM_RANGE.y, (cw.x + cw.y) * 0.5)
	check(absf(f.pos.y - window_y) < 8.0, "autopilot rides the hull into the scanner window")
	f.calibration.marker = 0.02
	f.calibration_input(0)
	f.calibration.marker = 0.02
	f.calibration_input(0)
	f.calibration.marker = 0.02
	f.calibration_input(0)
	check(f.phase == "alarm" and not f.transponder_sent, "three deviations sound the alarm instead of crashing")
	check(f.sentries.size() >= 2 and "calib_alarm" in world.sounds, "the alarm calls the guards back")
	world.god = true   # survive the alarm lasers; dodging is covered above
	step(f, f.alarm_left + 0.1, 20.0)
	world.god = false
	check(f.phase == "scan" and f.scan_attempts == 2, "after the alarm the scanner passes again")
	solve_calibration(f)
	check(f.transponder_sent and f.phase == "approach", "a calibrated ID is accepted")
	check(f.sentries.all(func(s): return s.leave), "accepted ID sends the guards away")

	# --- Drift and landing.
	step(f, f.approach_left - 2.0)
	check(f.drift_window > 0.0, "the approach signals the drift turn")
	Input.action_press("dash")
	f._process(1.0 / 60.0)
	Input.action_release("dash")
	check(f.drifted, "dash in the window flies the controlled drift")
	await process_frame
	step(f, 2.5)
	check(f.phase == "landing" and f.altitude > 0.8, "landing starts above the tower roof")
	# Fly the shadow into the ring and brake to a clean touchdown.
	var guard := 0
	while f.phase == "landing" and guard < 2000:
		guard += 1
		f.shadow = f.shadow.lerp(f.pad_screen(), 0.2)
		f.vel = Vector2.ZERO
		if f.descent > 0.2:
			Input.action_press("attack")
		else:
			Input.action_release("attack")
		f._process(1.0 / 60.0)
	Input.action_release("attack")
	check(f.touchdown == "präzise", "braked touchdown in the ring is clean")
	var spot: Vector2 = f.touchdown_world()
	check(spot.distance_to(f.PAD_WORLD) < 30.0, "touchdown point lies on the tower pad")
	var done := [0]
	f.completed.connect(func(): done[0] += 1)
	step(f, 2.0)
	check(done[0] == 1 and not f.active, "landing completes the flight exactly once")

	# --- Missing the pad makes Shadepi go around instead of crashing.
	var g = make(world)
	g.engine_repaired = true
	g._start_landing()
	g.shadow = Vector2(600, 320)
	g.altitude = 0.002
	g.descent = 0.3
	g._process(1.0 / 60.0)
	check(g.phase == "landing" and g.go_arounds == 1 and g.altitude > 0.3, "landing beside the pad is a go-around")
	g.shadow = g.pad_screen()
	g.altitude = 0.01
	g.descent = 0.8
	g._process(1.0 / 60.0)
	check(g.touchdown == "sehr hart" and g.health < 100 and g.health > 0, "a hard landing costs integrity but lands")

	# --- Repair deadline and integrity loss still end the run.
	var h = make(world)
	var crashes := [0]
	h.crashed.connect(func(): crashes[0] += 1)
	h.start_engine_failure()
	world.terminal.finish(false)
	h._process(h.REPAIR_SECONDS + 0.1)
	h._process(1.0)
	check(crashes[0] == 1 and not h.active, "missed repair deadline fails exactly once")
	var k = make(world)
	k.engine_repaired = true
	k.elapsed = 10.0
	var k_crash := [0]
	k.crashed.connect(func(): k_crash[0] += 1)
	k.health = 0
	k._process(0.02)
	check(k_crash[0] == 1, "losing all integrity aborts the flight")

	# --- Art, sounds and roof view mapping.
	check(Vector2i(Flight.PROPS.get_size()) == Vector2i(146, 34), "flight prop atlas layout")
	for key in ["drive_roll", "drive_near_miss", "drive_laser_warn", "drive_laser", "drive_brake", "drive_touchdown", "calib_tick", "calib_lock", "calib_error", "calib_alarm", "calib_accept"]:
		check(ResourceLoader.exists("res://assets/audio/%s.wav" % key), key + " sound exists")
	check(Flight.screen_to_roof(Flight.roof_to_screen(Vector2(300, 300))).distance_to(Vector2(300, 300)) < 0.01, "landing view maps to the roof camera")
	world.queue_free()
	await process_frame
	print("AERODYNE FLIGHT: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
