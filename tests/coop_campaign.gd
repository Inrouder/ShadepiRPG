extends SceneTree
## v0.54.0 · ClaudeHelper: Koop in Kapitel 3–7 – Spieler 2 steuert Raven, wo sie frei ist.
var checks := 0
var failures := 0

func _initialize() -> void: run.call_deferred()

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("FAIL: " + message)

func settle(w, frames: int = 60) -> void:
	for i in frames:
		await process_frame
		if w.cutscene.running: w.cutscene.skip()

func run() -> void:
	# Freie Aufnahmen statt Rauschstößen: volle Abtastrate und Quellenangabe.
	for sound in ["pistol", "drive_shot", "prop_blast", "drive_explosion", "hit", "slash", "prop_metal", "prop_wood", "enemy_hurt_0", "enemy_death_2", "enemy_attack_1"]:
		var stream: AudioStreamWAV = load("res://assets/audio/%s.wav" % sound)
		check(stream.mix_rate == 44100 and stream.get_length() > 0.15 and stream.get_length() < 1.8, "%s is a 44.1 kHz recording of sensible length" % sound)
	check(FileAccess.get_file_as_string("res://assets/audio/CREDITS.md").contains("CC0"), "sound sources and licence are documented")
	var w = load("res://scenes/campaign.tscn").instantiate()
	root.add_child(w)
	await process_frame
	w.close_menu(); w.started = true
	w.fresh_entry = false
	# Solo bleibt unverändert: Raven folgt von selbst.
	w._enter(w.Beat.AMBUSH)
	await settle(w)
	check(not w.actor_is_playable(w.raven) and w.actor_input_prefix(w.raven) == "", "solo ambush keeps Raven as an AI partner")
	w.set_coop(true)
	w._enter(w.Beat.AMBUSH)
	await settle(w)
	check(w.actor_is_playable(w.player) and w.actor_is_playable(w.raven), "co-op ambush: both heroes are playable")
	check(w.actor_input_prefix(w.raven) == "raven_" and w.actor_input_prefix(w.player) == "", "player two uses Raven's own controls")
	var start: Vector2 = w.raven.position
	var hero: Vector2 = w.player.position
	Input.action_press("raven_move_right")
	for i in 30: await physics_frame
	Input.action_release("raven_move_right")
	check(w.raven.position.x > start.x + 12.0, "Raven walks under player two's input (%.0f → %.0f)" % [start.x, w.raven.position.x])
	check(absf(w.player.position.x - hero.x) < 6.0, "Shadepi does not move with player two's input")
	check(w.combat_target(w.raven.position + Vector2(4, 0)) == w.raven, "enemies can target the player-controlled Raven")
	# Symbolsuche in der Garage: frei; danach nimmt Raven ihre Story-Position ein.
	w._enter(w.Beat.GARAGE)
	await settle(w)
	check(w.coop_raven_playable(), "co-op garage search: Raven is playable")
	w.point_index = 1
	check(not w.coop_raven_playable() and w.actor_input_prefix(w.raven) == "", "once the lift is found Raven follows the story position again")
	var before: Vector2 = w.raven.position
	for i in 40: await process_frame
	check(w.raven.position.distance_to(before) > 4.0 or w.raven.position.distance_to(w.Story.POINTS[w.Beat.GARAGE][1] + Vector2(-20, 0)) <= 9.0, "a guided Raven still walks by herself in co-op")
	# Tower: Raven extrahiert Daten – geführt; Spieler 2 bekommt die Naniten.
	w._enter(w.Beat.BOSS)
	await settle(w, 90)
	check(not w.coop_raven_playable() and w.companion_lead() == w.player, "tower fight: Raven is story-bound, player two gets the nanite swarm")
	# Raven führt (Dach): Spieler 1 steuert sie, Spieler 2 die Drohne.
	w._enter(w.Beat.ROOF)
	await settle(w)
	check(w.actor_is_playable(w.raven) and w.actor_input_prefix(w.raven) == "" and w.companion_lead() == w.raven, "when Raven leads, player one plays her and player two the drone")
	w.set_coop(false)
	w.queue_free()
	await process_frame
	print("COOP CAMPAIGN: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
