extends SceneTree

var checks := 0
var failures := 0

func _initialize() -> void:
	run.call_deferred()

func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error("FAIL: " + message)

func run() -> void:
	check(CombatRules.can_strike(Vector2.ZERO, Vector2.RIGHT, Vector2(40, 0)), "frontal target can be hit")
	check(not CombatRules.can_strike(Vector2.ZERO, Vector2.RIGHT, Vector2(-40, 0)), "target behind player is safe")
	check(not CombatRules.can_strike(Vector2.ZERO, Vector2.RIGHT, Vector2(70, 0)), "target outside blade reach is safe")
	check(CombatRules.damage(25, true) > CombatRules.damage(25, false), "Raven creates a meaningful damage window")
	check(WorldData.walkable(WorldData.START, false), "spawn is walkable")
	check(not WorldData.walkable(Vector2(150, 200), true), "building is solid")
	check(not WorldData.walkable(Vector2(509, 380), false), "closed gate blocks its corridor")
	check(WorldData.walkable(Vector2(509, 380), true), "open gate unblocks its corridor")
	# Flood-fill both sides with the same clearance as the player: verify no gate bypass.
	check(not reachable(WorldData.START, WorldData.JACKAL, false), "boss cannot be reached around the closed gate")
	check(reachable(WorldData.START, WorldData.RAVEN, false), "Raven can be reached from spawn")
	check(reachable(WorldData.START, WorldData.TERMINAL + Vector2(-26, 25), false), "terminal can be approached")
	check(reachable(WorldData.START, WorldData.EXIT, true), "open map connects to exit")
	var scene = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	scene.close_menu()
	var start: Vector2 = scene.player.position
	Input.action_press("move_right")
	for i in 15:
		await physics_frame
	Input.action_release("move_right")
	await physics_frame
	check(scene.player.position.x > start.x + 15, "keyboard input moves the actual player")
	scene.player.position = Vector2(120, 283)
	Input.action_press("move_up")
	for i in 20:
		await physics_frame
	Input.action_release("move_up")
	await physics_frame
	check(scene.player.position.y >= 278.0, "physics keeps player outside the north wall")
	scene.player.position = WorldData.RAVEN + Vector2(0, 40)
	scene.interact()
	check(scene.ui.dialogue_open, "Raven interaction opens the dialogue")
	for i in 3:
		scene.ui.advance_dialogue()
	check(scene.stage == 1, "finishing Raven dialogue advances objective")
	scene.player.position = WorldData.TERMINAL + Vector2(-26, 25)
	scene.interact()
	await physics_frame
	check(scene.stage == 2 and scene.gate_open, "terminal unlocks gate and combat")
	scene.player.position = Vector2(720, 350)
	scene.player.facing = (scene.enemy.position - scene.player.position).normalized()
	check(scene.raven_hack(), "Raven hack succeeds at valid range")
	check(scene.enemy.exposed > 0.0 and scene.enemy.stun > 0.0, "hack interrupts and exposes boss")
	check(not scene.raven_hack(), "hack cannot bypass cooldown")
	scene.player.energy = 0
	check(not scene.player.try_dash(Vector2.RIGHT), "dash cannot spend missing energy")
	check(not scene.player.try_cloak(), "cloak cannot activate with missing energy")
	scene.player.energy = 100
	check(scene.player.try_cloak(), "cloak activates with energy")
	check(scene.player.cloak_time == 10, "cloak has the promised ten second window")
	check(scene.player.try_attack(), "player can attack")
	check(scene.player.cloak_time == 0, "attack cancels stealth")
	check(not scene.player.try_attack(), "attack cooldown prevents repeated hits")
	scene.player.attack_time = 0
	scene.player.attack_cooldown = 0
	scene.player.position = scene.enemy.position + Vector2(-34, 0)
	scene.player.facing = Vector2.RIGHT
	var before: int = scene.enemy.health
	scene.player_strike(25)
	check(scene.enemy.health < before, "front-facing strike damages boss")
	before = scene.enemy.health
	scene.player.facing = Vector2.LEFT
	scene.player_strike(25)
	check(scene.enemy.health == before, "turning away prevents damage")
	scene.enemy.take_damage(1000)
	check(scene.stage == 3 and scene.enemy.health == 0, "boss defeat advances exactly to data objective")
	scene.player.position = WorldData.EXIT
	scene.interact()
	for i in 3:
		scene.ui.advance_dialogue()
	check(scene.stage == 4, "exit completes scene")
	var snapshot: Dictionary = scene.snapshot()
	var file := "user://test-validation-slot.json"
	check(SaveService.write(snapshot, file), "valid state can be saved")
	check(SaveService.read(file).stage == 4, "save round-trip preserves progress")
	var invalid := snapshot.duplicate()
	invalid.x = 10
	invalid.y = 10
	check(SaveService.validate(invalid).is_empty(), "save cannot place player inside geometry")
	invalid = snapshot.duplicate()
	invalid.stage = 2.5
	check(SaveService.validate(invalid).is_empty(), "fractional quest stage is rejected")
	invalid = snapshot.duplicate()
	invalid.health = INF
	check(SaveService.validate(invalid).is_empty(), "non-finite values are rejected")
	invalid = snapshot.duplicate()
	invalid.enemy_health = 180
	check(SaveService.validate(invalid).is_empty(), "inconsistent quest and boss states are rejected")
	check(SaveService.write(snapshot, file), "second save creates recovery backup")
	var broken := FileAccess.open(file, FileAccess.WRITE)
	broken.store_string("{broken"); broken.close()
	check(SaveService.read(file).stage == 4, "corrupted slot recovers from validated backup")
	for suffix in ["", ".bak", ".tmp"]:
		if FileAccess.file_exists(file + suffix):
			DirAccess.remove_absolute(file + suffix)
	scene.new_game()
	check(scene.stage == 0 and scene.enemy.health == 180 and not scene.gate_open, "restart resets combat, quest and gate")
	scene.queue_free()
	await process_frame
	print("SHADEPI TESTS: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)

func reachable(from: Vector2, to: Vector2, gate: bool) -> bool:
	var start := Vector2i(from / 8)
	var goal := Vector2i(to / 8)
	var queue: Array[Vector2i] = [start]
	var visited := {start: true}
	var index := 0
	while index < queue.size():
		var cell := queue[index]
		index += 1
		if cell.distance_to(goal) < 3:
			return true
		for offset in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
			var next: Vector2i = cell + offset
			if not visited.has(next) and WorldData.walkable(Vector2(next) * 8 + Vector2(4, 4), gate):
				visited[next] = true
				queue.append(next)
	return false
