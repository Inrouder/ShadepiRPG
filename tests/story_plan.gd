extends SceneTree
## v0.48.0 · ClaudeHelper: Kapitel 3 – projizierter Towerplan, Prüfschritte, Planbesprechung.
var checks := 0
var failures := 0
const TowerPlan = preload("res://scripts/tower_plan_hologram.gd")

func _initialize() -> void: run.call_deferred()

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("FAIL: " + message)

func run() -> void:
	# Pixelquelle: vier echte transparente Ebenen, keine leeren Hervorhebungen.
	var sheet: Image = load("res://assets/story/tower-plan.png").get_image()
	check(sheet.get_width() == 256 and sheet.get_height() == 96, "tower plan sheet has four 64x96 frames")
	check(sheet.get_pixel(0, 50).a == 0.0, "tower plan keeps real transparent outer space")
	for layer in 4:
		var used := 0
		for y in 96:
			for x in 64:
				if sheet.get_pixel(layer * 64 + x, y).a > 0.0: used += 1
		check(used > (400 if layer == 0 else 15), "tower plan layer %d carries placed pixels (%d)" % [layer, used])
	var w = load("res://scenes/campaign.tscn").instantiate()
	root.add_child(w)
	Engine.max_fps = 240
	Engine.time_scale = 10
	w.close_menu(); w.started = true
	w.fresh_entry = true
	w._enter(w.Beat.PACT)
	check(is_instance_valid(w.tower_plan) and w.tower_plan.target_reveal == 0.0, "fresh pact keeps the plan dark until Raven projects it")
	var spoken: Array[String] = []
	var shown_during_scene := false
	for i in 3000:
		await process_frame
		if w.cutscene.waiting_input:
			spoken.append(w.cutscene.line_label.text)
			if w.tower_plan.target_reveal > 0.0: shown_during_scene = true
			w.cutscene.advance()
		if not w.in_cinematic() and i > 10: break
	check(shown_during_scene and w.tower_plan.target_reveal == 1.0, "Raven projects the tower plan during the pact scene")
	check(spoken.has("Ich helfe dir. Aber wir sind keine Freunde.") and spoken.find("Ich helfe dir. Aber wir sind keine Freunde.") > spoken.find("Ich würde Kenzō gerne tot sehen. Ich kann nicht mein Leben lang fliehen."), "pact keeps the novel order: wish for Kenzō's death, then the boundary")
	var expected := [TowerPlan.ELEVATOR, TowerPlan.PAD, TowerPlan.SCANNER]
	for step in 2:
		w._complete_point()
		check(w.tower_plan.highlight == expected[step], "plan check %d highlights its matching tower layer" % step)
	# Pause freezes the projection clock.
	w.menu_open = true
	var clock: float = w.tower_plan.clock
	for i in 5: await process_frame
	check(w.tower_plan.clock == clock, "pause freezes the hologram")
	w.menu_open = false
	w._complete_point()
	var focused := {}
	for i in 4000:
		await process_frame
		if is_instance_valid(w.tower_plan): focused[w.tower_plan.highlight] = true
		if w.cutscene.waiting_input: w.cutscene.advance()
		if w.beat != w.Beat.PACT: break
	check(focused.has(TowerPlan.PAD) and focused.has(TowerPlan.SCANNER) and focused.has(TowerPlan.ELEVATOR), "plan briefing points at pad, scanner and guard floor")
	check(w.beat == w.Beat.AMBUSH and w.tower_plan == null, "briefing advances to the ambush and removes the projection")
	# Resuming the pact beat shows Raven's existing plan without replaying the scene.
	w.fresh_entry = false
	w._enter(w.Beat.PACT)
	check(is_instance_valid(w.tower_plan) and w.tower_plan.reveal == 1.0 and not w.in_cinematic(), "resumed pact shows the plan immediately")
	Engine.time_scale = 1
	w.queue_free()
	await process_frame
	print("STORY PLAN: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
