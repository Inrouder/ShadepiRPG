extends SceneTree
## v0.30.0 · CodexAI: regressions from Fehlerbericht 8.pdf.
var checks := 0
var failures := 0
func _initialize() -> void: run.call_deferred()
func check(ok: bool, text: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("FAIL: " + text)
func blocked(w, point: Vector2) -> bool:
	var shape := CircleShape2D.new()
	shape.radius = 7
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = shape
	query.collision_mask = 1
	query.transform = Transform2D(0, point)
	return not w.get_world_2d().direct_space_state.intersect_shape(query).is_empty()
func pad(w, button: int) -> void:
	var event := InputEventJoypadButton.new()
	event.device = 0
	event.button_index = button
	event.pressed = true
	w._unhandled_input(event)
func run() -> void:
	Engine.max_fps = 120
	var w = load("res://scenes/campaign.tscn").instantiate()
	root.add_child(w)
	w._enter(w.Beat.HANGAR)
	await physics_frame
	await physics_frame
	for point in [Vector2(310, 321), Vector2(538, 387), Vector2(774, 310)]:
		check(blocked(w, point), "hangar console blocks actual character physics at " + str(point))
	for point in w.Story.POINTS[w.Beat.HANGAR]:
		check(not blocked(w, point), "console interaction point has full player clearance at " + str(point))
	w._enter(w.Beat.ECHO)
	Engine.time_scale = 12
	var bubble := false
	var poses := {}
	var sleep_time := 0.0
	for i in 1000:
		await process_frame
		if w.sanctuary_tableau.speech.visible:
			bubble = true
			check(w.sanctuary_tableau.speech.label.text.contains("Hey Raven"), "door bubble contains the actual spoken line")
		if w.sanctuary_tableau.sprite.visible:
			poses[w.sanctuary_tableau.frame_index] = true
			if w.sanctuary_tableau.frame_index == 4: sleep_time += root.get_process_delta_time()
		if w.cutscene.waiting_input: w.cutscene.advance()
		if not w.cutscene.running and w.sanctuary_stage == 1: break
	check(bubble, "arrival identifies Shadepi behind the integrated doorway")
	check(poses.has(3) and poses.has(4) and poses.has(5), "Raven visibly sits, lies asleep and wakes before standing")
	check(sleep_time >= 3.5, "sleeping is held for a readable shot, not a one-second flash")
	check(w.sanctuary_stage == 1 and w.raven.visible and not w.echo_ready, "automatic sleep ends at the two-hour search checkpoint")
	w.fresh_entry = true
	w._enter(w.Beat.FLIGHT)
	var launch = w.departure
	check(launch != null and w.flight_intro_pending and not w.drive.visible, "fresh flight begins in the hangar instead of the live flight view")
	var stages := {}
	var paused := false
	var transcript: Array[String] = []
	var sequence: Array[String] = []
	for i in 1100:
		await process_frame
		if not is_instance_valid(w.departure): break
		stages[launch.stage] = true
		sequence.assign(launch.events)
		if w.cutscene.waiting_input:
			var line: String = w.cutscene.line_label.text
			if not transcript.has(line): transcript.append(line)
			w.cutscene.advance()
		if launch.stage == "failure" and not paused:
			paused = true
			var clock: float = launch.clock
			var elapsed: float = w.drive.elapsed
			w.menu_open = true
			for j in 8: await process_frame
			check(launch.clock == clock and w.drive.elapsed == elapsed and launch.cockpit_frame == 1, "pause freezes cockpit failure, flight clock and visuals")
			w.menu_open = false
	check(stages.has_all(["boarding", "cockpit", "failure", "knock", "restart", "takeoff", "outside"]), "all seven departure phases really play")
	check(sequence.find("failure") < sequence.find("knock") and sequence.find("knock") < sequence.find("restart") and sequence.find("restart") < sequence.find("takeoff"), "dashboard knock restarts engines before takeoff")
	check(transcript.has("Dreckmühle.") and transcript.has("Ich mag lieber Motorräder."), "cockpit characters react to the failed start")
	check(w.departure == null and not w.flight_intro_pending and w.drive.visible and w.drive.phase == "canyon", "takeoff hands over to existing flight controls")
	check(not w.drive.engine_repaired, "startup knock does not bypass Raven's later in-flight jumper repair")
	# Saving midway restarts the introduction safely; no half-boarded actors survive.
	w.fresh_entry = true
	w._enter(w.Beat.FLIGHT)
	check(w.save_game() and w.load_game() and w.departure != null and w.departure.stage == "boarding" and w.flight_intro_pending, "mid-intro save reloads into a complete hangar scene")
	var devices: Array[int] = [0]
	w.gamepads.assign(devices, false)
	pad(w, JOY_BUTTON_B)
	for i in 5: await process_frame
	check(w.departure == null and not w.flight_intro_pending and w.drive.visible and not w.cutscene.running, "controller B skips departure cleanly without a hidden live flight")
	w.fresh_entry = true
	w._enter(w.Beat.FLIGHT)
	w._enter(w.Beat.ROOF)
	for i in 8: await process_frame
	check(w.departure == null and w.beat == w.Beat.ROOF and not w.cutscene.running, "chapter change cancels departure without stale fades or actors")
	w.queue_free()
	await process_frame
	Engine.time_scale = 1
	print("REPORT 8: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
