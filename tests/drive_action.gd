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
	for action in ["move_left", "move_right", "attack", "hack", "dash"]:
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
	for column in 9:
		for row in 3:
			var texture := Art.texture(column, row)
			check(Rect2(Vector2.ZERO, Art.ATLAS.get_size()).encloses(texture.region), "HQ atlas region in bounds")
	check(Art.SIZES[3] == Vector2(160, 74), "parked cars have believable proportions beside the heroes")
	check(Art.SIZES[4] == Vector2(104, 70), "dumpsters have believable proportions beside the heroes")
	check(Vector2i(Drive.VEHICLES.get_size()) == Vector2i(1254, 1254), "vehicle atlas keeps its 2x2 layout")
	print("Drive action: %d checks, %d failures" % [checks, failures])
	world.queue_free()
	await process_frame
	quit(1 if failures else 0)
