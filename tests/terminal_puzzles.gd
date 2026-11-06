extends SceneTree
const Puzzle = preload("res://scripts/terminal_puzzle.gd")
const Solver = preload("res://tests/terminal_solver.gd")
var checks := 0
var failures := 0

func _initialize() -> void:
	run.call_deferred()

func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("FAIL: " + label)

func run() -> void:
	for context in Puzzle.CATALOG:
		var puzzle = Puzzle.new(context)
		Solver.solve(puzzle)
		check(puzzle.solved and not puzzle.failed, context + " has a reachable solution")
	var matrix = Puzzle.new("transponder")
	matrix.select_hex(7)
	check(matrix.buffer.is_empty(), "matrix must start in top row")
	matrix.select_hex(1)
	matrix.select_hex(2)
	check(matrix.buffer.size() == 1 and matrix.legal(11), "column enforced after first selection")
	matrix.select_hex(11)
	matrix.select_hex(11)
	check(matrix.buffer.size() == 2 and matrix.legal(13) and not matrix.legal(21), "no reuse; selection now follows row")
	matrix.select_hex(13)
	check(not matrix.solved and matrix.has_sequence(matrix.goals[0]), "hard matrix requires both daemons")
	matrix.select_hex(23)
	matrix.select_hex(20)
	check(matrix.solved and matrix.buffer.size() == 5, "overlapping daemons share the 55 byte")
	matrix = Puzzle.new("jackal")
	for i in [0, 5, 6, 16]: matrix.select_hex(i)
	check(matrix.failed and not matrix.solved, "bad buffer fails without granting access")
	var decoder = Puzzle.new("garage")
	decoder.guess(0)
	check(not decoder.solved and decoder.attempts == 4, "glitch filter must lock before guessing")
	decoder.filter = decoder.filter_target
	decoder.guess(1)
	check(decoder.attempts == 3 and decoder.history.contains("3 / 6"), "likeness counts exact positions")
	decoder.guess(1)
	check(decoder.attempts == 3, "repeated guess cannot consume another attempt")
	decoder.helper("reset")
	decoder.guess(2)
	decoder.helper("reset")
	check(decoder.attempts == 3, "reset helper is single-use")
	decoder.helper("dud")
	decoder.helper("dud")
	check(decoder.removed.size() == 1 and decoder.WORDS.find(decoder.secret) not in decoder.removed, "brackets never remove password")
	decoder = Puzzle.new("garage")
	decoder.filter = decoder.filter_target
	for i in [1, 2, 3, 4]: decoder.guess(i)
	check(decoder.failed and not decoder.solved, "decoder locks after exhausted attempts")
	for type in ["AND", "OR", "XOR", "NOT"]:
		for a in [false, true]:
			for b in [false, true]:
				var truth := {"AND": a and b, "OR": a or b, "XOR": a != b, "NOT": not a}
				check(Puzzle.gate_output(type, a, b) == truth[type], type + " truth table")
	var route = Puzzle.new("power")
	Solver.solve(route)
	check(route.infected == [0], "isolated ICE cannot cross disconnected segments")
	route = Puzzle.new("power")
	route.masks[0] = 2
	route.masks[1] = 8
	route.powered = true
	route.tick(1.5)
	check(1 in route.infected and not route.failed, "ICE spreads along reciprocal connections")
	route.masks[0] = 4
	route.masks[4] = 9
	route.tick(0.1)
	check(route.failed, "connecting an infected network to IN triggers defense")
	route = Puzzle.new("power")
	route.rate = 2
	Solver.solve(route)
	check(route.failed and route.status.contains("Überlast"), "excess data rate burns constrained segment")
	route = Puzzle.new("power")
	route.masks[3] = 2
	route.masks[4] = 8
	check(4 not in route.neighbors(3), "routing never wraps across grid edges")
	var signal_puzzle = Puzzle.new("charge")
	signal_puzzle.signal_values = signal_puzzle.signal_target.duplicate()
	signal_puzzle.tick(0.6)
	check(not signal_puzzle.solved and signal_puzzle.stability > 0.5, "phase lock requires sustained match")
	signal_puzzle.signal_values[0] = 1
	signal_puzzle.tick(0.1)
	check(signal_puzzle.stability == 0, "losing alignment resets lock")
	signal_puzzle.tick(11.4)
	check(signal_puzzle.signal_target[2] == 4, "secured channel changes phase over time")
	var jumper = Puzzle.new("repair")
	jumper.check_wiring()
	check(jumper.attempts == 2 and jumper.flash > 0 and not jumper.solved, "incorrect wiring sparks and alarms")
	jumper.wiring = [4, 3, 2, 1, 5]
	jumper.check_wiring()
	check(not jumper.solved and jumper.leds.all(func(v): return v), "pins alone cannot bypass resistor constraint")
	jumper.resistors = [2, 2]
	jumper.check_wiring()
	check(jumper.solved, "alternative 60 + 60 resistor solution works")
	await integration()
	print("Terminal puzzles: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)

func integration() -> void:
	var world = load("res://scenes/campaign.tscn").instantiate()
	root.add_child(world)
	await process_frame
	world._enter(world.Beat.HANGAR)
	world.ui.clear_dialogue()
	world.raven.position = world._target()
	world.interact()
	check(world.terminal != null and world.is_busy(), "interacting opens modal terminal and blocks world")
	var panel = world.terminal
	panel.set_process(false)
	panel.finish(true)
	check(world.point_index == 0 and world.terminal == panel, "unsolved terminal cannot commit")
	panel.paused = true
	panel._process(2.0)
	check(panel.puzzle.clock == 0.0, "pause freezes terminal clocks")
	panel.finish(false)
	check(world.terminal == null and world.point_index == 0 and not world.is_busy(), "cancel changes no story progress")
	world.interact()
	check(Solver.complete(world) and world.point_index == 1, "solved terminal commits exactly one point")
	world.load_game()
	world.ui.clear_dialogue()
	check(world.point_index == 1, "completed terminal survives checkpoint reload")
	world._enter(world.Beat.ROOF)
	world.ui.clear_dialogue()
	world.raven.position = world._target()
	world.interact()
	panel = world.terminal
	Solver.solve(panel.puzzle)
	panel.paused = true
	panel.finish(true)
	check(world.point_index == 0, "paused terminal cannot commit")
	panel.paused = false
	panel._process(0.0)
	check(root.gui_get_focus_owner() == panel.apply_button, "solved signal moves keyboard focus to acceptance")
	panel.finish(true)
	panel.finish(true)
	check(world.point_index == 1, "duplicate accept never skips a point")
	world.raven.position = world._target()
	world.interact()
	panel = world.terminal
	world._enter(world.Beat.ESCAPE, 0, 1)
	world.ui.clear_dialogue()
	panel.finished.emit(true)
	check(world.point_index == 1 and world.beat == world.Beat.ESCAPE, "stale terminal callback cannot affect another scene")
	world.player.position = world._target()
	world.interact()
	var remaining: float = world.countdown
	world._process(5.0)
	check(world.countdown == remaining, "escape countdown freezes while Raven solves terminal")
	check(Solver.complete(world) and world.point_index == 2, "charge arms only after signal synchronization")
	for id in Puzzle.CATALOG:
		world.open_terminal(id, func(): pass)
		check(world.terminal != null, id + " UI constructs")
		world.terminal._process(0.1)
		world.cancel_terminal()
	world.queue_free()
	await process_frame
