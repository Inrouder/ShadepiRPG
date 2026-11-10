extends SceneTree
## v0.53.0 · ClaudeHelper: Begleiter für Spieler 2 – Ravens Drohne und Shadepis Nanitenschwarm.
var checks := 0
var failures := 0

func _initialize() -> void: run.call_deferred()

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("FAIL: " + message)

func settle(w, frames: int = 40) -> void:
	for i in frames:
		await process_frame
		if w.cutscene.running: w.cutscene.skip()

func run() -> void:
	var drone: Image = load("res://assets/sprites/companions/drone.png").get_image()
	var motes: Image = load("res://assets/sprites/companions/nanites.png").get_image()
	check(drone.get_size() == Vector2i(112, 44) and motes.get_size() == Vector2i(56, 14), "companion sheets keep their frame grids")
	check(drone.get_pixel(0, 0).a == 0.0 and motes.get_pixel(0, 0).a == 0.0, "companion sheets are transparent pixel art")
	var white := motes.get_pixel(3, 3)
	var red := motes.get_pixel(3, 10)
	check(white.r > 0.9 and white.g > 0.9 and white.b > 0.9 and red.r > 0.9 and red.g < 0.95 and red.b < 0.9, "nanites glow white when calm and red when attacking")
	var w = load("res://scenes/campaign.tscn").instantiate()
	root.add_child(w)
	await process_frame
	w.close_menu(); w.started = true
	var pet = w.companion
	# Solo: Raven allein auf dem Dach → Drohne, folgt passiv.
	w.fresh_entry = false
	w._enter(w.Beat.ROOF)
	await settle(w)
	check(w.companion_lead() == w.raven and pet.kind == "drone" and pet.visible, "Raven alone on the roof is accompanied by her drone")
	check(not pet.claimed and pet.position.distance_to(w.raven.position) < 80.0, "without a second player the drone simply follows")
	# Solo mit beiden Helden in der Szene: kein Begleiter.
	w._enter(w.Beat.GARAGE)
	await settle(w, 60)
	check(w.companion_lead() == null and not pet.visible, "solo play with both heroes present shows no companion")
	# Koop: nur ein Held spielbar → Spieler 2 bekommt den Begleiter des Führenden.
	w.set_coop(true)
	w._enter(w.Beat.AMBUSH)
	await settle(w, 60)
	check(w.companion_lead() == null and not pet.visible, "co-op ambush: player two plays Raven herself, so no companion")
	w._enter(w.Beat.BOSS)
	await settle(w, 90)
	check(w.companion_lead() == w.player and pet.kind == "nanites" and pet.visible, "in co-op Shadepi's nanite swarm joins when only he is playable")
	var foes: Array = w.special_targets()
	check(not foes.is_empty(), "the tower fight has an enemy for the companion")
	if not foes.is_empty():
		var foe = foes[0]
		var before: int = foe.health
		pet.claim()
		check(pet.claimed, "player two takes over the companion")
		pet.position = foe.position + Vector2(-24, -18)
		pet.attack_cooldown = 0.0
		pet.attack()
		check(foe.health < before and pet.attack_flash > 0.0, "nanite bite damages the enemy and turns the swarm red")
		check(pet.attack_cooldown > 0.0, "bite has a cooldown")
		pet.hack()
		check(pet.shield_time > 0.0 and w.player.invulnerable >= 1.5, "protective swarm shields Shadepi")
		check(pet.hack_cooldown > 0.0, "the special has a cooldown")
	# Leine: der Begleiter bleibt beim Helden.
	pet.position = w.player.position + Vector2(900, 0)
	pet.shield_time = 0.0
	for i in 3: await process_frame
	check(pet.position.distance_to(w.player.position) <= pet.LEASH + 1.0, "the companion stays on its leash")
	# Pause friert ihn ein.
	w.menu_open = true
	var clock: float = pet.clock
	for i in 4: await process_frame
	check(pet.clock == clock, "pause freezes the companion")
	w.menu_open = false
	# Freigabe gibt die Pfeiltasten zurück.
	pet._release()
	var arrow := InputEventKey.new()
	arrow.physical_keycode = KEY_LEFT
	check(not pet.claimed, "releasing hands control back")
	# Koop auf dem Dach: Drohne mit Schuss und Störimpuls.
	w._enter(w.Beat.ROOF)
	await settle(w, 60)
	check(pet.kind == "drone", "in co-op the roof gives player two the drone")
	pet.claim()
	pet.attack_cooldown = 0.0
	pet.attack()
	check(pet.attack_flash > 0.0, "drone shot shows its muzzle flash even without a target")
	pet.hack_cooldown = 0.0
	pet.hack()
	check(pet.hack_cooldown > 0.0, "drone jamming pulse goes on cooldown")
	# Fahrt, Flug und Abspann: kein Begleiter.
	for beat in [w.Beat.CHASE, w.Beat.FLIGHT, w.Beat.END]:
		w._enter(beat)
		for i in 4: await process_frame
		check(w.companion_lead() == null, "no companion during %s" % w.Beat.keys()[beat])
	w.set_coop(false)
	w.queue_free()
	await process_frame
	print("COMPANION: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
