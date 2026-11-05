extends SceneTree

const Story = preload("res://scripts/campaign_story.gd")
const Flow = preload("res://scripts/chapter_flow.gd")
var checks := 0
var failures := 0
var query := PhysicsShapeQueryParameters2D.new()

func _initialize() -> void:
	var shape := CircleShape2D.new()
	shape.radius = 7.0
	query.shape = shape
	query.collision_mask = 1
	run.call_deferred()

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("FAIL: " + message)

func clear_at(scene: Node2D, point: Vector2) -> bool:
	query.transform = Transform2D(0, point)
	return scene.get_world_2d().direct_space_state.intersect_shape(query, 1).is_empty()

func freeze(node: Node) -> void:
	# PROCESS_MODE_DISABLED removes physics bodies too, invalidating route checks.
	node.set_process(false)
	node.set_physics_process(false)
	for child in node.get_children():
		freeze(child)

func accessible(scene: Node2D, start: Vector2) -> Array[Vector2]:
	var found: Array[Vector2] = []
	if not clear_at(scene, start):
		return found
	var queue: Array[Vector2i] = [Vector2i.ZERO]
	var visited := {Vector2i.ZERO: true}
	var cursor := 0
	while cursor < queue.size():
		var cell := queue[cursor]
		cursor += 1
		var point := start + Vector2(cell) * 8.0
		found.append(point)
		for direction in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
			var next: Vector2i = cell + direction
			var pos := start + Vector2(next) * 8.0
			if visited.has(next) or pos.x < 7 or pos.x > 1017 or pos.y < 180 or pos.y > 550:
				continue
			visited[next] = true
			if clear_at(scene, pos) and clear_at(scene, (pos + point) * 0.5):
				queue.append(next)
	return found

func check_routes(scene: Node2D, start: Vector2, targets: Array, reach: float, name: String) -> void:
	check(not clear_at(scene, Vector2(512, 50)), name + ": physics query detects the real upper wall")
	var points := accessible(scene, start)
	check(not points.is_empty(), name + ": spawn has full player clearance")
	for target: Vector2 in targets:
		var distance := INF
		for point in points:
			distance = minf(distance, point.distance_to(target))
		check(distance < reach, "%s: target %s reachable without destroying props (distance %.1f)" % [name, target, distance])

func check_ui(scene: Node2D) -> void:
	scene.ui._process(0.0)
	scene.ui.fit_hud_text()
	for label: Label in [scene.ui.mission_title, scene.ui.controls, scene.ui.abilities]:
		var width := label.get_theme_font("font").get_string_size(label.text, HORIZONTAL_ALIGNMENT_LEFT, -1, label.get_theme_font_size("font_size")).x
		check(width <= label.size.x, "HUD fits: " + label.text)
	var objective: Label = scene.ui.objective
	check(objective.get_theme_font("font").get_multiline_string_size(objective.text, HORIZONTAL_ALIGNMENT_LEFT, 214, 11).y <= 28, "Objective fits: " + objective.text)

func finish_dialogue(scene: Node2D) -> void:
	for i in 100:
		if not scene.ui.dialogue_open:
			return
		var label: Label = scene.ui.dialogue_text
		check(label.get_theme_font("font").get_multiline_string_size(label.text, HORIZONTAL_ALIGNMENT_LEFT, 562, 12).y <= 44, "Dialogue page fits: " + label.text)
		scene.ui.advance_dialogue()
	check(false, "dialogue terminates")

