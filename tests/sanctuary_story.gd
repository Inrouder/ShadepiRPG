extends SceneTree
## v0.29.0 · CodexAI: chronology, controller, persistence and abort regressions.
var checks := 0
var failures := 0
func _initialize() -> void: run.call_deferred()
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("FAIL: " + message)
func skip(w) -> void:
	for i in 5:
		if w.cutscene.running: w.cutscene.skip()
		await process_frame
func pad(w, button: int) -> void:
	var event := InputEventJoypadButton.new()
	event.device = 0
	event.button_index = button
	event.pressed = true
	w._unhandled_input(event)
	await process_frame
func blocked(w, point: Vector2) -> bool:
	var shape := CircleShape2D.new()
	shape.radius = 7
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = shape
	query.collision_mask = 1
	query.transform = Transform2D(0, point)
	return not w.get_world_2d().direct_space_state.intersect_shape(query).is_empty()
func run() -> void:
	Engine.max_fps = 120
	var w = load("res://scenes/campaign.tscn").instantiate()
	root.add_child(w)
	var devices: Array[int] = [0]
	w.gamepads.assign(devices, false)
	w._enter(w.Beat.ECHO)
	await skip(w)
	check(w.sanctuary_stage == 1 and not w.echo_ready and w.raven_leads(), "Raven arrives alone and automatically rests before the two-hour search")
	check(not w.player.visible and not w.sanctuary_tableau.sprite.visible and w.sanctuary_tableau.door.visible, "Shadepi stays behind the closed door, with no duplicate standing body")
	check(w.painted_layout == "chamber" and w._target() == w.SanctuaryTableau.DOOR, "after automatic sleeping the objective leads to the real doorway")
	check(not w.cutscene.running and w.timing == null and not w.echo_ready, "automatic rest ends without the retired timing puzzle")
	check(w.sanctuary_stage == 1 and not w.echo_ready and w._target() == w.SanctuaryTableau.DOOR, "two-hour sleep precedes searching at the separate door")
	check(w.load_game() and w.sanctuary_stage == 1 and not w.cutscene.running, "load after sleep resumes the search without replaying arrival or sleeping")
	w.raven.position = w._target()
	await pad(w, JOY_BUTTON_A)
	await skip(w)
	await physics_frame
	await physics_frame
	check(w.sanctuary_stage == 2 and w.painted_layout == "compensator", "door opens onto a different compensator map")
	check(w.sanctuary_tableau.sprite.visible and not w.sanctuary_tableau.door.visible and not w.player.visible, "motionless seated Shadepi is the only present Shadepi")
	check(blocked(w, Vector2(500, 312)) and not blocked(w, w._target()), "medical chair has a real footprint and its approach is clear")
	check(not blocked(w, w.SanctuaryTableau.ENTRY), "room entry has player clearance")
	check(w.load_game() and w.sanctuary_stage == 2 and w.sanctuary_tableau.sprite.visible, "save inside room restores seated figure, map and objective")
	w.raven.position = w._target()
	await pad(w, JOY_BUTTON_A)
	check(w.cutscene.running and not w.echo_ready, "memory cannot start before the mask-contact scene")
	await skip(w)
	check(w.echo_ready and w.raven.visible and not w.sanctuary_tableau.visible and w.painted_layout == "memory", "contact transfers Raven to the anchor space and clears the present tableau")
	check(w.load_game() and w.echo_ready and not w.cutscene.running, "save within memory space does not replay the touch")
	# Returning after all three memories must restore the same physical room first.
	w.memory_attack_complete = true
	w.memory_sacrifice_complete = true
	w.memory_legacy_complete = true
	w.point_index = 2
	w._scene_echo_end()
	# Keep the aftermath visible until its first spoken line.
	Engine.time_scale = 10
	for i in 500:
		await process_frame
		if w.cutscene.waiting_input: break
	check(not w.echo_ready and w.painted_layout == "compensator" and w.sanctuary_tableau.visible and w.raven.visible, "Raven returns physically to Shadepi's chair before speaking")
	check(w.cutscene.line_label.text.contains("Was war das denn?"), "first return reaction is surprise rather than unexplained knowledge")
	check(w.save_game(), "manual save works during aftermath")
	check(w.load_game() and w.cutscene.running and w.memory_legacy_complete, "loading completed memories replays only the return conversation")
	await skip(w)
	Engine.time_scale = 1
	check(w.beat == w.Beat.FLIGHT, "limited explanation continues to existing flight and tower storyline")
	# Cancelled asynchronous steps must not move actors or replace another chapter.
	w._enter(w.Beat.ECHO)
	w._enter(w.Beat.ROOF)
	for i in 8: await process_frame
	check(w.beat == w.Beat.ROOF and w.sanctuary_tableau == null and not w.echo_ready, "chapter change cancels arrival without stale dialogue or map mutations")
	# Pre-v0.29 and malformed saves remain safe.
	var cfg := ConfigFile.new()
	cfg.set_value("campaign", "beat", w.Beat.ECHO)
	cfg.set_value("campaign", "sanctuary_stage", "broken")
	cfg.save(w.Admin.checkpoint_path(w.SAVE, self))
	check(w.load_game() and w.sanctuary_stage == 0 and not w.echo_ready, "invalid stage safely starts original-story arrival")
	await skip(w)
	w.sanctuary_tableau.set_pose(2)
	w.sanctuary_tableau.transfer_step(0.5)
	check(w.sanctuary_tableau.flow.visible and w.sanctuary_tableau.transfer_power > 0.99, "transfer has a visible white stream and eye shimmer")
	w.sanctuary_tableau.transfer_step(1)
	check(not w.sanctuary_tableau.flow.visible and is_zero_approx(w.sanctuary_tableau.transfer_power), "transfer endpoints leave no lingering beam")
	var door_position: Vector2 = w.sanctuary_tableau.door.global_position
	w.sanctuary_tableau.set_pose(3)
	check(w.sanctuary_tableau.door.global_position == door_position, "sleep pose never displaces the physical doorway")
	# Exercise the contact without skipping: exact ordering and real paused animation.
	w._enter(w.Beat.ECHO, 0, 0, false, false, false, false, 2)
	w.raven.position = w._target()
	w._start_echo()
	Engine.time_scale = 12
	var spoken: Array[String] = []
	var paused_transfer := false
	for i in 800:
		await process_frame
		if w.cutscene.waiting_input:
			var line: String = w.cutscene.line_label.text
			if not spoken.has(line): spoken.append(line)
			w.cutscene.advance()
		if not paused_transfer and w.sanctuary_tableau.transfer_power > 0.1:
			paused_transfer = true
			w.menu_open = true
			var power: float = w.sanctuary_tableau.transfer_power
			var frame: int = w.sanctuary_tableau.flow.frame
			for pause_frame in 6: await process_frame
			check(w.sanctuary_tableau.transfer_power == power and w.sanctuary_tableau.flow.frame == frame and not w.echo_ready, "pause freezes the actual white transfer and delays entry into memories")
			w.menu_open = false
		if w.echo_ready and not w.cutscene.running: break
	check(paused_transfer and w.echo_ready, "unskipped contact completes through the white transfer")
	check(spoken.slice(0, 5) == ["Schläfst du?", "Wer ist eigentlich unter der Maske?", "Mach das nicht.", "Hast du Angst vor einer Frau?", "Nein, ich glaube nur …"], "mask exchange preserves all five requested lines in order before memories")
	Engine.time_scale = 1
	w.queue_free()
	await process_frame
	print("SANCTUARY STORY: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
