extends SceneTree

const Projectile = preload("res://scripts/power_projectile.gd")
var checks := 0
var failures := 0

func _initialize() -> void:
	run.call_deferred()

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("FAIL: " + message)

func freeze(node: Node) -> void:
	node.set_process(false)
	node.set_physics_process(false)
	for child in node.get_children():
		freeze(child)

func last_projectile(scene: Node2D) -> Node2D:
	var found: Node2D
	for child in scene.get_children():
		if child is Projectile and not child.is_queued_for_deletion():
			found = child
	return found

func full_charge(actor: PixelActor) -> void:
	actor.reset_transients()
	actor.energy = 100
	check(actor.start_charge(), "charge starts when playable and ready")
	actor.update_charge(1.1)
	check(actor.charge_ready, "full charge is ready")

func run() -> void:
	var scene = load("res://scenes/campaign.tscn").instantiate()
	root.add_child(scene)
	scene._enter(scene.Beat.AMBUSH)
	scene.ui.clear_dialogue()
	freeze(scene)
	var hero = scene.player
	hero.position = Vector2(100, 350)
	hero.facing = Vector2.RIGHT
	scene.raven.position = Vector2(65, 360)
	for i in scene.foes.size():
		scene.foes[i].position = Vector2(190 + 65 * i, 350)
		scene.foes[i].health = 1000
	await physics_frame
	await process_frame
	check(hero.start_charge(), "Shadepi can charge")
	hero.update_charge(1.09)
	check(not hero.charge_ready and scene.effects.charge_rings.is_empty(), "ready pulse never fires early")
	hero.update_charge(0.02)
	check(hero.charge_ready and scene.effects.charge_rings.size() == 1, "ready threshold emits one wave")
	hero.update_charge(10)
	check(scene.effects.charge_rings.size() == 1 and last_projectile(scene) == null, "holding full charge neither repeats pulse nor fires")
	check(not hero.try_attack() and not hero.try_kick() and not hero.try_cloak(), "other attacks and cloak cannot overlap charging")
	check(hero.release_charge() and hero.energy == 70, "release spends charge energy once")
	hero.animate("attack", 0)
	check(hero.visual.frame_coords.x == 2, "charged release shows the actual cut immediately")
	var wave = last_projectile(scene)
	check(wave != null and not wave.ranged, "Shadepi emits a travelling crescent")
	wave.set_physics_process(false)
	wave.advance(0.5)
	check(scene.foes[0].health == 947 and scene.foes[1].health == 947, "swept wave damages both targets once even at large delta")
	wave.advance(0.01)
	check(scene.foes[0].health == 947 and not hero.release_charge(), "no repeated damage or repeated release")
	wave.queue_free()
	# A physical arcade barrier blocks the projectile as well as movement.
	hero.position = Vector2(480, 350)
	scene.foes[0].position = Vector2(550, 350)
	scene.foes[0].health = 1000
	full_charge(hero)
	hero.release_charge()
	wave = last_projectile(scene)
	wave.set_physics_process(false)
	wave.advance(0.4)
	check(wave.is_queued_for_deletion() and wave.position.x <= 510 and scene.foes[0].health == 1000, "charge cannot shoot through a locked arcade exit")
	# Pause, damage, dash, checkpoint reset and low energy.
	hero.position = Vector2(100, 350)
	full_charge(hero)
	scene.menu_open = true
	hero._physics_process(0.01)
	check(not hero.charging and last_projectile(scene) == null, "pause cancels charge without an accidental shot")
	scene.menu_open = false
	full_charge(hero)
	hero.take_damage(1, hero.position - Vector2.RIGHT)
	check(not hero.charging and not hero.release_charge(), "damage interrupts the charged move")
	full_charge(hero)
	check(hero.try_dash(Vector2.RIGHT) and not hero.charging, "dodge cancels a charge")
	hero.reset_transients()
	hero.energy = 29
	check(not hero.start_charge(), "missing energy blocks charging")
	hero.energy = 100
	hero.start_charge()
	hero.update_charge(0.2)
	check(hero.release_charge() and hero.attack_kind == "normal" and hero.energy == 95, "early release performs the normal attack")
	full_charge(hero)
	hero.release_charge()
	wave = last_projectile(scene)
	hero.reset_transients()
	wave._physics_process(0.01)
	check(wave.is_queued_for_deletion(), "checkpoint generation invalidates old projectiles")
	# Kick timing, contact range, interrupt and shield rules.
	hero.position = Vector2(150, 350)
	hero.facing = Vector2.RIGHT
	hero.energy = 100
	scene.foes[0].position = Vector2(185, 350)
	scene.foes[0].health = 1000
	scene.foes[1].position = Vector2(110, 350)
	scene.foes[1].health = 1000
	check(hero.try_kick() and hero.energy == 88, "kick has its own energy cost")
	hero._physics_process(0.1)
	check(scene.foes[0].health == 1000 and hero.visual.frame / 8 == 1, "kick windup shows raised knee before impact")
	hero._physics_process(0.1)
	check(scene.foes[0].health == 980 and scene.foes[0].stun > 0, "extended kick damages and interrupts frontal enemy")
	check(hero.visual.frame / 8 == 2 and scene.foes[1].health == 1000, "extended-leg pose and rear target exclusion")
	hero._physics_process(0.03)
	check(scene.foes[0].health == 980, "kick only applies damage once")
	hero.reset_transients()
	scene.foes[0].position = Vector2(185, 350)
	scene.foes[0].armoured = true
	scene.player_kick(hero)
	check(scene.foes[0].health == 980, "kick respects boss armour")
	for direction in 8:
		hero.facing = Vector2.from_angle(direction * PI / 4)
		hero.animate("charge", 0)
		check(hero.visual.texture == hero.COMBAT_POSES and hero.visual.frame == hero.OCTANT_ROWS[direction], "charge pose direction %d" % direction)
		hero.attack_time = 0.25
		hero.animate("kick", 0)
		check(hero.visual.frame == 16 + hero.OCTANT_ROWS[direction] and hero.cast_shadow.frame == hero.visual.frame, "kick direction and shadow %d" % direction)
	hero.reset_transients()
	check(hero.visual.texture==hero.normal_texture and hero.visual.position == hero.standing_visual_position and hero.visual.texture_filter==CanvasItem.TEXTURE_FILTER_LINEAR, "pose resets to original atlas and foot anchor")
	scene.queue_free()
	await process_frame
	# Raven uses the primary controls during her hunt and her own inputs in co-op.
	var chapter = load("res://scenes/chapter_one.tscn").instantiate()
	root.add_child(chapter)
	chapter._enter_checkpoint(chapter.Phase.HUNT)
	freeze(chapter)
	var raven = chapter.raven
	raven.position = Vector2(-530, 420)
	raven.facing = Vector2.RIGHT
	chapter.patrol[0].position = Vector2(-480, 420)
	chapter.patrol[0].health = 1000
	chapter.patrol[1].position = Vector2(-400, 420)
	chapter.patrol[1].health = 1000
	await physics_frame
	await process_frame
	full_charge(raven)
	raven.animate("charge", 0)
	check(raven.visual.frame == 26, "Raven has her own braced pistol pose facing east")
	check(raven.release_charge() and raven.energy == 75, "charged pistol uses Raven's energy")
	wave = last_projectile(chapter)
	wave.set_physics_process(false)
	wave.advance(0.4)
	check(wave.ranged and chapter.patrol[0].health == 957 and chapter.patrol[1].health == 1000, "charged shot hits only the nearest aligned enemy")
	check(not raven.try_kick(), "Raven does not use Shadepi's kick artwork")
	var devices: Array[int] = [0, 1]
	chapter.gamepads.assign(devices, true)
	for pair in [["charge", 0, JOY_AXIS_TRIGGER_RIGHT], ["kick", 0, JOY_AXIS_TRIGGER_LEFT], ["raven_charge", 1, JOY_AXIS_TRIGGER_RIGHT]]:
		var found := false
		for event in InputMap.action_get_events(pair[0]):
			if event is InputEventJoypadMotion and event.device == pair[1] and event.axis == pair[2]:
				found = true
		check(found, "independent trigger binding: " + pair[0])
	chapter.queue_free()
	await process_frame
	var coop = load("res://scenes/main.tscn").instantiate()
	root.add_child(coop)
	coop.close_menu()
	coop.set_coop(true)
	freeze(coop)
	Input.action_press("raven_charge")
	coop.player._physics_process(0.01)
	coop.raven._physics_process(0.5)
	check(coop.raven.charging and not coop.player.charging, "Raven's held input does not charge Shadepi")
	coop.raven._physics_process(0.61)
	check(coop.raven.charge_ready, "holding input reaches ready state")
	Input.action_release("raven_charge")
	coop.raven._physics_process(0.01)
	check(last_projectile(coop) != null and last_projectile(coop).source == coop.raven, "release input emits Raven's own shot")
	await process_frame
	Input.action_press("charge")
	coop.player._physics_process(0.5)
	check(coop.player.charging, "Shadepi's dedicated input starts charging")
	coop.menu_open = true
	coop.player._physics_process(0.01)
	Input.action_release("charge")
	await process_frame
	coop.menu_open = false
	coop.player._physics_process(0.01)
	check(not coop.player.charging and coop.player.attack_time == 0, "release during pause cannot fire on resume")
	Input.action_press("kick")
	coop.player._physics_process(0.01)
	check(coop.player.attack_kind == "kick" and coop.player.kick_pending, "kick input starts the timed kick")
	Input.action_release("kick")
	coop.player.reset_transients()
	coop.player.energy = 100
	coop.player.start_charge()
	coop.player.update_charge(1.1)
	coop._on_joy_connection_changed(0, false)
	check(not coop.player.charging, "disconnect cancels full charge instead of firing")
	coop.queue_free()
	await process_frame
	# Charged dive shots still respect vulnerability windows and wave handoff.
	var dive = load("res://scenes/chapter_two.tscn").instantiate()
	root.add_child(dive)
	dive._enter(dive.Section.DIVE, 1)
	dive.ui.clear_dialogue()
	freeze(dive)
	var threat = dive.threats[0]
	threat.elapsed = 0
	dive.special_hit(threat, 62, dive.raven, false)
	check(dive.threats.size() == 1, "power shot cannot bypass closed ICE")
	threat.elapsed = 1.4
	dive.special_hit(threat, 62, dive.raven, false)
	check(dive.threats.size() == 2 and dive.next_wave, "vulnerable ICE defeat starts the existing next wave")
	dive.queue_free()
	await process_frame
	print("COMBAT MOVES: %d checks, %d failures" % [checks, failures])
	quit(0 if failures == 0 else 1)
