extends SceneTree
## v0.55.0 · ClaudeHelper: Koop-Prüfung für jeden Abschnitt aller Kapitel.
## Startet jeden Abschnitt in einer Koop-Sitzung, wartet bis frei gespielt wird und drückt
## echte Tasten: D bewegt die Figur von Spieler 1, Pfeil rechts die von Spieler 2
## (Raven oder Begleiter). Meldet jeden Abschnitt, in dem Spieler 2 nichts steuert.
## Dazu: Sozius-Steuerung in Verfolgung und Flug und das umgebaute Menü (Hauptmenü ↔ Kapitel).
## godot --headless --script res://tests/coop_chapters.gd
var rows: Array[String] = []
var faults := 0
var checks := 0
var failures := 0

func check(ok: bool, msg: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("FAIL: " + msg)

func frames(n: int) -> void:
	for i in n: await process_frame

func visible_texts(ui) -> Array:
	var out := []
	for b in ui.menu_buttons:
		if b.visible: out.append(b.text)
	return out

func pause(w) -> void:
	w.menu_open = true
	w.ui.show_menu()
	await frames(2)

func until_drive(w) -> void:
	for i in 1500:
		await process_frame
		if w.cutscene.running: w.cutscene.skip()
		elif w.ui.dialogue_open: w.ui.advance_dialogue()
		elif w.drive != null and i > 40: return

func _initialize() -> void: run.call_deferred()

func key(code: int, pressed: bool) -> void:
	var e := InputEventKey.new(); e.physical_keycode = code; e.keycode = code; e.pressed = pressed
	Input.parse_input_event(e)

func free_play(w, limit: int = 2500) -> bool:
	for i in limit:
		await process_frame
		if w.cutscene.running: w.cutscene.skip()
		elif i > 40 and not w.is_busy(): return true
	return false

func probe(w, label: String) -> void:
	var free: bool = await free_play(w)
	for i in 25: await process_frame
	if not free or w.is_busy():
		rows.append("%-28s  – (Filmszene / kein freies Spiel)" % label)
		return
	var pet = w.companion
	var both: bool = w.actor_is_playable(w.player) and w.actor_is_playable(w.raven)
	var lead = w.raven if (w.actor_is_playable(w.raven) and not w.actor_is_playable(w.player)) else w.player
	var two_node = w.raven if both else (pet if pet.kind != "" and pet.visible else null)
	var role := "Raven" if both else ("Drohne" if pet.kind == "drone" else ("Naniten" if pet.kind == "nanites" else "NICHTS"))
	if not w.actor_is_playable(w.player) and not w.actor_is_playable(w.raven):
		rows.append("%-28s  – (keine Figur spielbar: Fahrt, Flug, Minispiel)" % label)
		return
	var a0: Vector2 = lead.position
	var b0: Vector2 = two_node.position if two_node != null else Vector2.ZERO
	key(KEY_D, true); key(KEY_RIGHT, true)
	for i in 24: await physics_frame
	key(KEY_D, false); key(KEY_RIGHT, false)
	var one_moves: bool = lead.position.x > a0.x + 4.0
	var two_moves: bool = two_node != null and two_node.position.x > b0.x + 4.0
	var ok := two_node != null and two_moves
	check(ok, label + ": Spieler 2 steuert " + role)
	check(one_moves, label + ": Spieler 1 bewegt seine Figur")
	if not ok: faults += 1
	rows.append("%-28s  S1 %-7s %s   S2 %-7s %s%s" % [label, "Raven" if lead == w.raven else "Shadepi", "bewegt" if one_moves else "(blockiert)", role, "bewegt" if two_moves else "BEWEGT SICH NICHT", "" if ok else "   <<< FEHLER"])
	for i in 6: await process_frame

func run() -> void:
	if not OS.get_user_data_dir().begins_with("/tmp/shadepi-"):
		push_error("Run with an isolated XDG_DATA_HOME=/tmp/shadepi-... directory; real player saves must never be used.")
		quit(1)
		return
	set_meta("shadepi_coop_session", true)
	var one = load("res://scenes/chapter_one.tscn").instantiate()
	root.add_child(one)
	await create_timer(0.3).timeout
	one.chapter_coop = true
	one.close_menu()
	for phase in [0, 1, 4, 6]:
		one._enter_checkpoint(phase)
		await probe(one, "Kapitel 1 · " + one.Phase.keys()[phase])
	one.queue_free(); await process_frame
	var two = load("res://scenes/chapter_two.tscn").instantiate()
	root.add_child(two)
	await create_timer(0.3).timeout
	two.close_menu()
	for section in [0, 1, 2, 5, 3]:
		two._enter(section)
		await probe(two, "Kapitel 2 · " + two.Section.keys()[section])
	two.queue_free(); await process_frame
	var w = load("res://scenes/campaign.tscn").instantiate()
	root.add_child(w)
	await create_timer(0.3).timeout
	w.close_menu()
	for name: String in w.Beat.keys():
		w.fresh_entry = false
		w._enter(w.Beat[name])
		await probe(w, "Kapitel 3–7 · " + name)
	for row in rows: print("COOP ", row)
	check(rows.size() == 21 and faults == 0, "alle 21 Abschnitte geprüft, Spieler 2 hat überall eine Rolle")

	# v0.57.1 · ClaudeHelper (Nutzerbericht): Ravens Schüsse treffen die Gegner der Kampagne.
	w.fresh_entry = false
	w._enter(w.Beat.AMBUSH)
	for i in 80:
		await create_timer(0.05).timeout
		if w.cutscene.running: w.cutscene.skip()
		elif w.ui.dialogue_open: w.ui.advance_dialogue()
		elif not w.foes.is_empty() and w.coop_raven_playable() and not w.is_busy(): break
	check(not w.foes.is_empty() and w.coop_raven_playable(), "Hinterhalt: Spieler 2 spielt Raven gegen echte Gegner")
	if not w.foes.is_empty():
		var foe = w.foes[0]
		for side in [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]:
			w.raven.position = foe.position + side * 70.0
			w.raven.facing = -side
			if w._line_clear(w.raven.position, foe.position): break
		var life: int = foe.health
		w.raven.attack_cooldown = 0.0
		w.raven.energy = 100.0
		var aim: Vector2 = w.raven.facing
		key(KEY_U, true)
		for i in 4: await physics_frame
		key(KEY_U, false)
		for i in 2: await physics_frame
		check(foe.health < life, "Ravens Schuss (U) trifft den Gegner im Hinterhalt")
		w.raven.facing = -aim
		w.raven.position = foe.position + aim * -70.0
		life = foe.health
		w.raven_shot()
		check(foe.health == life, "ein Schuss in die Gegenrichtung trifft nicht")
		# Zwei gespielte Helden bleiben zusammen im Bild …
		w.raven.position = w.player.position + Vector2(w.COOP_REACH.x, 0)
		check(is_zero_approx(w.limit_coop_motion(w.raven, Vector2(110, 0), 0.016).x), "zwei gespielte Helden hält die Koop-Leine zusammen")
	# … aber eine allein geführte Figur hängt nicht am unsichtbaren Partner (Halle: unsichtbare Wand).
	w.fresh_entry = false
	w._enter(w.Beat.HANGAR)
	for i in 60:
		await create_timer(0.05).timeout
		if w.cutscene.running: w.cutscene.skip()
		elif w.ui.dialogue_open: w.ui.advance_dialogue()
		elif i > 12 and not w.is_busy(): break
	w.raven.position = Vector2(566, 343)
	w.player.position = w.raven.position - Vector2(w.COOP_REACH.x, 0)
	check(w.coop and w.raven_leads() and w.limit_coop_motion(w.raven, Vector2(110, 0), 0.016) == Vector2(110, 0), "Halle: Raven läuft frei, obwohl Shadepi weit links wartet")
	var before_x: float = w.raven.position.x
	key(KEY_D, true)
	await create_timer(0.5).timeout
	key(KEY_D, false)
	check(w.raven.position.x > before_x + 30.0, "Halle: D bewegt Raven über die frühere Grenze nach rechts")
	await process_frame
	check(not w.ui.raven_vitals.visible, "führt Raven allein, zeigt die Anzeige keine zweite Raven-Zeile")
	var bike: Image = load("res://assets/world/hq/bike-parked.png").get_image()
	var holes := 0
	for y in range(100, 240):
		if bike.get_pixel(113, y).a < 0.99 or bike.get_pixel(70, y).a < 0.5 or bike.get_pixel(156, y).a < 0.5: holes += 1
	check(holes == 0, "das geparkte Motorrad hat in der Mitte keine Lücke")

	# Verfolgung: Raven (Spieler 2) schießt und hackt vom Sozius – U und O sind ihre Tasten.
	w.fresh_entry = false
	w._enter(w.Beat.CHASE)
	await until_drive(w)
	check(w.drive != null and w.coop, "Verfolgung läuft in der Koop-Sitzung")
	if w.drive != null:
		key(KEY_U, true); await frames(2)
		check(w.drive._crew("attack", true), "Spieler 2 feuert in der Verfolgung mit U")
		key(KEY_U, false); await frames(2)
		key(KEY_O, true); await process_frame
		check(w.drive._crew("hack"), "Spieler 2 löst den Hack in der Verfolgung mit O aus")
		key(KEY_O, false); await frames(2)
		w.set_coop(false)
		key(KEY_O, true); await process_frame
		check(not w.drive._crew("hack"), "im Einzelspieler bleiben Ravens Tasten in der Verfolgung ohne Wirkung")
		key(KEY_O, false); await frames(2)
		w.set_coop(true)
	# Flug: Raven gibt als Kopilotin den Kalibriercode ein und öffnet das Wartungsdeck.
	w.fresh_entry = false
	w._enter(w.Beat.FLIGHT)
	await until_drive(w)
	var flight = w.drive
	check(flight != null and flight.has_method("_crew_pressed"), "Flug stellt die Kopiloten-Eingabe bereit")
	if flight != null and flight.has_method("_crew_pressed"):
		key(KEY_RIGHT, true); await process_frame
		check(flight._crew_pressed("move_right"), "Spieler 2 gibt Kalibrierrichtungen mit den Pfeiltasten ein")
		key(KEY_RIGHT, false); await frames(2)
		key(KEY_U, true); await process_frame
		check(flight._crew_pressed("attack"), "Spieler 2 öffnet das Wartungsdeck mit U")
		key(KEY_U, false); await frames(2)
	w.queue_free(); await frames(2)

	# Menü: Pause in jedem Kapitel führt ins Hauptmenü, das Hauptmenü wählt Modus und Kapitel.
	set_meta("shadepi_admin_testing", true)
	for scene in ["res://scenes/chapter_two.tscn", "res://scenes/campaign.tscn"]:
		set_meta("shadepi_coop_session", true)
		change_scene_to_file(scene)
		await frames(8)
		var c = current_scene
		check(c.scene_file_path == scene and c.started and c.coop, scene.get_file() + " startet direkt und im Koop")
		await pause(c)
		var texts := visible_texts(c.ui)
		check("Zurück ins Hauptmenü" in texts and not "Zurück zu Kapitel 1" in texts, scene.get_file() + ": Pause bietet das Hauptmenü, nicht mehr Kapitel 1")
		check(not c.ui.mode_button.visible and "Fortsetzen" in texts and "Zurück zum Desktop" in texts, scene.get_file() + ": Pause ohne Moduswechsel, mit Fortsetzen und Desktop")
		check(c.ui.menu.get_global_rect().encloses(c.ui.quit_button.get_global_rect()) and root.get_visible_rect().encloses(c.ui.menu.get_global_rect()), scene.get_file() + ": Pausenmenü passt ins Bild")
		c.ui.main_menu_button.pressed.emit()
		await frames(8)
		var m = current_scene
		check(m.scene_file_path == "res://scenes/chapter_one.tscn" and not m.started and m.ui.start_backdrop.visible, "Hauptmenü geöffnet")
		check(m.ui.requested_coop and m.ui.mode_button.visible and m.ui.mode_button.text.contains("Koop"), "Hauptmenü merkt sich den Koop-Modus")
		check(not m.ui.main_menu_button.visible and not m.ui.restart_button.visible, "Hauptmenü ohne Rückweg zu sich selbst")
		m.admin_flags["unlock_all"] = true
		m.ui._update_mode_buttons()
		await frames(2)
		check(m.ui.next_chapter_button.visible and m.ui.campaign_button.visible, "Hauptmenü bietet Kapitel 2 und Kapitel 3–7 an")
		check(m.ui.menu.get_global_rect().encloses(m.ui.quit_button.get_global_rect()) and root.get_visible_rect().encloses(m.ui.menu.get_global_rect()), "Hauptmenü mit Kapitelwahl passt ins Bild")
		(m.ui.campaign_button if scene.ends_with("campaign.tscn") else m.ui.next_chapter_button).pressed.emit()
		await frames(8)
		c = current_scene
		check(c.scene_file_path == scene and c.started and c.coop, scene.get_file() + ": aus dem Hauptmenü wieder direkt im Koop")
	# Kapitel 1 selbst: Pause → Hauptmenü, Wechsel zu Einzelspieler gilt danach auch in Kapitel 3–7.
	change_scene_to_file("res://scenes/chapter_one.tscn")
	await frames(8)
	var first = current_scene
	first.ui.resume_button.pressed.emit()
	await frames(4)
	check(first.started and first.chapter_coop, "Kapitel 1 startet aus dem Hauptmenü im gemerkten Koop")
	await pause(first)
	check(first.ui.main_menu_button.visible and not first.ui.mode_button.visible and not first.ui.next_chapter_button.visible and not first.ui.campaign_button.visible, "Kapitel-1-Pause: Hauptmenü statt Modus- und Kapitelknöpfen")
	first.ui.main_menu_button.pressed.emit()
	await frames(8)
	var menu = current_scene
	check(menu != first and not menu.started and menu.ui.requested_coop, "Kapitel 1 kehrt ins Hauptmenü zurück")
	menu.ui.mode_button.pressed.emit()
	menu.admin_flags["unlock_all"] = true
	menu.ui._update_mode_buttons()
	menu.ui.campaign_button.pressed.emit()
	await frames(8)
	check(current_scene.scene_file_path.ends_with("campaign.tscn") and not current_scene.coop and not get_meta("shadepi_coop_session", true), "im Hauptmenü gewählter Einzelspieler gilt im geöffneten Kapitel")
	print("COOP CHAPTERS: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
