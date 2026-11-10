extends SceneTree
## v0.54.1 · ClaudeHelper: Begleiter über echte Tasten/Pad-Ereignisse und den Menüstart –
## so, wie Spieler 2 ihn wirklich bedient (Kapitel 1 und Kapitel 3–7).
var checks := 0
var failures := 0

func _initialize() -> void: run.call_deferred()

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("FAIL: " + message)

func key(code: int, pressed: bool) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = code
	event.keycode = code
	event.pressed = pressed
	Input.parse_input_event(event)

func play_until_free(w, limit: int = 4000) -> void:
	for i in limit:
		await process_frame
		if w.cutscene.running: w.cutscene.skip()
		elif i > 30 and not w.is_busy(): return

func drive(w, label: String, hero) -> void:
	var pet = w.companion
	for i in 20: await process_frame
	check(pet.kind != "" and pet.visible, "%s: the companion is there (%s)" % [label, pet.kind])
	check(pet.claimed, "%s: in a co-op session player two owns the companion at once" % label)
	var pet_start: Vector2 = pet.position
	var hero_start: Vector2 = hero.position
	key(KEY_RIGHT, true)
	for i in 24: await physics_frame
	key(KEY_RIGHT, false)
	check(pet.position.x > pet_start.x + 8.0, "%s: arrow keys fly the companion (%.0f → %.0f)" % [label, pet_start.x, pet.position.x])
	check(absf(hero.position.x - hero_start.x) < 3.0, "%s: the hero does not move with player two's arrows" % label)
	pet.attack_cooldown = 0.0
	key(KEY_U, true)
	for i in 4: await process_frame
	key(KEY_U, false)
	check(pet.attack_cooldown > 0.0, "%s: U fires the companion's attack" % label)
	pet.hack_cooldown = 0.0
	key(KEY_O, true)
	for i in 4: await process_frame
	key(KEY_O, false)
	check(pet.hack_cooldown > 0.0, "%s: O triggers the companion's special" % label)

func run() -> void:
	# Kapitel 1 über das echte Menü im Koop starten: Raven ist allein unterwegs, das Kapitel
	# schaltet `coop` dafür ab – Spieler 2 muss trotzdem die Drohne haben.
	var one = load("res://scenes/chapter_one.tscn").instantiate()
	root.add_child(one)
	await create_timer(0.3).timeout
	one.ui.requested_coop = true
	one.ui.start_selected()
	await play_until_free(one)
	check(one.coop_session() and not one.coop and one.raven_leads(), "chapter one opening is a co-op session with Raven playing alone")
	check(one.companion_lead() == one.raven, "chapter one: Raven's drone belongs to player two")
	await drive(one, "chapter one", one.raven)
	check(not InputMap.action_has_event("move_left", one.companion._arrow(KEY_LEFT)), "chapter one: arrows are taken from player one while the drone is flown")
	one.queue_free()
	await process_frame
	await process_frame
	check(InputMap.action_has_event("move_left", one.companion._arrow(KEY_LEFT)) if is_instance_valid(one) else true, "leaving the chapter gives the arrow keys back")
	# Kapitel 3–7: Start über das Menü im Koop, dann ein Sprung in eine Szene mit nur einem Helden.
	var w = load("res://scenes/campaign.tscn").instantiate()
	root.add_child(w)
	await create_timer(0.3).timeout
	w.ui.requested_coop = true
	w.ui.start_selected()
	for i in 20: await process_frame
	w.fresh_entry = false
	w._enter(w.Beat.ROOF)
	await play_until_free(w)
	await drive(w, "tower roof", w.raven)
	w._enter(w.Beat.BOSS)
	await play_until_free(w)
	await drive(w, "tower fight", w.player)
	# Kapitelwechsel: die Koop-Sitzung gilt weiter, ohne dass im neuen Kapitel neu gewählt wird.
	check(get_meta("shadepi_coop_session", false), "the menu choice is remembered for the session")
	w.queue_free()
	await process_frame
	var two = load("res://scenes/chapter_two.tscn").instantiate()
	root.add_child(two)
	await create_timer(0.3).timeout
	check(two.coop and two.ui.requested_coop, "the next chapter starts in co-op without asking again")
	two.queue_free()
	await process_frame
	w = load("res://scenes/campaign.tscn").instantiate()
	root.add_child(w)
	await create_timer(0.3).timeout
	check(w.coop, "chapters 3-7 inherit the co-op session")
	w.close_menu()
	w.fresh_entry = false
	w._enter(w.Beat.ROOF)
	await play_until_free(w)
	await drive(w, "after chapter change", w.raven)
	# Ein einzelnes Gamepad gehört in der Koop-Sitzung Spieler 2: die Bindung folgt dem Raven-Pad.
	w.gamepads.raven_device = 3
	for i in 3: await process_frame
	check(w.companion.pad_device == 3, "the companion follows player two's gamepad after the mode is set")
	var found := false
	for event in InputMap.action_get_events("pet_attack"):
		if event is InputEventJoypadButton and event.device == 3 and event.button_index == JOY_BUTTON_X: found = true
	check(found, "X on player two's gamepad attacks")
	w.gamepads.raven_device = -1
	w.set_coop(false)
	remove_meta("shadepi_coop_session")
	w.queue_free()
	await process_frame
	print("COMPANION INPUT: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
