extends RefCounted
## Deterministic input fixtures for story tests; uses the same rules as the UI.
static func solve(puzzle: RefCounted) -> void:
	match puzzle.kind:
		"matrix":
			for index in ([1, 11, 13, 23, 20] if puzzle.hard else [1, 11, 13]):
				puzzle.select_hex(index)
		"decoder":
			puzzle.filter = puzzle.filter_target
			puzzle.guess(puzzle.WORDS.find(puzzle.secret))
		"routing":
			for entry in [[4, 10], [5, 12], [9, 3], [10, 10], [11, 9], [7, 6]]:
				for turn in 4:
					if puzzle.masks[entry[0]] == entry[1]: break
					puzzle.rotate(entry[0])
			puzzle.input_a = true
			puzzle.input_b = true
			puzzle.powered = true
			puzzle.tick(3.1)
		"signal":
			# Wait through interference before locking.
			puzzle.tick(6.0 - fposmod(puzzle.clock, 6.0))
			puzzle.signal_values = puzzle.signal_target.duplicate()
			puzzle.tick(1.3)
		"jumper":
			puzzle.wiring = [4, 3, 2, 1, 5]
			puzzle.resistors = [1, 3]
			puzzle.check_wiring()

static func complete(world: Node) -> bool:
	if world.terminal == null:
		return false
	var panel = world.terminal
	solve(panel.puzzle)
	if not panel.puzzle.solved:
		push_error("Terminal fixture could not solve " + panel.context)
		return false
	panel.finish(true)
	return true
