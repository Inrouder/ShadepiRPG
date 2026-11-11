extends SceneTree
## v0.57.0 · ClaudeHelper: Arcade-Automat „NEON KOMBAT“ – Fundort, Menüführung, Kampfregeln,
## Zweispieler-Eingabe mit echten Tasten, CPU-Gegner und Rückweg ins Spiel.
## godot --headless --script res://tests/arcade.gd
const Kombat = preload("res://scripts/arcade/neon_kombat.gd")
var checks := 0
var failures := 0

func _initialize() -> void:
	run.call_deferred()

func check(ok: bool, msg: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("FAIL: " + msg)

## Kopflos läuft Godot ungebremst; gewartet wird deshalb in Spielzeit, nicht in Bildern.
func frames(n: int) -> void:
	await create_timer(maxf(0.03, n / 60.0)).timeout
	await process_frame

func until(done: Callable, seconds: float = 8.0) -> void:
	var left := seconds
	while left > 0.0 and not done.call():
		await process_frame
		left -= root.get_process_delta_time()

func key(code: Key, down: bool) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.physical_keycode = code
	event.pressed = down
	Input.parse_input_event(event)

func tap(code: Key) -> void:
	key(code, true); await frames(3)
	key(code, false); await frames(3)

func settle(w) -> void:
	for i in 60:
		await frames(4)
		if w.cutscene.running: w.cutscene.skip()
		elif w.ui.dialogue_open: w.ui.advance_dialogue()
		elif i > 8: return

func fighting(a) -> void:
	await until(func(): return a.phase == "fight")

func run() -> void:
	if not OS.get_user_data_dir().begins_with("/tmp/shadepi-"):
		push_error("Run with an isolated XDG_DATA_HOME=/tmp/shadepi-... directory; real player saves must never be used.")
		quit(1)
		return
	check(not Kombat.unlocked(), "der Automat ist vor dem ersten Fund nicht im Hauptmenü")
	for entry in Kombat.ROSTER:
		var sheet: Texture2D = load(entry.sheet)
		check(sheet != null and Vector2i(sheet.get_size()) == Vector2i(1024, 5120), "%s nutzt ein vollständiges Figurenblatt" % entry.name)
		check(Kombat.MOVES.has(entry.special) and float(entry.reach) > 30.0, "%s hat einen gültigen Spezialangriff" % entry.name)
	check(Kombat.ROSTER.size() == 10, "zehn Kämpfer stehen zur Wahl")

	var w = load("res://scenes/campaign.tscn").instantiate()
	root.add_child(w)
	await frames(20)
	w.close_menu()
	w.fresh_entry = false
	w._enter(w.Beat.HANGAR)
	await settle(w)
	check(is_instance_valid(w.arcade_cabinet) and w.arcade_cabinet.visible, "der Automat steht in Shadepis Halle")
	check(w.interaction_prompt().find("NEON KOMBAT") < 0, "fern vom Automaten erscheint kein Spielangebot")
	w.raven.position = w.ARCADE_SPOT + w.ArcadeCabinet.USE_POINT
	await frames(3)
	check(w.interaction_prompt().contains("NEON KOMBAT"), "am Automaten erscheint das Spielangebot")
	var objective: int = w.point_index
	w.interact()
	await frames(4)
	var a = w.arcade
	check(is_instance_valid(a) and w.is_busy() and a.screen == a.Screen.TITLE, "E öffnet den Automaten und hält das Spiel an")
	check(Kombat.unlocked(), "nach dem Fund steht der Automat im Hauptmenü bereit")

	# Titel → Duell → Kämpferwahl mit beiden Tastaturhälften.
	await tap(KEY_S)
	check(a.menu_index == 1, "S wählt im Titelbild den nächsten Eintrag")
	await tap(KEY_E)
	check(a.screen == a.Screen.SELECT and a.versus, "Duell öffnet die Kämpferwahl für zwei Spieler")
	await tap(KEY_D)
	await tap(KEY_RIGHT); await tap(KEY_RIGHT)
	check(a.cursors[0] == 1 and a.cursors[1] == 3, "beide Spieler bewegen ihre eigene Auswahl")
	await tap(KEY_J)
	check(a.locked[0] and not a.locked[1] and a.screen == a.Screen.SELECT, "Spieler 1 bestätigt, Spieler 2 wählt weiter")
	await tap(KEY_U)
	check(a.screen == a.Screen.FIGHT and a.fighters[0].data.id == "raven" and a.fighters[1].data.id == "kenzo", "nach beiden Bestätigungen beginnt der Kampf mit der Wahl")
	check(a.phase == "intro" and a.banner.begins_with("RUNDE"), "die Runde wird angesagt")
	var start: float = a.fighters[0].x
	key(KEY_D, true); await frames(6); key(KEY_D, false)
	check(is_equal_approx(a.fighters[0].x, start), "während der Ansage bewegt sich niemand")
	await fighting(a)

	# Bewegung, Sprung, Schlag, Block.
	var p1: Dictionary = a.fighters[0]
	var p2: Dictionary = a.fighters[1]
	var x1: float = p1.x
	var x2: float = p2.x
	key(KEY_D, true); key(KEY_LEFT, true); await frames(10); key(KEY_D, false); key(KEY_LEFT, false); await frames(2)
	check(p1.x > x1 + 4.0 and p2.x < x2 - 4.0, "D bewegt Spieler 1, Pfeil links Spieler 2")
	await tap(KEY_W)
	check(p1.y < 0.0 and p2.y == 0.0, "W lässt nur Spieler 1 springen")
	await until(func(): return p1.y >= 0.0)
	p1.x = 300.0; p2.x = 348.0
	var life: float = p2.hp
	await tap(KEY_J)
	await frames(20)
	check(p2.hp == life - float(p1.data.light) and p1.meter > 0.0, "J trifft mit dem leichten Schlag und lädt die Spezialleiste")
	await frames(60)
	p1.x = 300.0; p2.x = 348.0; p2.vx = 0.0
	life = p2.hp
	key(KEY_DOWN, true); await frames(4)
	check(p2.blocking, "Pfeil runter blockt")
	await tap(KEY_K)
	await frames(30)
	key(KEY_DOWN, false); await frames(2)
	check(p2.hp < life and p2.hp > life - float(p1.data.heavy) * 0.5, "ein geblockter Hieb kostet nur einen Bruchteil")

	# Spezialangriffe.
	await frames(40)
	p1.x = 150.0; p2.x = 420.0; p1.meter = 100.0
	life = p2.hp
	await tap(KEY_L)
	check(p1.meter == 50.0 and (p1.state == "shot" or not a.shots.is_empty()), "L löst Ravens Hack-Impuls aus und kostet die halbe Leiste")
	await until(func(): return p2.hp < life)
	await frames(2)
	check(p2.hp == life - 14.0 and a.shots.is_empty(), "das Geschoss trifft auf Distanz")
	a.start_match(0, 2, true)
	await fighting(a)
	p1 = a.fighters[0]; p2 = a.fighters[1]
	p1.x = 200.0; p2.x = 330.0; p1.meter = 100.0
	a._begin(p1, "dash")
	await frames(60)
	check(p1.x > p2.x and p2.hp == float(p2.data.hp) - 18.0, "Shadepis Schattenschnitt fährt durch den Gegner")
	p2.x = 300.0; p1.x = 380.0; p2.meter = 100.0; p1.y = 0.0
	life = p1.hp
	a._begin(p2, "slam")
	await frames(70)
	check(p1.hp == life - 20.0, "Jackals Chromfaust trifft am Boden im Umkreis")

	# Rundenende, Siegzählung, Ergebnis.
	await frames(40)
	p1.x = 300.0; p2.x = 348.0; p2.hp = 1.0; p1.y = 0.0; p1.state = "idle"
	await tap(KEY_J)
	await frames(20)
	check(a.phase == "ko" and a.wins[0] == 1 and p2.state == "ko" and a.banner == "K.O.", "K.O. beendet die Runde und zählt den Sieg")
	await until(func(): return a.round_number == 2)
	check(a.round_number == 2 and a.fighters[1].hp == float(a.fighters[1].data.hp), "die zweite Runde beginnt mit voller Lebensleiste")
	await fighting(a)
	a.timer = 0.05
	a.fighters[1].hp = 40.0
	await frames(12)
	check(a.phase == "ko" and a.banner == "ZEIT!" and a.wins[0] == 2, "bei Zeitablauf gewinnt, wer mehr Leben hat")
	await until(func(): return a.screen == a.Screen.RESULT)
	check(a.screen == a.Screen.RESULT and a.winner == 0, "zwei Rundensiege entscheiden das Duell")
	await tap(KEY_S); await tap(KEY_S)
	await tap(KEY_E)
	check(a.screen == a.Screen.TITLE, "vom Ergebnis zurück zum Titelbild")

	# Allein gegen die CPU: der Gegner kommt und greift an.
	a.start_match(0, 4, false)
	await fighting(a)
	var foe: Dictionary = a.fighters[1]
	var foe_start: float = foe.x
	await until(func(): return Kombat.MOVES.has(str(foe.state)), 12.0)
	check(foe.x < foe_start - 20.0 and Kombat.MOVES.has(str(foe.state)), "die CPU rückt vor und greift an")
	a.wins[0] = 1
	a.fighters[1].hp = 0.0
	await until(func(): return a.screen == a.Screen.RESULT)
	check(a.screen == a.Screen.RESULT and a.total_wins == 1, "ein Sieg gegen die CPU wird gezählt")

	# Esc: zurück zum Titel, dann aus dem Automaten; das Spiel läuft unverändert weiter.
	await tap(KEY_ESCAPE)
	check(is_instance_valid(a) and a.screen == a.Screen.TITLE and not w.menu_open, "Esc führt zuerst zum Titelbild, nicht ins Pausenmenü")
	await tap(KEY_ESCAPE)
	await frames(3)
	check(not is_instance_valid(w.arcade) and not w.is_busy() and w.point_index == objective and w.beat == w.Beat.HANGAR, "zweites Esc verlässt den Automaten, die Mission ist unverändert")
	w.queue_free()
	await frames(3)

	# Hauptmenü: nach dem Fund direkt spielbar, auch während das Menü offen ist.
	var menu = load("res://scenes/chapter_one.tscn").instantiate()
	root.add_child(menu)
	await frames(10)
	check(menu.ui.arcade_button.visible and root.get_visible_rect().encloses(menu.ui.menu.get_global_rect()) and menu.ui.menu.get_global_rect().encloses(menu.ui.quit_button.get_global_rect()), "Hauptmenü zeigt den Automaten und bleibt im Bild")
	menu.ui.arcade_button.pressed.emit()
	await frames(4)
	check(is_instance_valid(menu.arcade) and not menu.started, "der Automat öffnet sich aus dem Hauptmenü")
	await tap(KEY_E)
	check(menu.arcade.screen == menu.arcade.Screen.SELECT and not menu.started, "Eingaben gehen an den Automaten, nicht an das Menü darunter")
	await tap(KEY_ESCAPE); await tap(KEY_ESCAPE)
	await frames(3)
	check(not is_instance_valid(menu.arcade) and not menu.started and menu.menu_open, "nach dem Verlassen steht wieder das Hauptmenü")
	print("ARCADE: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
