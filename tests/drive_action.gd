extends SceneTree
const Drive = preload("res://scripts/campaign_drive.gd")
const Art = preload("res://scripts/prop_art.gd")
var checks := 0
var failures := 0
class World extends Node2D:
	var busy := false
	var visual_quality := 2
	var terminal: CanvasLayer
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
	func admin_enabled(_key: String) -> bool: return false
	func sound(_key: String) -> void: pass
	func toast(_text: String) -> void: pass

func _initialize() -> void:
	run.call_deferred()

func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("FAIL: " + label)

func make_drive(world: World, flight: bool = true) -> Node2D:
	var drive = Drive.new()
	drive.world = world
	drive.flight = flight
	world.add_child(drive)
	drive.set_process(false)
	return drive

func run() -> void:
	for action in ["move_left", "move_right", "move_up", "move_down", "attack", "hack", "dash"]:
		InputMap.add_action(action)
	var world := World.new()
	root.add_child(world)
	var drive = make_drive(world)
	await process_frame
	drive.elapsed = 3.19
	drive._process(0.02)
	check(drive.engine_failed, "flight triggers engine failure")
	var progress: float = drive.elapsed
	check(world.busy and world.terminal != null, "engine failure opens Raven's wiring terminal")
	drive._process(2.0)
	check(drive.repair_left == drive.REPAIR_SECONDS, "terminal freezes emergency deadline")
	world.terminal.finish(false)
	check(not drive.engine_repaired, "cancel cannot repair engine")
	Input.action_press("attack")
	drive._process(0.01)
	check(world.terminal != null, "attack reopens repair terminal")
	await process_frame
	drive._process(0.1)
	check(not drive.engine_repaired, "holding the button cannot auto-complete repair")
	Input.action_release("attack")
	check(drive.elapsed == progress, "emergency preserves scanner window")
	world.terminal.puzzle.check_wiring()
	world.terminal.finish(true)
	check(not drive.engine_repaired and world.busy, "wrong wiring cannot restart engine")
	check(preload("res://tests/terminal_solver.gd").complete(world), "correct wiring accepted")
	check(drive.engine_repaired and not drive.engine_failed, "verified jumpers restart engine")
	check(drive.restart_flash > 0 and not drive.debris.is_empty(), "restart emits effects")
	drive.start_engine_failure()
	check(not drive.engine_failed, "failure only occurs once per flight")
	drive.elapsed = 9.1
	Input.action_press("hack")
	drive._process(0.01)
	Input.action_release("hack")
	check(drive.transponder_sent, "transponder works after repair")
	var completed := [0]
	drive.completed.connect(func(): completed[0] += 1)
	drive.elapsed = 14.99
	drive._process(0.02)
	drive._process(1.0)
	check(completed[0] == 1, "successful flight completes exactly once")
	var failed = make_drive(world)
	var crashes := [0]
	failed.crashed.connect(func(): crashes[0] += 1)
	failed.start_engine_failure()
	world.terminal.finish(false)
	failed._process(failed.REPAIR_SECONDS + 0.1)
	failed._process(1.0)
	check(crashes[0] == 1 and not failed.active, "missed repair deadline fails exactly once")
	var slow = make_drive(world, false)
	var fast = make_drive(world, false)
	slow.lane = 2
	fast.lane = 2
	for i in 30: slow._steer(1.0 / 30.0)
	for i in 144: fast._steer(1.0 / 144.0)
	check(absf(slow.x - fast.x) < 1.0, "steering consistent at 30 and 144 fps")
	var chase = make_drive(world, false)
	chase.grenade = Vector2(chase.boss_x, 270)
	chase._process(0.2)
	check(chase.armour == 67 and not chase.explosions.is_empty(), "grenade damage and explosion share impact")
	chase.hazards.clear()
	chase.hazards.append(Vector2(chase.x, 210))
	chase._process(0.1)
	check(chase.health == 76 and chase.hazards.is_empty(), "swept obstacle collision damages once and removes debris hazard")
	chase.armour = 0
	chase._process(0.01)
	check(chase.victory_left > 0 and chase.active, "final explosion remains visible before transition")
	for i in 100: chase.impact(Vector2.ZERO, true)
	check(chase.debris.size() <= 150 and chase.clouds.size() <= 45 and chase.explosions.size() <= 8, "effects have strict allocation caps")
	# v0.56.0 · ClaudeHelper: Der Verfolger zerlegt Hindernisse, statt durch sie hindurchzugleiten.
	var smash = make_drive(world, false)
	smash.hazards.clear(); smash.objects.clear(); smash.debris.clear()
	smash.boss_x = 320.0; smash.x = 230.0
	smash.hazards.append(Vector2(320.0, smash.car_y - 40.0))
	smash._advance_bike_world(0.05)
	var concrete := 0
	for bit in smash.debris:
		if int(bit.k) >= 0 and int(bit.k) <= 5: concrete += 1
	check(smash.hazards.is_empty() and smash.smashed == 1 and concrete >= 8, "the pursuer bursts a barrier into concrete chunks")
	var plating: int = smash.armour
	smash.objects.append({"k": "wreck", "p": Vector2(320.0, smash.car_y - 34.0), "done": false, "r": 0.0})
	smash._advance_bike_world(0.02)
	check(smash.objects.is_empty() and smash.smashed == 2 and smash.armour == plating - 6 and not smash.explosions.is_empty(), "ramming a wreck explodes it and dents the pursuer")
	smash.hazards.append(Vector2(232.0, smash.car_y - 40.0))
	smash._advance_bike_world(0.05)
	check(smash.hazards.size() == 1 and smash.smashed == 2, "barriers in another lane stay intact")
	# v0.58.0 · ClaudeHelper: Etappen – Tunnel ohne Drohnen, Hochstraße mit Seitenwind.
	var staged = make_drive(world, false)
	check(staged.stages == 1, "a plain drive keeps the single-stage rules")
	staged.stages = 3
	staged.hazards.clear(); staged.objects.clear(); staged.drones.clear()
	staged.armour = 0
	staged._process(0.01)
	check(staged.stage_shift >= 0.0 and staged.car_dead < 0.0 and staged.active, "an early pursuer falls back instead of ending the chase")
	var integrity: float = staged.health
	staged.health = 50.0
	for i in 20: staged._process(0.1)
	check(staged.stage == 1 and staged.health == 75.0 and staged.car_y > 380.0, "the stage change repairs the bike and brings the next car in from behind")
	for i in 20: staged._process(0.1)
	check(staged.stage_shift < 0.0 and staged.car_y < 340.0 and staged.armour == 80, "the tunnel pursuer closes in with its own plating")
	staged.next_drone = 0.0
	for i in 30: staged._process(0.1)
	check(staged.drones.is_empty(), "no cargo drones fly inside the tunnel")
	staged.armour = 0
	staged._process(0.01)
	for i in 40: staged._process(0.1)
	check(staged.stage == 2 and Drive.STAGE_NAMES[2] == "HOCHSTRASSE", "the third stage is the skyway")
	staged.hazards.clear(); staged.objects.clear()
	staged.next_wind = 0.0; staged.x = 320.0; staged.velocity_x = 0.0
	staged._process(0.05)
	var gust_x: float = staged.x
	for i in 6: staged._process(0.1)
	check(staged.wind > 0.0 and absf(staged.x - gust_x) > 8.0, "crosswind pushes the bike sideways on the skyway")
	staged.armour = 0
	staged._process(0.01)
	check(staged.car_dead >= 0.0 and staged.victory_left > 0.0, "only the last pursuer is destroyed")
	check(is_instance_valid(smash.fx_layer) and smash.fx_layer.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST, "pixel effects are sampled without smoothing")
	for column in 9:
		for row in 3:
			var texture := Art.texture(column, row)
			check(Rect2(Vector2.ZERO, Art.ATLAS.get_size()).encloses(texture.region), "HQ atlas region in bounds")
	check(Art.SIZES[3] == Vector2(160, 74), "parked cars have believable proportions beside the heroes")
	check(Art.SIZES[4] == Vector2(104, 70), "dumpsters have believable proportions beside the heroes")
	check(Vector2i(Drive.VEHICLES.get_size()) == Vector2i(1254, 1254), "vehicle atlas keeps its 2x2 layout")
	await check_bike_chase(world)
	print("Drive action: %d checks, %d failures" % [checks, failures])
	world.queue_free()
	await process_frame
	quit(1 if failures else 0)

