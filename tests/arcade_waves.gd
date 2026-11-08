extends SceneTree

var checks := 0
var failures := 0
var query := PhysicsShapeQueryParameters2D.new()

func _initialize() -> void:
	var shape := CircleShape2D.new()
	shape.radius = 7
	query.shape = shape
	query.collision_mask = 1
	run.call_deferred()

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("FAIL: " + message)

func freeze(scene: Node) -> void:
	scene.set_process(false)
	scene.set_physics_process(false)
	for child in scene.get_children():
		freeze(child)

func clear_at(scene: Node2D, point: Vector2) -> bool:
	query.transform = Transform2D(0, point)
	return scene.get_world_2d().direct_space_state.intersect_shape(query, 1).is_empty()

func finish_dialogue(scene: Node2D) -> void:
	for _round in 4:
		if scene.in_cinematic():
			scene.cutscene.skip()
		_finish_dialogue_once(scene)
	if scene.in_cinematic():
		scene.cutscene.skip()

func _finish_dialogue_once(scene: Node2D) -> void:
	for page in 60:
		if not scene.ui.dialogue_open:
			return
		scene.ui.advance_dialogue()

func reachable(scene: Node2D, start: Vector2, section: Dictionary) -> Array[Vector2]:
	var result: Array[Vector2] = []
	var cells: Array[Vector2i] = [Vector2i.ZERO]
	var seen := {Vector2i.ZERO: true}
	var cursor := 0
	while cursor < cells.size():
		var cell := cells[cursor]
		cursor += 1
		var point := start + Vector2(cell) * 8
		result.append(point)
		for direction in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
			var next: Vector2i = cell + direction
			var candidate := start + Vector2(next) * 8
			if seen.has(next) or candidate.x <= section.bounds.x or candidate.x >= section.bounds.y or candidate.y <= section.floor.x or candidate.y >= section.floor.y:
				continue
			seen[next] = true
			if clear_at(scene, candidate) and clear_at(scene, (point + candidate) / 2):
				cells.append(next)
	return result

func verify_encounter(scene: Node2D, expected_total: int) -> void:
	var encounter = scene.encounter
	var total := 0
	var visited := -1
	var paths: Array[Vector2] = []
	for step in 30:
		freeze(scene)
		await physics_frame
		await process_frame
		if encounter.finished:
			break
		var section: Dictionary = encounter.sections[encounter.section_index]
		if encounter.waiting:
			check(clear_at(scene, Vector2(section.bounds.x, 410)), "completed section releases its exit")
			scene.player.health = 60
			encounter.leader().position = section.start
			encounter._process(0)
			freeze(scene)
			await physics_frame
			await process_frame
		if visited != encounter.section_index:
			visited = encounter.section_index
			check(clear_at(scene, section.start), "section entrance has player clearance")
			paths = reachable(scene, section.start, section)
			check(not paths.is_empty(), "section has walkable floor")
		check(not clear_at(scene, Vector2(section.bounds.y, 410)), "forward barrier blocks walking and dashing")
		check(not clear_at(scene, Vector2(section.bounds.x, 410)), "rear barrier closes during combat")
		var actor: PixelActor = encounter.leader()
		var original := actor.position
		actor.position = Vector2(section.bounds.y - 25, 410)
		actor.move_and_collide(Vector2(200, 0))
		check(actor.position.x < section.bounds.y - 7, "a dash-sized physical move cannot cross the exit")
		actor.position = original
		for foe in encounter.fighters:
			total += 1
			check(clear_at(scene, foe.position), "enemy spawn is outside walls and scenery: " + str(foe.position))
			var distance := INF
			for point in paths:
				distance = minf(distance, point.distance_to(foe.position))
			check(distance < 12, "enemy can be reached inside the section: " + str(foe.position))
			foe.hack()
			foe.take_damage(1000)
		encounter._process(0)
		if encounter.break_left > 0:
			var wave: int = encounter.wave_index
			if scene.get_script().resource_path.ends_with("campaign.gd"):
				check(scene._target() == Vector2.ZERO, "exit stays unavailable between waves")
			scene.menu_open = true
			encounter._process(5)
			check(encounter.break_left == 2, "pause freezes reinforcement countdown")
			scene.menu_open = false
			scene.ui.dialogue([["TEST", "Wellenpause"]])
			encounter._process(5)
			check(encounter.break_left == 2, "dialogue freezes reinforcement countdown")
			finish_dialogue(scene)
			encounter._process(1.9)
			check(encounter.wave_index == wave and encounter.living() == 0, "wave never starts early")
			# Camp an authored arrival point: reinforcement must choose clear floor nearby.
			encounter.leader().position = section.waves[wave + 1][0][0]
			encounter._process(0.11)
			for foe in encounter.fighters:
				check(foe.position.distance_to(encounter.leader().position) >= 56, "reinforcement never appears on the player")
		if encounter.finished:
			break
	check(encounter.finished and total == expected_total, "all authored waves complete, expected %d enemies, got %d" % [expected_total, total])
	await physics_frame
	await process_frame
	if is_instance_valid(encounter):
		check(encounter.right_gate.get_child(0).disabled, "final barrier is released")

