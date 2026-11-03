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
	check(SpriteAssets.valid_sheet(scene.player.visual.texture), "selected player sprite fits a supported grid")
	var invalid_sprite := ImageTexture.create_from_image(Image.create_empty(48, 64, false, Image.FORMAT_RGBA8))
	check(not SpriteAssets.valid_sheet(invalid_sprite), "single-frame replacement is rejected")
	if "--expect-custom-sprite" in OS.get_cmdline_user_args():
		check(scene.player.visual.texture.resource_path == "res://assets/custom/shadepi.png", "imported custom sheet takes precedence")
	scene.set_visual_quality(0)
	check(not scene.atmosphere_filter.visible and not scene.shadow_lights[0].shadow_enabled, "reduced mode removes screen processing and dynamic shadows")
	scene.set_visual_quality(2)
	check(scene.atmosphere_filter.visible and scene.shadow_lights[0].shadow_enabled, "atmospheric mode restores lighting and post filter")
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
	await physics_frame
	await physics_frame
	check(not scene.player.light_occluder.visible and not scene.blade_light.enabled, "cloaked player does not give away position with light and cast shadow")
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
	await check_coop(scene)
	await check_gamepads(scene)
	check_directional_animation(scene)
	scene.queue_free()
	await process_frame
	await check_chapter()
	await check_chapter_two()
	await check_campaign()
	print("SHADEPI TESTS: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)

func check_coop(scene: Node2D) -> void:
	# Use the menu entry point, then send real keyboard events.
	scene.menu_open = true
	scene.ui.show_menu()
	scene.ui.mode_button.pressed.emit()
	scene.ui.resume_button.pressed.emit()
	check(scene.coop and not scene.menu_open, "menu starts local co-op")
	check(scene.save_path() == SaveService.COOP_PATH, "co-op selects its own save slot")
	var shadepi_start: Vector2 = scene.player.position
	var raven_start: Vector2 = scene.raven.position
	key(KEY_D, true)
	key(KEY_LEFT, true)
	for i in 15:
		await physics_frame
	key(KEY_D, false)
	key(KEY_LEFT, false)
	await physics_frame
	check(scene.player.position.x > shadepi_start.x + 15, "WASD controls Shadepi during simultaneous input")
	check(scene.raven.position.x < raven_start.x - 15, "arrows independently control Raven")
	check(absf(scene.player.position.y - shadepi_start.y) < 0.1, "Raven input does not steer Shadepi")
	var offset: Vector2 = scene.camera.position - scene.player.position.lerp(scene.raven.position, 0.5)
	check(offset.distance_to(Vector2(0, -27)) < 3.0, "shared camera tracks both players")
	scene.player.position = scene.raven.position + Vector2(-448, 0)
	check(scene.limit_coop_motion(scene.player, Vector2(-100, 0), 0.016).x == 0.0, "camera boundary prevents walking farther away")
	check(scene.limit_coop_motion(scene.player, Vector2(100, 0), 0.016).x > 0.0, "camera boundary allows regrouping")
	scene.player.position = WorldData.RAVEN + Vector2(0, 28)
	scene.raven.position = WorldData.RAVEN
	scene.interact(scene.raven)
	for i in 3:
		scene.ui.advance_dialogue()
	check(scene.stage == 1, "Raven can start the team dialogue")
	scene.raven.position = WorldData.TERMINAL + Vector2(-26, 25)
	scene.interact(scene.raven)
	await physics_frame
	check(scene.stage == 2 and scene.gate_open, "Raven can operate the mission terminal")
	scene.player.position = Vector2(350, 380)
	scene.raven.position = Vector2(710, 323)
	scene.raven.facing = Vector2.RIGHT
	check(scene.combat_target(scene.enemy.position) == scene.raven, "Jackal can target Raven")
	key(KEY_O, true)
	await physics_frame
	key(KEY_O, false)
	check(scene.enemy.exposed > 0.0, "Raven's hack uses her own range and key")
	var enemy_health: int = scene.enemy.health
	key(KEY_U, true)
	for i in 4:
		await physics_frame
	key(KEY_U, false)
	check(scene.enemy.health < enemy_health, "Raven's pulse shot damages Jackal")
	scene.raven.health = 63
	var saved_raven: Vector2 = scene.raven.position
	check(scene.save_game(), "co-op checkpoint saves both players")
	scene.raven.position = WorldData.RAVEN
	scene.raven.health = 100
	check(scene.load_game() and scene.raven.position == saved_raven and scene.raven.health == 63, "co-op load restores Raven's position and health")
	scene.raven.take_damage(100, scene.enemy.position)
	check(scene.menu_open and scene.raven.health == 100 and scene.player.health == 100, "Raven defeat resets the team checkpoint")
	scene.close_menu()
	scene.enemy.take_damage(1000)
	scene.raven.position = WorldData.EXIT
	scene.interact(scene.raven)
	for i in 3:
		scene.ui.advance_dialogue()
	check(scene.stage == 4, "Raven can complete the shared mission")
	scene.set_coop(false)
	check(InputMap.action_has_event("move_left", arrow_left()), "solo arrow shortcuts are restored")

func check_gamepads(scene: Node2D) -> void:
	var both: Array[int] = [0, 1]
	var one: Array[int] = [0]
	var none: Array[int] = []
	scene.set_coop(true)
	scene.new_game(false)
	scene.gamepads.assign(both, true)
	var shadepi_start: Vector2 = scene.player.position
	var raven_start: Vector2 = scene.raven.position
	stick(0, 1.0)
	stick(1, -1.0)
	for i in 15:
		await physics_frame
	stick(0, 0.0)
	stick(1, 0.0)
	await physics_frame
	check(scene.player.position.x > shadepi_start.x + 15.0 and scene.raven.position.x < raven_start.x - 15.0, "two analog sticks control distinct actors")
	pad_button(1, JOY_BUTTON_START)
	await process_frame
	check(scene.menu_open, "Raven controller opens pause menu")
	var mode_before: bool = scene.ui.requested_coop
	scene.ui.mode_button.grab_focus()
	stick(0, 1.0, JOY_AXIS_LEFT_Y)
	await process_frame
	check(root.gui_get_focus_owner() == scene.ui.resume_button, "left stick moves menu focus")
	stick(0, 0.0, JOY_AXIS_LEFT_Y)
	scene.ui.mode_button.grab_focus()
	pad_button(0, JOY_BUTTON_A)
	await process_frame
	check(scene.ui.requested_coop != mode_before, "controller A activates the focused menu button")
	scene.close_menu()
	scene.player.position = WorldData.RAVEN + Vector2(0, 28)
	scene.raven.position = WorldData.RAVEN
	pad_button(1, JOY_BUTTON_A)
	await process_frame
	check(scene.ui.dialogue_open, "Raven controller starts dialogue")
	for i in 3:
		pad_button(1, JOY_BUTTON_A)
		await process_frame
	check(scene.stage == 1, "Raven controller advances and closes dialogue")
	scene.raven.position = WorldData.TERMINAL + Vector2(-26, 25)
	pad_button(1, JOY_BUTTON_A)
	await physics_frame
	check(scene.stage == 2, "Raven controller operates the terminal")
	scene.raven.position = Vector2(710, 323)
	scene.raven.facing = Vector2.RIGHT
	pad_button(1, JOY_BUTTON_Y)
	await process_frame
	check(scene.enemy.exposed > 0.0 and scene.player.cloak_time == 0.0, "Raven Y hacks without triggering Shadepi's cloak")
	var hp: int = scene.enemy.health
	pad_button(1, JOY_BUTTON_X)
	for i in 3:
		await physics_frame
	check(scene.enemy.health < hp and scene.player.attack_time == 0.0, "Raven X fires without swinging Shadepi's katana")
	pad_button(0, JOY_BUTTON_Y)
	await physics_frame
	await physics_frame
	check(scene.player.cloak_time > 0.0, "Shadepi Y activates cloak")
	scene.gamepads.assign(one, true)
	check(scene.gamepads.shadepi_device == -1 and scene.gamepads.raven_device == 0, "one co-op controller is assigned to Raven")
	var shadepi_position: Vector2 = scene.player.position
	stick(0, -1.0)
	for i in 8:
		await physics_frame
	stick(0, 0.0)
	check(scene.player.position.distance_to(shadepi_position) < 0.1, "reassignment removes old Shadepi bindings")
	scene.set_coop(false)
	scene.new_game(false)
	scene.gamepads.assign(one, false)
	pad_button(0, JOY_BUTTON_Y)
	await physics_frame
	await physics_frame
	check(scene.player.cloak_time > 0.0, "the first controller controls Shadepi in solo")
	scene.stage = 2
	scene.set_gate(true)
	scene.player.position = Vector2(710, 323)
	await physics_frame
	pad_button(0, JOY_BUTTON_RIGHT_SHOULDER)
	await process_frame
	check(scene.enemy.exposed > 0.0, "solo controller can call Raven's hack")
	stick(0, -1.0)
	await physics_frame
	check(Input.is_action_pressed("move_left"), "analog input is held before disconnect")
	scene.gamepads.assign(none, false)
	check(not Input.is_action_pressed("move_left"), "disconnect clears held controller input")

func stick(device: int, value: float, axis: JoyAxis = JOY_AXIS_LEFT_X) -> void:
	var event := InputEventJoypadMotion.new()
	event.device = device
	event.axis = axis
	event.axis_value = value
	Input.parse_input_event(event)
	Input.flush_buffered_events()

func pad_button(device: int, button: JoyButton) -> void:
	var event := InputEventJoypadButton.new()
	event.device = device
	event.button_index = button
	event.pressed = true
	Input.parse_input_event(event)
	var release := event.duplicate() as InputEventJoypadButton
	release.pressed = false
	Input.parse_input_event(release)
	Input.flush_buffered_events()

func check_directional_animation(scene: Node2D) -> void:
	for actor in [scene.player, scene.raven]:
		if actor.directions == 4:
			# Existing custom four-direction sheets still use their own layout.
			continue
		actor.facing = Vector2.UP
		actor.animate("idle", 0.0)
		actor.animate("walk", 0.02)
		check(actor.visual.frame_coords.y == 11, "north uses the rear walk cycle")
		actor.facing = Vector2.RIGHT
		actor.animate("walk", 0.02)
		check(actor.visual.frame_coords.y == 13, "north to east turns through the northeast pose")
		actor.animate("walk", 0.07)
		check(actor.visual.frame_coords.y == 10, "east uses the side walk cycle")
		actor.facing = Vector2.UP
		actor.animate("idle", 0.0)
		actor.animate("walk", 0.02)
		actor.facing = Vector2.LEFT
		actor.animate("walk", 0.02)
		check(actor.visual.frame_coords.y == 12, "north to west turns through the northwest pose")
		actor.animate("walk", 0.07)
		check(actor.visual.frame_coords.y == 9 and actor.cast_shadow.frame == actor.visual.frame, "west uses its own walk cycle and matching shadow")

func key(code: Key, pressed: bool) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = code
	event.pressed = pressed
	Input.parse_input_event(event)

func arrow_left() -> InputEventKey:
	var event := InputEventKey.new()
	event.physical_keycode = KEY_LEFT
	return event

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

func check_chapter() -> void:
	var chapter = load("res://scenes/chapter_one.tscn").instantiate()
	root.add_child(chapter)
	await process_frame
	chapter.ui.mode_button.pressed.emit()
	chapter.ui.resume_button.pressed.emit()
	check(chapter.chapter_coop and not chapter.coop, "chapter defers co-op until the team fight")
	check(chapter.ui.dialogue_open and chapter.ui.comic_art.texture != null, "chapter opens with comic artwork")
	chapter.ui.advance_dialogue()
	check(chapter.ui.comic_art.texture.resource_path.ends_with("apartment.jpg"), "Raven gets the lead in her apartment")
	finish_dialogue(chapter)
	check(chapter.phase == chapter.Phase.HUNT and chapter.actor_is_playable(chapter.raven) and not chapter.actor_is_playable(chapter.player), "the hunt gives primary controls to Raven")
	check(chapter.saved_checkpoint(true) == chapter.Phase.HUNT, "the hunt is saved in the co-op slot")
	check(chapter.patrol.size() == 4 and not chapter.gate_open, "four street punks guard Raven's route")
	var sprites := {}
	for guard in chapter.patrol:
		sprites[guard.visual.texture.resource_path] = true
	check(sprites.size() == 4, "hunt punks use four distinct sprites")
	var first_guard = chapter.patrol[0]
	chapter.raven.facing = (first_guard.position - chapter.raven.position).normalized()
	await physics_frame
	var hp: int = first_guard.health
	var direct_aim: Vector2 = chapter.raven.facing
	chapter.raven.facing = direct_aim.rotated(0.3)
	chapter.raven_shot()
	check(first_guard.health == hp, "off-axis shots miss even inside the old aim cone")
	chapter.raven.facing = direct_aim
	chapter.raven_shot()
	check(first_guard.health < hp, "Raven can shoot a street punk with her pistol")
	for guard in chapter.patrol:
		guard.take_damage(100)
	check(not chapter.gate_open, "clearing the gang still requires following the trail")
	var route := [
		Vector2(-543, 448), Vector2(-297, 448), Vector2(-297, 346), Vector2(-158, 346),
		Vector2(-158, 451), Vector2(-60, 451), Vector2(308, 452), Vector2(319, 343),
		Vector2(392, 343), Vector2(480, 365), Vector2(580, 361),
	]
	for point in route:
		if point == Vector2(308, 452):
			await walk_to(chapter.raven, Vector2(125, 451))
		await walk_to(chapter.raven, point)
		check(chapter.raven.position.distance_to(point) < 20.0, "Raven can walk to %s through chapter geometry" % point)
	check(chapter.phase == chapter.Phase.DUEL and chapter.enemy.active, "the trail opens the gate and starts the first Jackal fight")
	finish_dialogue(chapter)
	chapter.enemy.take_damage(1000)
	check(chapter.enemy.health == 360 and not chapter.raven_hack(), "Jackal blocks all damage and early hacks during the first duel")
	chapter.raven.take_damage(500, chapter.enemy.position)
	check(chapter.raven.health == 1 and chapter.phase == chapter.Phase.DUEL, "early damage cannot end Raven's duel")
	chapter.duel_time = 0.0
	chapter._process(29.9)
	check(chapter.phase == chapter.Phase.DUEL and chapter.counter_warning, "the duel is still active just before 30 seconds")
	chapter._process(0.11)
	check(chapter.phase == chapter.Phase.ROOFTOP and chapter.raven.health == 0 and not chapter.effects.links.is_empty(), "the scripted counterhack knocks Raven down after 30 seconds")
	chapter._process(1.0)
	finish_dialogue(chapter)
	check(chapter.phase == chapter.Phase.RESCUE and chapter.actor_is_playable(chapter.player), "Shadepi takes over in the rescue")
	check(chapter.patrol.size() == 3 and not chapter.gate_open, "the patrol guards the way to Raven")
	for guard in chapter.patrol:
		guard.take_damage(100)
	check(chapter.gate_open, "the patrol's defeat opens the rescue gate")
	chapter.player.position = chapter.raven.position + Vector2(-20, 0)
	chapter.interact()
	check(chapter.phase == chapter.Phase.REVIVE, "interacting with Raven starts the rescue dialogue")
	finish_dialogue(chapter)
	check(chapter.phase == chapter.Phase.TEAM and not chapter.coop and chapter.raven.health == 0, "Shadepi starts the 360 HP fight alone")
	chapter.enemy.take_damage(1000)
	check(chapter.enemy.health == 180 and not chapter.raven_joined, "damage stops at exactly half health for the handoff")
	chapter._process(0.01)
	check(chapter.coop and chapter.raven_joined and chapter.raven.health == 100, "Raven stands up and the second player takes control")
	check(chapter.actor_input_prefix(chapter.raven) == "raven_", "co-op Raven has her own input bindings")
	chapter.player.position = Vector2(690, 330)
	chapter.raven.position = Vector2(678, 323)
	await physics_frame
	check(chapter.raven_hack() and chapter.enemy.exposed > 0.0, "Raven hacks Jackal during the team fight")
	chapter.enemy.take_damage(200)
	check(chapter.phase == chapter.Phase.EPILOGUE and chapter.ui.dialogue_open, "winning starts the closing conversation")
	finish_dialogue(chapter)
	chapter.ending.custom_step(3.0)
	check(not chapter.raven.visible and chapter.ui.dialogue_open, "Raven leaves through the door before Shadepi speaks")
	finish_dialogue(chapter)
	chapter.ending.custom_step(2.0)
	check(chapter.phase == chapter.Phase.COMPLETE and chapter.ui.dialogue_open, "the rooftop jump completes the chapter")
	check(chapter.load_game(true) and chapter.phase == chapter.Phase.COMPLETE and not chapter.enemy.visible, "the completed co-op checkpoint can be reloaded")
	chapter.chapter_coop = false
	chapter._enter_checkpoint(chapter.Phase.TEAM)
	chapter.player.position = Vector2(710, 323)
	chapter.enemy.position = WorldData.JACKAL
	chapter.enemy.take_damage(1000)
	chapter._process(0.01)
	chapter.raven.position = Vector2(681, 323)
	await physics_frame
	await process_frame
	await process_frame
	check(not chapter.coop and chapter.raven_joined and chapter.enemy.health < 180, "solo Raven assists with aimed shots after the handoff")
	chapter.queue_free()
	await process_frame

func finish_dialogue(chapter: Node2D) -> void:
	for _line in 16:
		if not chapter.ui.dialogue_open:
			break
		chapter.ui.advance_dialogue()

func walk_to(actor: PixelActor, point: Vector2) -> void:
	var actions := ["move_left", "move_right", "move_up", "move_down"]
	for frame in 210:
		var offset := point - actor.position
		var held := [offset.x < -3.0, offset.x > 3.0, offset.y < -3.0, offset.y > 3.0]
		for index in actions.size():
			if held[index]:
				Input.action_press(actions[index])
			else:
				Input.action_release(actions[index])
		if offset.length() < 5.0:
			break
		await physics_frame
	for action in actions:
		Input.action_release(action)

func check_chapter_two() -> void:
	var chapter = load("res://scenes/chapter_two.tscn").instantiate()
	root.add_child(chapter)
	chapter.new_game()
	finish_dialogue(chapter)
	for scan in chapter.SCANS:
		chapter.player.position = scan
		chapter.interact()
	check(chapter.scan_index == 3, "chapter two scans all approaches before entry")
	chapter.player.position = chapter.DOOR
	chapter.interact()
	finish_dialogue(chapter)
	check(chapter.section == chapter.Section.HIDEOUT, "steel door leads to Raven")
	chapter.player.position = chapter.WORKBENCH
	chapter.interact()
	finish_dialogue(chapter)
	check(chapter.section == chapter.Section.COOLING, "Raven must be connected to the cooling system before diving")
	chapter.player.position = chapter.BATH
	chapter.interact()
	check(chapter.raven_leads() and chapter.actor_is_playable(chapter.raven), "deep dive switches control to Raven")
	chapter.raven.position = chapter.RELAYS[0]
	chapter.ice_cycle = 1.5
	chapter.interact()
	check(chapter.relay_index == 0, "red ICE window blocks access")
	chapter.ice_cycle = 1.2
	chapter.interact()
	check(chapter.relay_index == 1 and chapter.threats.size() == 1, "first hack opens the virus encounter")
	check(chapter.load_game() and chapter.relay_index == 1 and chapter.threats.size() == 1, "the saved data node reloads its encounter")
	for expected in [1, 2, 1, 2, 1]:
		check(chapter.threats.size() == expected, "ICE encounter spawns the expected group")
		var target: Node2D = chapter.threats[0]
		target.elapsed = 1.6
		chapter.raven.position = target.position - Vector2(0, 25)
		chapter.raven.facing = Vector2.DOWN
		chapter.raven_shot()
		if chapter.relay_index == 1 and chapter.threats.is_empty():
			chapter.raven.position = chapter.RELAYS[1]
			chapter.ice_cycle = 0.0
			chapter.interact()
	chapter.raven.position = chapter.RELAYS[2]
	chapter.ice_cycle = 0.0
	chapter.interact()
	check(chapter.dive_hold > 0.0 and chapter.raven_leads(), "countertrace waits for the final download")
	chapter._process(0.6)
	finish_dialogue(chapter)
	check(chapter.section == chapter.Section.RECOVERY and chapter.actor_is_playable(chapter.player), "countertrace returns control to Shadepi")
	chapter.player.position = chapter.SPRAY
	chapter.interact()
	chapter.player.position = chapter.BATH
	chapter.interact()
	finish_dialogue(chapter)
	check(chapter.section == chapter.Section.END and chapter.saved_checkpoint() == chapter.Section.END, "the vow closes and saves chapter two")
	chapter.queue_free()
	await process_frame

func check_campaign() -> void:
	var scene = load("res://scenes/campaign.tscn").instantiate()
	root.add_child(scene)
	scene.new_game()
	finish_dialogue(scene)
	for i in 3:
		scene.player.position = scene._target()
		scene.interact()
	finish_dialogue(scene)
	check(scene.beat == scene.Beat.AMBUSH and scene._living() == 2, "pact leads to the two-shooter ambush")
	for foe in scene.foes:
		foe.take_damage(1000)
	scene.player.position = scene._target()
	scene.interact()
	finish_dialogue(scene)
	check(scene.beat == scene.Beat.CHASE and scene.drive != null, "ambush opens the motorcycle chase")
	var drive = scene.drive
	Input.action_press("hack")
	Input.action_press("attack")
	Input.action_press("dash")
	drive._process(0.01)
	Input.action_release("hack")
	Input.action_release("attack")
	Input.action_release("dash")
	check(drive.hack > 0 and drive.grenade != Vector2.ZERO and not drive.bullets.is_empty(), "bike supports shooting, hacking and grenades")
	drive._process(0.6)
	check(drive.armour < 100, "aligned shots and grenade damage the pursuing car")
	drive.health = 0
	drive._process(0.01)
	check(scene.beat == scene.Beat.CHASE and scene.menu_open and scene.drive.health == 100, "crashing restarts the chase checkpoint")
	scene.close_menu()
	finish_dialogue(scene)
	scene.drive.armour = 0
	scene.drive._process(0.01)
	check(scene.beat == scene.Beat.GARAGE, "defeating the car opens chapter four")
	finish_dialogue(scene)
	scene.player.position = scene._target()
	scene.interact()
	scene.player.position = scene._target()
	scene.interact()
	check(scene.beat == scene.Beat.GARAGE, "lift waits for Raven")
	scene.raven.position = scene._target()
	scene.interact()
	finish_dialogue(scene)
	for i in 3:
		scene.clock = 0
		scene.raven.position = scene._target()
		scene.interact()
	check(scene.beat == scene.Beat.HANGAR and scene.point_index == 3, "transponder preparation opens the port puzzle")
	scene.raven.position = scene.PORTS[0]
	scene.interact()
	check(scene.port_index == 0, "wrong port resets the diagnostic")
	for i in 3:
		scene.clock = 0
		scene.raven.position = scene._target()
		scene.interact()
	finish_dialogue(scene)
	scene.player.position = scene._target()
	scene.interact()
	check(scene.timing != null, "the sanctuary timing game opens before the memories")
	var timing = scene.timing
	await process_frame
	await process_frame
	timing.mode = 2
	timing._process(0.1)
	check(timing.scores[0] > 0 and timing.scores[1] > 0, "both players receive independent time scores")
	timing.elapsed = 15.0
	timing._process(0.01)
	finish_dialogue(scene)
	for i in 3:
		scene.raven.position = scene._target()
		scene.interact()
	finish_dialogue(scene)
	check(scene.beat == scene.Beat.FLIGHT and scene.drive.flight, "chapter five leads to the Aerodyne flight")
	scene.drive.elapsed = 15.0
	scene.drive._process(0.01)
	check(scene.beat == scene.Beat.FLIGHT and scene.menu_open, "landing requires a transmitted transponder code")
	scene.close_menu()
	finish_dialogue(scene)
	scene.drive.elapsed = 9.1
	Input.action_press("hack")
	scene.drive._process(0.01)
	Input.action_release("hack")
	check(scene.drive.transponder_sent, "Raven transmits the code in scanner range")
	scene.drive.elapsed = 15.0
	scene.drive._process(0.01)
	finish_dialogue(scene)
	for i in 2:
		scene.clock = 0
		scene.raven.position = scene._target()
		scene.interact()
	finish_dialogue(scene)
	check(scene.beat == scene.Beat.ROOF and scene._living() == 2, "lift guards fight outside the penthouse")
	for foe in scene.foes:
		foe.hack()
		foe.take_damage(1000)
	await process_frame
	await process_frame
	finish_dialogue(scene)
	check(scene.beat == scene.Beat.BOSS and scene._living() == 1, "Kenzō is alone in the penthouse")
	scene.foes.back().take_damage(1000)
	await process_frame
	await process_frame
	finish_dialogue(scene)
	check(scene.beat == scene.Beat.ESCAPE, "boss defeat starts the sixty-second escape")
	for i in 4:
		scene.clock = 0
		scene.player.position = scene._target()
		scene.interact()
	finish_dialogue(scene)
	for i in 4:
		scene.player.position = scene._target()
		scene.interact()
		finish_dialogue(scene)
	check(scene.beat == scene.Beat.END and scene.saved_checkpoint() == scene.Beat.END, "consent and three ritual steps reach and save the ending")
	scene.queue_free()
	await process_frame