func check_bike_chase(world: World) -> void:
	# v0.20.0: throttle, drones, turbo strips, oil, mines and wrecks.
	var bike = make_drive(world, false)
	Input.action_press("move_up")
	for i in 60: bike._process(1.0 / 60.0)
	Input.action_release("move_up")
	check(bike.bike_y < bike.BIKE_Y - 40.0 and bike.speed > 1.1, "accelerating moves the bike forward and speeds up the road")
	var far_scroll: float = bike.scroll
	check(far_scroll > 226.0, "road scroll follows the bike's speed")
	Input.action_press("move_right")
	for i in 30: bike._process(1.0 / 60.0)
	Input.action_release("move_right")
	check(bike.x > 360.0, "free steering moves across the whole road instead of fixed lanes")
	bike.objects.clear(); bike.hazards.clear(); bike.drones.clear()
	bike.next_hazard = 999.0
	bike.next_drone = 999.0
	bike.health = 80
	bike.objects.append({"k": "boost", "p": Vector2(bike.x, bike.bike_y - 4), "done": false, "r": 0.0})
	bike._process(0.01)
	check(bike.boost > 0.0 and bike.health == 86, "turbo strip boosts and repairs a little")
	bike.boost = 0.0
	bike.hurt = 0.0
	bike.objects.append({"k": "slick", "p": Vector2(bike.x, bike.bike_y), "done": false, "r": 0.0})
	bike._process(0.01)
	check(bike.slick > 0.0 and bike.health == 86, "oil makes the bike slide without damage")
	bike.objects.append({"k": "wreck", "p": Vector2(bike.x, bike.bike_y), "done": false, "r": 0.0})
	bike._process(0.01)
	bike.hurt = 0.0
	bike._process(0.01)
	check(bike.health == 58, "a burning wreck damages exactly once")
	bike.hurt = 0.0
	bike.objects.append({"k": "mine", "p": Vector2(bike.x, bike.bike_y), "done": false, "r": 0.0})
	bike._process(0.01)
	check(bike.health == 38, "drone mines explode on contact")
	bike.health = 100
	bike.objects.clear()
	bike.drones.append({"p": Vector2(bike.x, 92.0), "state": "hover", "t": 0.0, "drops": 0, "spin": 0.0})
	for i in 90: bike._process(1.0 / 60.0)
	check(bike.objects.any(func(o): return o.k == "mine"), "hovering drones drop mines onto the road")
	var armour_before: int = bike.armour
	bike.hack_cooldown = 0.0
	Input.action_press("hack")
	bike._process(0.01)
	Input.action_release("hack")
	check(bike.drones[0].state == "hacked", "Raven's hack captures the drone above the bike")
	for i in 120: bike._process(1.0 / 60.0)
	check(bike.drones.is_empty() and bike.armour <= armour_before - 18, "the captured drone crashes into the pursuing car")
	bike.free()
	await process_frame
