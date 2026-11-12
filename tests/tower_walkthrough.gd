extends SceneTree
## v0.60.3 · ClaudeHelper (Nutzerbericht): Tower von der Penthouse-Tür bis zum Abflug in echtem
## Ablauf – keine übersprungenen Filme, echte Tasten zum Laufen. Prüft Sichtbarkeit und Steuerung
## der geführten Figur in Flur und Lobby, die vollständige Kenzō-Szene und den Rückweg.
## godot --headless --script res://tests/tower_walkthrough.gd
var checks := 0
var failures := 0

func _initialize() -> void:
	run.call_deferred()

func check(ok: bool, msg: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("FAIL: " + msg)

func release() -> void:
	for a in ["move_left", "move_right", "move_up", "move_down"]: Input.action_release(a)

## Läuft mit echten Tasten auf ein Ziel zu, bis `done` wahr ist. Liefert den zurückgelegten Weg.
func walk(w, actor, target: Callable, done: Callable, seconds: float) -> float:
	var left := seconds
	var from: Vector2 = actor.position
	var path := 0.0
	while left > 0.0 and not done.call():
		var d: Vector2 = target.call() - actor.position
		release()
		if absf(d.x) > 5.0: Input.action_press("move_right" if d.x > 0.0 else "move_left")
		if absf(d.y) > 5.0: Input.action_press("move_down" if d.y > 0.0 else "move_up")
		await physics_frame
		path += actor.position.distance_to(from)
		from = actor.position
		left -= 1.0 / 60.0 if Engine.time_scale <= 1.0 else root.get_physics_process_delta_time()
	release()
	return path

## Lässt Filme in echter Folge laufen und drückt Dialoge weiter. Liefert die Zahl der Zeilen.
func watch(w, seconds: float, until: Callable = Callable()) -> int:
	var lines := 0
	var left := seconds
	var last := ""
	while left > 0.0:
		await process_frame
		left -= root.get_process_delta_time()
		if until.is_valid() and until.call(): break
		if w.in_cinematic():
			if w.cutscene.waiting_input:
				if w.cutscene.line_label.text != last:
					last = w.cutscene.line_label.text
					lines += 1
				w.cutscene.advance()
		elif w.ui.dialogue_open:
			w.ui.advance_dialogue()
		elif not until.is_valid():
			break
	return lines

## Wegziel im Raum: erst auf der Bodenmitte entlang (an Pflanzkübeln vorbei), dann zum Ausgang.
func lane(w, actor) -> Vector2:
	if not w.in_passage(): return actor.position
	var e: Vector2 = w.passage.exit()
	return e if absf(e.x - actor.position.x) < 30.0 else Vector2(e.x, w.passage.point(w.passage.floor_centre()).y)

func solve_roof(w) -> void:
	for point in 2:
		w.clock = 0
		w.raven.position = w._target()
		w.interact()
		check(preload("res://tests/terminal_solver.gd").complete(w), "Raven löst das Dachterminal %d" % (point + 1))

func clear(w) -> void:
	for foe in w.foes:
		if foe.health > 0:
			foe.front_shield = false
			foe.take_damage(1000)

func way_in(w, label: String) -> void:
	w.fresh_entry = false
	w._enter(w.Beat.ROOF)
	await watch(w, 30.0)
	await solve_roof(w)
	await watch(w, 6.0, func(): return w.in_passage() and not w.in_cinematic())
	check(w.in_passage() and w.passage.key == "tower_corridor" and not w.in_cinematic(), label + "nach der Tür steht man spielbar im Flur")
	check(w.raven.visible and w.actor_is_playable(w.raven) and w.passage.contains(w.raven.position), label + "Raven ist im Flur sichtbar und steuerbar")
	check(not w.player.visible and not w.actor_is_playable(w.player), label + "Shadepi bleibt wie auf dem Dach getarnt")
	await process_frame
	check(is_equal_approx(w.camera.zoom.x, 1.25) and w.camera.position.distance_to(w.raven.position) < 60.0, label + "die Kamera liegt im Flur auf Raven")
	var view: Rect2 = Rect2(w.camera.get_screen_center_position() - Vector2(320, 180) / w.camera.zoom.x, Vector2(640, 360) / w.camera.zoom.x)
	check(view.has_point(w.raven.position + Vector2(0, -30)), label + "Raven steht im Bild")
	var start: Vector2 = w.raven.position
	var path: float = await walk(w, w.raven, func(): return lane(w, w.raven), func(): return not w.in_passage() or w.passage.key != "tower_corridor" or w.in_cinematic(), 14.0)
	check(path > 600.0, label + "Raven läuft mit echten Tasten durch den Flur (%d px)" % int(path))
	await watch(w, 6.0, func(): return w.in_passage() and w.passage.key == "tower_lobby" and not w.in_cinematic())
	check(w.in_passage() and w.passage.key == "tower_lobby" and w.raven.visible and w.actor_is_playable(w.raven), label + "in der Lobby bleibt Raven sichtbar und steuerbar")
	check(is_equal_approx(w.camera.zoom.x, 1.25) and w.passage.contains(w.raven.position), label + "die Lobby hat Kamera und Boden des Raums")
	path = await walk(w, w.raven, func(): return lane(w, w.raven), func(): return not w.in_passage() or w.in_cinematic(), 12.0)
	check(path > 300.0, label + "Raven erreicht die Tür zur Suite zu Fuß (%d px)" % int(path))

func run() -> void:
	if not OS.get_user_data_dir().begins_with("/tmp/shadepi-"):
		push_error("Run with an isolated XDG_DATA_HOME=/tmp/shadepi-... directory; real player saves must never be used.")
		quit(1)
		return
	Engine.time_scale = 4.0
	var w = load("res://scenes/campaign.tscn").instantiate()
	root.add_child(w)
	for i in 10: await process_frame
	w.close_menu()

	# Vergleichsmaß: die Kenzō-Szene bei direktem Einstieg in die Suite.
	w.fresh_entry = true
	w._enter(w.Beat.BOSS)
	var reference: int = await watch(w, 120.0)
	check(reference >= 4 and w.beat == w.Beat.BOSS and not w.in_cinematic(), "Vergleich: die Kenzō-Szene hat %d Zeilen" % reference)

	# --- Hinweg in echtem Ablauf --------------------------------------------------------------
	await way_in(w, "")
	var lines: int = await watch(w, 120.0, func(): return w.beat == w.Beat.BOSS and not w.in_cinematic() and not w.ui.dialogue_open)
	check(w.beat == w.Beat.BOSS and not w.in_passage() and not w.passages_active(), "hinter der Lobby beginnt Kenzōs Suite")
	check(lines == reference, "die Kenzō-Szene läuft vollständig (%d von %d Zeilen)" % [lines, reference])
	check(w.player.visible and w.actor_is_playable(w.player) and w.player.position.y < 640.0 and w.player.position.x < 1024.0, "Shadepi ist in der Suite sichtbar und steuerbar")
	check(is_equal_approx(w.camera.zoom.x, 1.0) and w.camera.limit_bottom == 640 and w.camera.limit_top == 0, "die Suite hat wieder Karte und Zoom der Hauptwelt")
	check(w._living() == 1 and w.foes[0].active and w.is_combat(), "Kenzō steht zum Kampf bereit")
	var spot: Vector2 = w.player.position
	var moved: float = await walk(w, w.player, func(): return spot + Vector2(60, 0), func(): return w.player.position.x > spot.x + 30.0, 3.0)
	check(moved > 25.0, "Shadepi bewegt sich in der Suite mit echten Tasten")
	var kenzo = w.foes[0]
	var hp: int = kenzo.health
	w.player.position = kenzo.position + Vector2(-34, 0)
	w.player.facing = Vector2.RIGHT
	for i in 5:
		Input.action_press("attack"); await physics_frame; await physics_frame
		Input.action_release("attack")
		for k in 24: await physics_frame
	check(kenzo.health < hp, "Shadepis Angriff trifft Kenzō")

	# --- Rückweg in echtem Ablauf -------------------------------------------------------------
	w.fresh_entry = false
	w._enter(w.Beat.ESCAPE, 0, 3)
	await watch(w, 30.0)
	check(w.tower_stage == 2 and w.player.visible and w.actor_is_playable(w.player), "vor dem Dachausgang ist Shadepi spielbar")
	await walk(w, w.player, func(): return w._target(), func(): return w.player.position.distance_to(w._target()) < 30.0, 12.0)
	w.interact()
	await watch(w, 6.0, func(): return w.in_passage() and not w.in_cinematic())
	check(w.in_passage() and w.passage.key == "tower_lobby" and w.passage.route == "out" and not w.in_cinematic(), "der Rückweg beginnt spielbar in der Lobby")
	check(w.player.visible and w.raven.visible and w.actor_is_playable(w.player) and w.passage.contains(w.player.position) and w.passage.contains(w.raven.position), "beide Helden stehen sichtbar in der Lobby")
	check(w._living() == 3 and w.is_combat(), "drei Wachen greifen in der Lobby an")
	var guard = w.passage_foes[0]
	var gap: float = guard.position.distance_to(w.player.position)
	for i in 240: await physics_frame
	check(guard.position.distance_to(w.player.position) < gap - 20.0 or w.player.health < 100, "die Wachen rücken wirklich vor")
	w.player.health = 100
	clear(w)
	await watch(w, 2.0, func(): return not w.passage.locked)
	var path: float = await walk(w, w.player, func(): return lane(w, w.player), func(): return not w.in_passage() or w.passage.key != "tower_lobby" or w.in_cinematic(), 14.0)
	check(path > 250.0, "Shadepi läuft durch die Lobby zum Flur (%d px)" % int(path))
	await watch(w, 6.0, func(): return w.in_passage() and w.passage.key == "tower_corridor" and not w.in_cinematic())
	check(w.in_passage() and w.passage.key == "tower_corridor" and w.player.visible and w.actor_is_playable(w.player) and w._living() == 3, "im Flur warten drei Wachen, Shadepi bleibt steuerbar")
	clear(w)
	await watch(w, 2.0, func(): return not w.passage.locked)
	path = await walk(w, w.player, func(): return lane(w, w.player), func(): return not w.in_passage() or w.in_cinematic(), 16.0)
	check(path > 600.0, "Shadepi läuft durch den Flur zum Landeplatz (%d px)" % int(path))
	await watch(w, 8.0, func(): return is_instance_valid(w.tower_departure))
	check(is_instance_valid(w.tower_departure) and not w.in_passage() and w.tower_stage == 3, "nach dem Flur startet der Abflug")
	check(w.camera.limit_bottom == 640 and w.camera.limit_top == 0 and is_equal_approx(w.camera.zoom.x, 1.0), "der Abflug läuft mit der Kamera der Hauptwelt")
	await watch(w, 90.0, func(): return w.beat == w.Beat.LAKE)
	check(w.beat == w.Beat.LAKE, "der Abflug endet am See")

	# --- Koop: Hinweg mit zwei Spielern -------------------------------------------------------
	w.set_coop(true)
	await way_in(w, "Koop · ")
	await watch(w, 120.0, func(): return w.beat == w.Beat.BOSS and not w.in_cinematic() and not w.ui.dialogue_open)
	check(w.beat == w.Beat.BOSS and w.player.visible and w.actor_is_playable(w.player) and w._living() == 1, "Koop · die Suite beginnt mit sichtbarem Shadepi und Kenzō")
	Engine.time_scale = 1.0
	print("TOWER WALKTHROUGH: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