func run() -> void:
	var chapter = load("res://scenes/chapter_one.tscn").instantiate()
	root.add_child(chapter)
	chapter._enter_checkpoint(chapter.Phase.HUNT)
	await verify_encounter(chapter, 12)
	check(not chapter.gate_open, "hunt still requires its story trail after all waves")
	chapter.trail_index = chapter.TRAIL.size()
	chapter._check_hunt_gate()
	check(not chapter.gate_open, "all waves plus trail unlock terminal, not gate")
	chapter.raven.position = chapter.TRAIL.back()
	chapter.interact()
	check(preload("res://tests/terminal_solver.gd").complete(chapter) and chapter.gate_open, "matrix hack opens Jackal's gate")
	chapter._enter_checkpoint(chapter.Phase.RESCUE)
	await verify_encounter(chapter, 8)
	check(chapter.gate_open and chapter.raven.health == 0, "rescue opens only after all waves without reviving Raven early")
	# Check automatic saving at section boundaries, death and mid-wave reload.
	chapter._enter_checkpoint(chapter.Phase.HUNT)
	for wave in 2:
		for foe in chapter.encounter.fighters:
			foe.take_damage(1000)
		chapter.encounter._process(0)
		if wave == 0:
			chapter.encounter._process(2)
	check(chapter.encounter.section_index == 1 and chapter.encounter.waiting, "next section waits for the player")
	chapter.load_game(false)
	check(chapter.encounter.section_index == 1 and chapter.encounter.wave_index == 0, "autosave resumes the next section")
	check(chapter.raven.position == chapter.Waves.HUNT[1].start and chapter.trail_index == 1, "restored hunt keeps earlier trail progress")
	chapter.player_defeated()
	check(chapter.encounter.section_index == 1 and chapter.raven.health == 100, "death restarts current section with full health")
	chapter.close_menu()
	chapter.chapter_coop = true
	chapter._enter_checkpoint(chapter.Phase.HUNT, 2)
	chapter.save_game()
	chapter.load_game(false)
	check(chapter.encounter.section_index == 1, "solo section is independent from co-op save")
	chapter.load_game(true)
	check(chapter.encounter.section_index == 2, "co-op section restores independently")
	var cfg := ConfigFile.new()
	cfg.set_value("chapter_one", "solo", chapter.Phase.HUNT)
	cfg.set_value("arcade", "solo", "corrupt")
	cfg.save(chapter.CHAPTER_SAVE)
	chapter.load_game(false)
	check(chapter.encounter.section_index == 0, "invalid or legacy section data starts safely")
	cfg.erase_section("arcade")
	cfg.save(chapter.CHAPTER_SAVE)
	chapter.load_game(false)
	check(chapter.encounter.section_index == 0, "pre-arcade checkpoint remains loadable")
	chapter.queue_free()
	await process_frame
	var campaign = load("res://scenes/campaign.tscn").instantiate()
	root.add_child(campaign)
	campaign._enter(campaign.Beat.AMBUSH)
	finish_dialogue(campaign)
	await verify_encounter(campaign, 13)
	check(campaign._target() != Vector2.ZERO, "motorcycle unlocks after last ambush section")
	campaign._enter(campaign.Beat.AMBUSH, 1)
	finish_dialogue(campaign)
	campaign.save_game()
	campaign.load_game()
	check(campaign.encounter.section_index == 1 and campaign.player.position == campaign.Waves.AMBUSH[1].start, "campaign resumes saved combat section")
	finish_dialogue(campaign)
	campaign._retry("Test")
	check(campaign.encounter.section_index == 1 and campaign.menu_open, "campaign death preserves section checkpoint")
	campaign._enter(campaign.Beat.ROOF)
	finish_dialogue(campaign)
	for point in 2:
		campaign.clock = 0
		campaign.raven.position = campaign._target()
		campaign.interact()
		check(preload("res://tests/terminal_solver.gd").complete(campaign), "Raven solves roof access terminal")
	finish_dialogue(campaign)
	check(campaign.beat == campaign.Beat.BOSS and campaign._living() == 1, "roof terminals lead straight to the single Kenzō boss")
	campaign.foes.back().take_damage(1000)
	await process_frame
	await process_frame
	finish_dialogue(campaign)
	check(campaign.beat == campaign.Beat.ESCAPE, "Kenzō's defeat opens the escape")
	campaign.tower.elapsed = campaign.tower.TRANSFER_SECONDS
	await verify_encounter(campaign, 8)
	await process_frame
	finish_dialogue(campaign)
	check(campaign.escape_guards_cleared and campaign.beat == campaign.Beat.ESCAPE, "all lift waves after Kenzō release the escape timer")
	campaign.queue_free()
	await process_frame
	print("ARCADE WAVES: %d checks, %d failures" % [checks, failures])
	quit(0 if failures == 0 else 1)
