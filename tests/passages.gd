extends SceneTree
## v0.60.0 · ClaudeHelper: Durchgangsräume aus den gelieferten Kulissen – Gasse hinter Ravens
## Wohnung, Tower-Flur und Lobby (Hin- und Rückweg), zwei Netz-Ebenen im Deep Dive.
## godot --headless --script res://tests/passages.gd
const Room = preload("res://scripts/passage_room.gd")
var checks := 0
var failures := 0

func _initialize() -> void:
	run.call_deferred()

func check(ok: bool, msg: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("FAIL: " + msg)

func frames(n: int) -> void:
	for i in n: await process_frame

## Filme überspringen, Dialoge weiterdrücken, bis die Szene wieder spielbar ist.
func settle(w) -> void:
	for i in 60:
		await process_frame
		if w.in_cinematic(): w.cutscene.skip()
		elif w.ui.dialogue_open: w.ui.advance_dialogue()
		elif i > 4: return

func clear(w) -> void:
	for foe in w.foes:
		if foe.health > 0:
			foe.front_shield = false
			foe.take_damage(1000)

func run() -> void:
	if not OS.get_user_data_dir().begins_with("/tmp/shadepi-"):
		push_error("Run with an isolated XDG_DATA_HOME=/tmp/shadepi-... directory; real player saves must never be used.")
		quit(1)
		return
	for key: String in Room.ROOMS:
		var config: Dictionary = Room.ROOMS[key]
		var floor := PackedVector2Array(config.floor)
		var inside := true
		for route: Array in config.routes.values():
			for p: Vector2 in route:
				if not Geometry2D.is_point_in_polygon(p, floor): inside = false
		check(inside, "%s: Ein- und Ausgänge liegen auf dem Boden" % key)
		var art: Texture2D = config.art
		check(absf(art.get_width() / float(art.get_height()) - config.size.x / config.size.y) < 0.02, "%s: Kulisse wird unverzerrt gezeichnet" % key)
		for box: Rect2 in config.solids:
			for route: Array in config.routes.values():
				check(not box.grow(8.0).has_point(route[0]) and not box.grow(8.0).has_point(route[1]), "%s: kein Hindernis auf Ein- oder Ausgang" % key)

	# --- Kapitel 1: Gasse zwischen Wohnung und Straße -----------------------------------------
	var one = load("res://scenes/chapter_one.tscn").instantiate()
	root.add_child(one)
	await frames(10)
	one.new_game(false)
	one.cutscene.skip()
	await settle(one)
	check(one.in_backalley() and one.phase == one.Phase.APARTMENT and one.actor_is_playable(one.raven), "Raven steht nach der Wohnung spielbar in der Gasse")
	check(one.backalley.locked and one.backalley_punk.visible and one.backalley_punk.health > 0, "der Punk steht an der Seite, der Weg ist noch nicht frei")
	check(one.camera.zoom.x == 1.0 and one.camera.limit_top == int(Room.ORIGIN.y) and one.camera.limit_right - one.camera.limit_left == 640, "die Gasse füllt genau einen Bildschirm")
	# Wand: nach oben gegen die Rückwand laufen.
	one.raven.position = one.backalley.point(Vector2(320, 246))
	Input.action_press("move_up")
	for i in 30: await physics_frame
	Input.action_release("move_up")
	check(one.raven.position.y >= one.backalley.point(Vector2(0, 236)).y, "die Rückwand der Gasse hält Raven auf dem Boden")
	one.raven.position = one.backalley.exit()
	await frames(4)
	check(one.in_backalley() and not one.in_cinematic(), "vor der Begegnung führt der Ausgang nirgendwohin")
	one.raven.position = one.backalley_punk.position + Vector2(-60, 6)
	await frames(4)
	check(one.backalley_met and one.in_cinematic(), "der Punk spricht Raven an, sobald sie vorbeikommt")
	var said := ""
	for i in 40:
		await process_frame
		if not one.in_cinematic(): break
		said += one.cutscene.line_label.text + " "
		if one.cutscene.waiting_input: one.cutscene.advance()
		else: one.cutscene.skip()
	check(one.backalley_punk.health == 0 and absf(one.backalley_punk.visual.rotation - PI * 0.5) < 0.01, "Ravens Hack legt den Punk um")
	check(not one.backalley.locked, "danach ist der Weg zur Straße frei")
	one.raven.position = one.backalley.exit()
	await frames(4)
	await settle(one)
	check(not one.in_backalley() and one.phase == one.Phase.HUNT and one.encounter != null, "aus der Gasse geht es auf die Straße zur Jagd")
	check(one.camera.limit_bottom == 640 and one.camera.limit_left == one.WEST_EDGE and one.raven.position.y < 640.0, "die Straßenkamera ist wiederhergestellt")
	one._enter_checkpoint(one.Phase.APARTMENT)
	one.cutscene.skip()
	await settle(one)
	one._enter_checkpoint(one.Phase.HUNT)
	check(not one.in_backalley() and not is_instance_valid(one.backalley_punk) or one.backalley_punk.is_queued_for_deletion(), "ein Kontrollpunktsprung räumt die Gasse ab")
	one.queue_free()
	await frames(3)

	# --- Kampagne: Hinweg durch Flur und Lobby -----------------------------------------------
	var w = load("res://scenes/campaign.tscn").instantiate()
	root.add_child(w)
	await frames(10)
	w.close_menu()
	w.fresh_entry = false
	w._enter(w.Beat.ROOF)
	await settle(w)
	w.point_index = 1
	w._complete_point()
	await settle(w)
	check(w.beat == w.Beat.ROOF and w.in_passage() and w.passage.key == "tower_corridor", "nach der Penthouse-Tür folgt der Flur")
	check(not w.is_combat() and w._living() == 0 and not w.passage.locked, "auf dem Hinweg stehen keine Wachen im Flur")
	check(w.chapter_objective().contains("Penthouse") and w._target() == w.passage.exit(), "Ziel und Wegmarke zeigen zum Penthouse")
	var lead = w._passage_lead()
	check(lead.position.distance_to(w.passage.entry()) < 40.0 and w.passage.contains(lead.position), "die Figur betritt den Flur an der linken Tür")
	lead.position = w.passage.point(Vector2(500, 152))
	Input.action_press("move_up")
	for i in 30: await physics_frame
	Input.action_release("move_up")
	check(lead.position.y >= w.passage.point(Vector2(0, 146)).y, "die Flurwand hält die Figur auf dem Boden")
	lead.position = w.passage.exit()
	await frames(4)
	await settle(w)
	check(w.in_passage() and w.passage.key == "tower_lobby", "vom Flur geht es in die Lobby")
	w._passage_lead().position = w.passage.exit()
	await frames(4)
	await settle(w)
	await settle(w)
	check(not w.in_passage() and w.beat == w.Beat.BOSS and w._living() == 1, "die Tür in der Lobby führt zu Kenzō")
	check(w.camera.limit_bottom == 640 and w.camera.zoom.x == 1.0 and w.player.position.y < 640.0, "nach den Durchgängen gelten wieder Karte und Kamera der Suite")

	# --- Kampagne: Rückweg mit Wachen ---------------------------------------------------------
	w.fresh_entry = false
	w._enter(w.Beat.ESCAPE, 0, 3)
	await settle(w)
	var suite_spot: Vector2 = w.player.position
	w._complete_point()
	await settle(w)
	check(w.in_passage() and w.passage.key == "tower_lobby" and w.passage.route == "out", "der Rückweg beginnt in der Lobby")
	check(w._living() == 3 and w.passage.locked and w.is_combat(), "drei Wachen versperren die Lobby")
	check(not is_instance_valid(w.tower_departure) and w.tower_stage == 2, "der Abflug wartet, bis der Weg frei ist")
	var left: float = w.countdown
	await frames(20)
	check(w.countdown == left, "der Countdown ruht während der Kämpfe im Flur")
	w.player.position = w.passage.exit()
	await frames(4)
	check(w.passage.key == "tower_lobby" and not w.in_cinematic(), "solange Wachen leben, bleibt der Ausgang zu")
	clear(w)
	await frames(4)
	check(not w.passage.locked and w._target() == w.passage.exit(), "nach dem Kampf ist die Lobby frei")
	w.player.position = w.passage.exit()
	await frames(4)
	await settle(w)
	check(w.in_passage() and w.passage.key == "tower_corridor" and w._living() == 3 and w.passage.locked, "im Flur warten drei weitere Wachen")
	var shield := 0
	for foe in w.passage_foes:
		if foe.front_shield: shield += 1
	check(shield == 1, "eine der Flurwachen trägt den Schild")
	w.player_defeated()
	await frames(4)
	await settle(w)
	check(not w.in_passage() and w.beat == w.Beat.ESCAPE and w.camera.limit_bottom == 640 and w.passage_foes.is_empty(), "ein Sturz im Flur führt sauber zum Kontrollpunkt zurück")
	w._enter(w.Beat.ESCAPE, 0, 3)
	await settle(w)
	w._complete_point()
	await settle(w)
	clear(w); await frames(4)
	w.player.position = w.passage.exit(); await frames(4); await settle(w)
	clear(w); await frames(4)
	w.player.position = w.passage.exit(); await frames(4)
	for i in 30:
		await process_frame
		if is_instance_valid(w.tower_departure): break
		if w.in_cinematic(): w.cutscene.skip()
	check(not w.in_passage() and w.tower_stage == 3 and is_instance_valid(w.tower_departure), "nach dem Flur startet der Abflug")
	check(w.player.position.distance_to(suite_spot) < 400.0 and w.player.position.y < 640.0, "die Helden stehen für den Abflug wieder auf der Karte")
	w.queue_free()
	await frames(3)

	# --- Kapitel 2: zwei Netz-Ebenen ----------------------------------------------------------
	var two = load("res://scenes/chapter_two.tscn").instantiate()
	root.add_child(two)
	await frames(10)
	two._enter(two.Section.DIVE)
	await settle(two)
	two.raven.position = two.RELAYS[0]
	two.ice_cycle = 1.2
	two.interact()
	await settle(two)
	check(two.in_net_layer() and two.net_layer.key == "dive_archive" and two.relay_index == 0, "nach dem ersten Relais öffnet sich das Datenarchiv")
	check(two.threats.size() == 2 and two.net_layer.locked and two.chapter_objective().contains("Netz-Ebene 2"), "zwei ICE-Programme bewachen die Ebene")
	two.raven.position = two.net_layer.exit()
	await frames(4)
	check(two.in_net_layer() and not two.in_cinematic(), "das Portal bleibt zu, solange ICE aktiv ist")
	for threat in two.threats.duplicate(): two._destroy_threat(threat)
	check(two.threats.size() == 3 and two.net_layer.locked, "die zweite Welle folgt sofort")
	for threat in two.threats.duplicate(): two._destroy_threat(threat)
	check(two.threats.is_empty() and not two.net_layer.locked and two._target() == two.net_layer.exit(), "ist alles gelöscht, öffnet sich das Portal")
	two.raven.position = two.net_layer.exit()
	await frames(4)
	await settle(two)
	check(not two.in_net_layer() and two.relay_index == 1 and two.threats.size() == 1, "zurück auf der Datenspur läuft das zweite Relais wie bisher")
	check(two.raven.position.distance_to(two.RELAYS[0]) < 4.0 and two.camera.limit_bottom == 640, "Raven steht wieder am Relais, die Kamera der Hauptebene gilt")
	for threat in two.threats.duplicate(): two._destroy_threat(threat)
	for threat in two.threats.duplicate(): two._destroy_threat(threat)
	two.raven.position = two.RELAYS[1]
	two.ice_cycle = 0.2
	two.interact()
	await settle(two)
	check(two.in_net_layer() and two.net_layer.key == "dive_core" and two.threats.size() == 3, "nach dem zweiten Relais folgt der rote Kern")
	two.raven.take_damage(1000, two.raven.position)
	await frames(6)
	await settle(two)
	check(not two.in_net_layer() and two.relay_index == 1 and two.camera.limit_bottom == 640, "ein Absturz im Kern setzt am zweiten Relais neu an")
	two.raven.position = two.RELAYS[1]
	for threat in two.threats.duplicate(): two._destroy_threat(threat)
	for threat in two.threats.duplicate(): two._destroy_threat(threat)
	two.ice_cycle = 0.2
	two.interact()
	two.skip_net_layer()
	check(two.relay_index == 2 and two.ice_guardian() != null, "nach dem Kern wartet der Wächter wie bisher")
	print("PASSAGES: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