func run() -> void:
	# Deliberately stale later checkpoints must not skip the next chapter.
	var config := ConfigFile.new()
	config.set_value("chapter", "section", 4)
	config.save("user://shadepi-chapter-two.cfg")
	config = ConfigFile.new()
	config.set_value("campaign", "beat", Story.Beat.END)
	config.save("user://shadepi-campaign.cfg")
	var first = load("res://scenes/chapter_one.tscn").instantiate()
	root.add_child(first)
	current_scene = first
	first._enter_checkpoint(first.Phase.COMPLETE)
	first.interact()
	await scene_changed
	var two = current_scene
	freeze(two)
	check(two.section == two.Section.YARD, "chapter 1 exit starts chapter 2 despite an old completed save")
	check(not has_meta(Flow.FRESH_ENTRY), "fresh chapter marker consumed exactly once")
	finish_dialogue(two)
	for section in [two.Section.YARD, two.Section.HIDEOUT, two.Section.COOLING, two.Section.DIVE, two.Section.RECOVERY, two.Section.END]:
		two._enter(section)
		freeze(two)
		await physics_frame
		await physics_frame
		await process_frame
		var targets: Array = []
		match section:
			two.Section.YARD:
				targets.assign(two.SCANS)
				targets.append(two.DOOR)
			two.Section.DIVE:
				targets.assign(two.RELAYS)
			two.Section.RECOVERY:
				targets.assign([two.SPRAY, two.BATH])
			_:
				if two._target() != Vector2.ZERO:
					targets.append(two._target())
		check_routes(two, two.raven.position if two.raven_leads() else two.player.position, targets, 48, "Chapter 2 / %d" % section)
		check_ui(two)
	# Recovery must cover physical-world scenery deaths, not only the dive.
	two._enter(two.Section.YARD)
	two.player.health = 1
	two.player.take_damage(24, two.player.position - Vector2.ONE)
	await process_frame
	check(two.player.health == 100 and two.section == two.Section.YARD, "scenery death restores chapter 2 checkpoint")
	two._enter(two.Section.DIVE, 1)
	two.raven.health = 1
	two.raven.take_damage(24, two.raven.position - Vector2.ONE)
	await process_frame
	check(two.raven.health == 100 and two.relay_index == 1 and two.threats.size() == 1, "dive death restores health and relay encounter")
	two._enter(two.Section.END)
	two.interact()
	await scene_changed
	var campaign = current_scene
	freeze(campaign)
	check(campaign.beat == Story.Beat.PACT, "chapter 2 exit starts chapter 3 despite old campaign ending")
	check(not has_meta(Flow.FRESH_ENTRY), "campaign consumes chapter entry marker")
	for beat in range(Story.Beat.END + 1):
		campaign._enter(beat)
		finish_dialogue(campaign)
		freeze(campaign)
		check_ui(campaign)
		if beat > 0:
			check(Story.CHAPTERS[beat] >= Story.CHAPTERS[beat - 1] and Story.CHAPTERS[beat] <= Story.CHAPTERS[beat - 1] + 1, "chapter order at beat %d" % beat)
		if beat not in [Story.Beat.CHASE, Story.Beat.FLIGHT]:
			await physics_frame
			await physics_frame
			await process_frame
			check_routes(campaign, campaign.raven.position if campaign.raven_leads() else campaign.player.position, Story.POINTS[beat], 43, "Campaign / %d" % beat)
		if beat == Story.Beat.HANGAR:
			check_routes(campaign, campaign.raven.position, campaign.PORTS, 22, "Hangar ports")
		if beat in [Story.Beat.LAKE, Story.Beat.END]:
			check(not clear_at(campaign, Vector2(746, 353)), "old ending position is correctly inside water")
			for point: Vector2 in Story.POINTS[Story.Beat.LAKE]:
				check(clear_at(campaign, point) and clear_at(campaign, point + Vector2(18, 5)), "both ritual participants stand on shore at " + str(point))
			check(clear_at(campaign, campaign.player.position) and clear_at(campaign, campaign.raven.position), "finale actors have clearance on land")
		if beat == Story.Beat.ECHO:
			campaign._start_echo()
			campaign._enter_echo()
			freeze(campaign)
			finish_dialogue(campaign)
			await physics_frame
			await physics_frame
			await process_frame
			check_routes(campaign, campaign.raven.position, campaign.Painted.ECHO_POINTS, 43, "Memory anchors")
			for index in [0, 1, 2]:
				campaign.point_index = index
				campaign.raven.position = Vector2(551, 426)
				campaign.interact()
				check(campaign.raven.position == (campaign.SPAWN if index == 0 else campaign.Painted.ECHO_POINTS[index - 1]), "false echo returns to actual memory anchor %d" % index)
		if beat == Story.Beat.ESCAPE:
			var long_text := "Langer Text. ".repeat(80)
			var callback_count := [0]
			campaign.ui.dialogue([["SYSTEM", long_text]], func(): callback_count[0] += 1)
			check(campaign.ui.dialogue_lines.size() > 1 and callback_count[0] == 0, "long dialogue paginates without completing early")
			var pages: Array[String] = [campaign.ui.dialogue_text.text]
			for line: Array in campaign.ui.dialogue_lines:
				pages.append(line[1])
			check(" ".join(pages) == long_text, "pagination preserves every word and its order")
			var timer: float = campaign.countdown
			campaign._process(10.0)
			check(campaign.countdown == timer, "escape clock pauses during paginated dialogue")
			finish_dialogue(campaign)
			check(callback_count[0] == 1, "dialogue completion runs exactly once after the last page")
			campaign.menu_open = true
			campaign._process(10.0)
			check(campaign.countdown == timer, "escape clock pauses in menu")
			campaign.close_menu()
			campaign.countdown = 0.01
			campaign._process(0.02)
			check(campaign.countdown == 60.0 and campaign.beat == Story.Beat.ESCAPE and campaign.menu_open, "escape timeout restarts only escape checkpoint")
	# Hack range must use Raven, independently of Shadepi's position.
	campaign._enter(Story.Beat.AMBUSH)
	finish_dialogue(campaign)
	await physics_frame
	await process_frame
	campaign.foes[0].position = Vector2(470, 420)
	campaign.foes[1].health = 0
	campaign.raven.position = Vector2(450, 420)
	campaign.player.position = Vector2(100, 420)
	check(campaign.raven_hack(), "Raven can hack a nearby target when Shadepi is far away")
	campaign.hack_cooldown = 0
	campaign.raven.position = Vector2(100, 420)
	campaign.player.position = Vector2(450, 420)
	check(not campaign.raven_hack(), "Shadepi cannot extend Raven's hack range")
	# Resume stays independent of the sequential story entry.
	campaign._enter(Story.Beat.ROOF)
	campaign.save_game()
	campaign.queue_free()
	await process_frame
	campaign = load("res://scenes/campaign.tscn").instantiate()
	root.add_child(campaign)
	freeze(campaign)
	check(campaign.beat == Story.Beat.ROOF, "menu/direct entry still resumes the saved campaign checkpoint")
	var invalid := ConfigFile.new()
	invalid.set_value("campaign", "beat", "11")
	invalid.save("user://invalid-checkpoint.cfg")
	check(Flow.checkpoint("user://invalid-checkpoint.cfg", "campaign", "beat", range(12)) == -1, "invalid checkpoint cannot unlock later chapters")
	check(campaign.Dressing.items("lake").is_empty(), "lake shore contains no unexplained industrial cargo")
	for layout in ["chamber", "suite"]:
		for item in campaign.Dressing.items(layout):
			check(item[1] not in ["vending", "crate", "dumpster", "barrel"], layout + " has appropriate technology instead of street clutter")
	campaign.queue_free()
	await process_frame
	print("STORY AUDIT: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
