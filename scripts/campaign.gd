extends "res://scripts/main.gd"

const Story = preload("res://scripts/campaign_story.gd")
const Beat = Story.Beat
const Timing = preload("res://scripts/sanctuary_timing.gd")
const Drive = preload("res://scripts/campaign_drive.gd")
const ChapterHud = preload("res://scripts/campaign_hud.gd")
const SAVE := "user://shadepi-campaign.cfg"
const SPAWN := Vector2(134, 421)
const COVER: Array[Rect2] = [Rect2(330, 365, 57, 37), Rect2(576, 266, 66, 62), Rect2(766, 421, 77, 35)]
const SHOOTERS := [preload("res://assets/sprites/shooter-visor.png"), preload("res://assets/sprites/shooter-violet.png")]
const GUARDS := [
	preload("res://assets/sprites/punk-1.png"), preload("res://assets/sprites/punk-2.png"),
	preload("res://assets/sprites/punk-3.png"), preload("res://assets/sprites/punk-4.png"),
]
var beat := Beat.PACT
var point_index := 0
var port_index := 0
const PORTS := [Vector2(725, 359), Vector2(785, 350), Vector2(842, 367)]
const PORT_ORDER := [1, 0, 2]
var clock := 0.0
var countdown := 60.0
var foes: Array[PixelActor] = []
var drive: Node2D
var timing: Node2D
var echo_ready := false
var drive_layer: CanvasLayer
var cover_bodies: Array[StaticBody2D] = []

func create_hud() -> CanvasLayer:
	return ChapterHud.new()

func _ready() -> void:
	super._ready()
	if not load_game():
		new_game()

func world_walls() -> Array[Rect2]:
	return [Rect2(0, 0, 1024, 251), Rect2(0, 495, 1024, 145),
		Rect2(-20, 0, 20, 640), Rect2(1024, 0, 20, 640)]

func world_props() -> Array[Dictionary]:
	return []

func _build_world() -> void:
	super._build_world()
	ground_atmosphere.hide()
	enemy.hide()
	set_gate(true)
	for box in COVER:
		cover_bodies.append(_collider(box))
	drive_layer = CanvasLayer.new()
	drive_layer.layer = 8
	add_child(drive_layer)

func raven_leads() -> bool:
	return (beat == Beat.HANGAR or (beat == Beat.ROOF and point_index < 2)) or (beat == Beat.ECHO and echo_ready)

func actor_is_playable(actor: PixelActor) -> bool:
	return drive == null and timing == null and beat != Beat.END and actor == (raven if raven_leads() else player)

func actor_input_prefix(_actor: PixelActor) -> String:
	return ""

func is_combat() -> bool:
	return beat in [Beat.AMBUSH, Beat.BOSS] or (beat == Beat.ROOF and point_index == 2)

func _process(delta: float) -> void:
	super._process(delta)
	if raven_leads():
		camera.position = raven.position + Vector2(0, -52)
	if is_busy():
		return
	clock += delta
	if beat == Beat.ESCAPE:
		countdown = maxf(0, countdown - delta)
		if countdown == 0:
			_retry("Zeit abgelaufen · Kontrollpunkt")

func _update_raven_follower(delta: float) -> void:
	if not is_combat() and (beat != Beat.GARAGE or point_index != 1):
		return
	var target: Vector2 = Story.POINTS[beat][1] + Vector2(-20, 0) if beat == Beat.GARAGE else player.position + Vector2(-35, 22)
	if raven.position.distance_to(target) > (8.0 if beat == Beat.GARAGE else 35.0):
		raven.facing = (target - raven.position).normalized()
		raven.velocity = raven.facing * 88
		raven.move_and_slide()
		raven.animate("walk", delta)
	else:
		raven.animate("idle", delta)

func new_game(_save_checkpoint: bool = true) -> void:
	_enter(Beat.PACT)

func _enter(next: int) -> void:
	if is_instance_valid(timing):
		timing.hide()
		timing.queue_free()
		timing = null
		gamepads.assign(Input.get_connected_joypads(), false)
	echo_ready = false
	if is_instance_valid(drive):
		drive.hide()
		drive.queue_free()
	drive = null
	for foe in foes:
		foe.hide()
		foe.set_physics_process(false)
		foe.queue_free()
	foes.clear()
	beat = next
	stage = 0
	point_index = 0
	port_index = 0
	clock = 0.0
	countdown = 60.0
	hack_cooldown = 0.0
	player.health = 100
	player.energy = 100.0
	player.position = SPAWN
	player.reset_transients()
	reset_raven(SPAWN + Vector2(-27, 14))
	raven.visible = true
	player.visible = not raven_leads()
	for body in cover_bodies:
		body.get_child(0).set_deferred("disabled", beat in [Beat.LAKE, Beat.END])
		body.visible = beat not in [Beat.LAKE, Beat.END]
	effects.rain = beat in [Beat.AMBUSH, Beat.GARAGE, Beat.ROOF]
	ui.dialogue_open = false
	ui.dialogue_panel.hide()
	close_menu()
	autosave()
	if beat in [Beat.CHASE, Beat.FLIGHT]:
		drive = Drive.new()
		drive.world = self
		drive.flight = beat == Beat.FLIGHT
		drive_layer.add_child(drive)
		drive.completed.connect(_advance)
		drive.crashed.connect(func(): _retry("Landung abgebrochen · Kontrollpunkt" if beat == Beat.FLIGHT else "Fahrzeug ausgefallen · Kontrollpunkt"))
	if is_combat():
		_spawn_wave()
	ui.dialogue(Story.DIALOGUE[beat])

func _advance() -> void:
	if beat < Beat.END:
		_enter(beat + 1)

func _retry(title: String) -> void:
	_enter(beat)
	menu_open = true
	ui.show_menu(title)

func _spawn_wave() -> void:
	if beat == Beat.BOSS:
		_spawn_foe(Vector2(858, 340), 360, -1)
		return
	if beat == Beat.ROOF:
		_spawn_foe(Vector2(735, 335), 80, 2)
		_spawn_foe(Vector2(870, 320), 72, 1)
		return
	_spawn_foe(Vector2(481, 355), 64, 0)
	_spawn_foe(Vector2(717, 364), 72, 1)

func _spawn_foe(point: Vector2, hp: int, variant: int) -> void:
	var foe := EnemyScript.new()
	foe.max_health = hp
	var sprite: Texture2D = SHOOTERS[variant] if beat == Beat.AMBUSH else (GUARDS[variant] if variant >= 0 else preload("res://assets/sprites/kenzo.png"))
	foe.setup(sprite, self)
	foe.position = point
	foe.hit_damage = 16 if variant >= 0 else 24
	foe.shot_range = 176.0 if variant == 1 or (beat == Beat.AMBUSH and variant == 0) else 0.0
	foe.move_speed = 62
	actors.add_child(foe)
	foe.reset_fight(hp)
	foe.active = true
	if variant < 0:
		foe.sweep_enabled = true
		foe.flash_time = 0.45
	if beat == Beat.ROOF and variant == 2:
		foe.front_shield = true
	foes.append(foe)

func combat_target(origin: Vector2, include_cloaked: bool = false) -> PixelActor:
	return super.combat_target(origin, include_cloaked) if is_combat() else null

func player_strike(amount: int) -> void:
	if not is_combat():
		return
	for foe in foes:
		if foe.health > 0 and CombatRules.can_strike(player.position, player.facing, foe.position) and _line_clear(player.position, foe.position):
			foe.take_damage(amount)

func raven_hack() -> bool:
	if not is_combat() or is_busy():
		return false
	if hack_cooldown > 0:
		toast("Ravens Deck lädt.")
		return false
	var target: PixelActor
	var nearest := 250.0
	for foe in foes:
		var distance: float = player.position.distance_to(foe.position)
		if foe.health > 0 and distance < nearest and _line_clear(raven.position, foe.position):
			target = foe
			nearest = distance
	if target == null:
		toast("Raven braucht eine freie Verbindung.")
		return false
	if beat == Beat.BOSS and target.health <= 180 and fposmod(clock, 3.0) > 1.45:
		toast("Kenzō sperrt die Leitung. Auf das Flackern am Schulterservo warten.")
		return false
	target.hack()
	hack_cooldown = 6.0
	effects.hack_arc(raven.position, target.position)
	sound("hack")
	toast("Optik und Implantate gestört.")
	return true

func enemy_defeated(_foe: PixelActor = null) -> void:
	if _living() != 0:
		return
	if beat in [Beat.ROOF, Beat.BOSS]:
		_finish_encounter.call_deferred(beat)
	else:
		toast("Die Gasse ist frei. Zum Motorrad!")

func _finish_encounter(expected: int) -> void:
	if beat == expected and not foes.is_empty() and _living() == 0:
		_advance()

func _living() -> int:
	var amount := 0
	for foe in foes:
		if foe.health > 0:
			amount += 1
	return amount

func player_defeated() -> void:
	_retry.call_deferred("Systemausfall · Kontrollpunkt")

func chapter_label() -> String:
	var chapter: int = Story.CHAPTERS[beat]
	if chapter == 5:
		return "KAPITEL 5 / HEILIGTUM"
	return "KAPITEL %d / %s" % [chapter, Story.TITLES[chapter - 3]]

func _target() -> Vector2:
	if beat == Beat.HANGAR and point_index == 3:
		return PORTS[PORT_ORDER[port_index]]
	if (is_combat() and _living() > 0) or point_index >= Story.POINTS[beat].size():
		return Vector2.ZERO
	return Story.POINTS[beat][point_index]

func _timed_node() -> bool:
	return beat in [Beat.HANGAR, Beat.ROOF] or (beat == Beat.ESCAPE and point_index in [0, 2])

func _signal_open() -> bool:
	return fposmod(clock, 2.1) < 1.0

func chapter_objective() -> String:
	match beat:
		Beat.AMBUSH:
			return "Hinterhalt · %d Gegner" % _living() if _living() else "Zum Motorrad"
		Beat.ECHO:
			return "Erinnerungen ordnen · %d / 3" % point_index if echo_ready else "An Shadepis Sessel treten"
		Beat.GARAGE:
			return "Gemeinsam auf die Plattform" if point_index == 1 else Story.OBJECTIVES[beat]
		Beat.HANGAR:
			if point_index == 3:
				return "Prüf-ICE · Portfolge 2, 1, 3 · %d / 3" % port_index
			return Story.OBJECTIVES[beat] % point_index
		Beat.ROOF:
			return "Aufzugwachen ausschalten" if point_index == 2 else ["Kennung am Dachterminal prüfen", "Penthouse-Zugang öffnen"][point_index]
		Beat.PACT:
			return Story.OBJECTIVES[beat] % point_index
		Beat.BOSS:
			var hp: int = foes.back().health if not foes.is_empty() else 360
			return "Kenzō · %d / 360 HP%s" % [hp, " · Hackfenster" if hp <= 180 and fposmod(clock, 3.0) <= 1.45 else ""]
		Beat.ESCAPE:
			return "%s · %02d s" % [["Daten sichern", "Aufzug blockieren", "Pumpeneinheit neu starten", "Aerodyne starten"][point_index], ceili(countdown)]
	return Story.OBJECTIVES[beat]

func interaction_prompt() -> String:
	if timing != null:
		return ""
	if beat == Beat.ECHO and echo_ready and raven.position.distance_to(Vector2(551, 426)) < 28.0:
		return "E / A · Flimmerndes Echo prüfen"
	var target := _target()
	var actor: PixelActor = raven if raven_leads() else player
	if beat == Beat.HANGAR:
		var prop := _hangar_prop()
		if not prop.is_empty():
			return "E / A · " + prop
		if point_index == 3 and _near_port() >= 0:
			return "E / A · Port %d prüfen" % (_near_port() + 1)
	if target == Vector2.ZERO or actor.position.distance_to(target) > 43.0:
		return ""
	if _timed_node():
		return "E / A · Daten abgreifen" if _signal_open() else "ICE scannt · auf Cyan warten"
	return "E / A · " + chapter_objective()

func _hangar_prop() -> String:
	for item in [[Vector2(193, 289), "Klingen ansehen"], [Vector2(476, 293), "Ersatzteile ansehen"], [Vector2(899, 330), "Aerodyne ansehen"]]:
		if raven.position.distance_to(item[0]) <= 24.0:
			return item[1]
	return ""

func _near_port() -> int:
	for i in PORTS.size():
		if raven.position.distance_to(PORTS[i]) <= 22.0:
			return i
	return -1

func interact(_actor: PixelActor = null) -> void:
	if is_busy() or interaction_prompt().is_empty():
		return
	if beat == Beat.ECHO:
		if not echo_ready:
			_start_echo()
			return
		if raven.position.distance_to(Vector2(551, 426)) < 28.0:
			raven.position = SPAWN if point_index == 0 else Story.POINTS[beat][point_index - 1]
			toast("Das Bild zerfällt. Zur letzten stabilen Erinnerung.")
			return
		toast(["Das Kloster.", "Die früheren Träger.", "Die Nacht des Angriffs."][point_index])
		if point_index == 2:
			ui.dialogue([
				["RAVEN", "Ich habe gesehen, was du verloren hast.", "echo"],
				["SHADEPI", "Das Heiligtum lebt in mir. Jetzt hast du seine Erinnerungen gesehen.", "echo"],
			], _advance)
			return
	if beat == Beat.GARAGE and point_index == 1 and raven.position.distance_to(_target()) > 35.0:
		toast("Warte auf Raven.")
		return
	if beat == Beat.HANGAR and not _hangar_prop().is_empty():
		toast(_hangar_prop() + " · Bestände des Ordens.")
		return
	if beat == Beat.HANGAR and point_index == 3:
		if _near_port() != PORT_ORDER[port_index] or not _signal_open():
			port_index = 0
			toast("Prüf-ICE hat ausgelöst. Prüfe 2, 1, 3 bei Cyan.")
			return
		effects.hack_arc(PORTS[PORT_ORDER[port_index]], Vector2(884, 328))
		port_index += 1
		if port_index == PORTS.size():
			_advance()
		return
	if _timed_node() and not _signal_open():
		toast("Zugriff blockiert. Warte auf das Cyan-Signal.")
		return
	if _timed_node():
		effects.burst(_target(), Color("70f5f7"), 28)
		sound("hack")
	if beat == Beat.PACT:
		toast(["Aufzug: Sicherheitskräfte eine Etage tiefer.", "Dachzugang: privater Landeplatz.", "Scanner: Kennung von Kenzōs Gleiter erforderlich."][point_index])
	if beat == Beat.HANGAR:
		effects.hack_arc(_target(), Vector2(884, 328))
		toast(["Stromversorgung aktiv.", "Kennung kopiert.", "Transponder bereit. Prüf-ICE verlangt Portfolge 2, 1, 3."][point_index])
	if beat == Beat.ESCAPE:
		toast(["Daten gesichert. Spuren gelöscht.", "Aufzug blockiert.", "Pumpe läuft. Zur Luke!", "Aerodyne hebt ab."][point_index])
	point_index += 1
	if beat == Beat.ROOF and point_index == 2:
		player.position = raven.position + Vector2(-50, 15)
		player.show()
		ui.dialogue([["RAVEN", "Sicherung am Aufzug unter dem Penthouse. Ich nehme den Funker, du den Schild.", "tower"]])
		_spawn_wave()
		return
	if beat != Beat.HANGAR and point_index == Story.POINTS[beat].size():
		_advance()

func _start_echo() -> void:
	timing = Timing.new()
	timing.world = self
	drive_layer.add_child(timing)
	timing.completed.connect(_enter_echo)

func _enter_echo() -> void:
	timing.hide()
	timing.queue_free()
	timing = null
	gamepads.assign(Input.get_connected_joypads(), false)
	echo_ready = true
	player.hide()
	ui.dialogue([["HEILIGTUM", "Eindämmung bricht. Ein Teil des Schwarms geht auf Raven über. Finde die stabilen Erinnerungsanker.", "echo"]])

func saved_checkpoint() -> int:
	var config := ConfigFile.new()
	if config.load(SAVE) != OK:
		return -1
	var value: Variant = config.get_value("campaign", "beat", -1)
	return value if value is int and value >= Beat.PACT and value <= Beat.END else -1

func autosave() -> void:
	if not save_game():
		toast("Kontrollpunkt konnte nicht gespeichert werden.")

func save_game() -> bool:
	var config := ConfigFile.new()
	config.set_value("campaign", "beat", beat)
	return config.save(SAVE) == OK

func load_game(_requested_mode: Variant = null) -> bool:
	var saved := saved_checkpoint()
	if saved < 0:
		return false
	_enter(saved)
	return true

func _draw() -> void:
	var theme: String = Story.THEMES[beat]
	var lake := theme == "lake"
	var palette: Dictionary = {
		"hideout": ["17272e", "38545e", "68c6be"], "alley": ["1d2230", "373c50", "df547a"],
		"garage": ["23262b", "484447", "f0a464"], "hangar": ["15212d", "304458", "70e1ef"],
		"roof": ["222338", "424562", "87d2f4"], "suite": ["302435", "59415b", "f4b992"],
		"echo": ["261e2e", "534050", "f58790"], "lake": ["142a30", "24454b", "73e4df"],
	}
	var colours: Array = palette.get(theme, palette.hangar)
	var floor := Color(colours[0])
	var trim := Color(colours[1])
	var neon := Color(colours[2])
	draw_rect(Rect2(0, 0, 1024, 640), floor)
	for x in range(0, 1024, 52):
		var height := 26 + (x * 13) % 125
		if lake:
			draw_colored_polygon(PackedVector2Array([Vector2(x - 18, 245), Vector2(x + 10, 245 - height), Vector2(x + 38, 245)]), trim.darkened(0.3))
			draw_line(Vector2(x + 10, 214), Vector2(x + 10, 253), trim, 3)
		else:
			draw_rect(Rect2(x, 226 - height, 45, height + 25), trim.darkened(0.35))
			for y in range(235 - height, 236, 12):
				draw_rect(Rect2(x + 8, y, 5, 2), neon.darkened(0.65 + float((x + y) % 3) * 0.08))
	draw_rect(Rect2(0, 237, 1024, 15), trim)
	for y in range(260, 490, 16):
		draw_line(Vector2(0, y), Vector2(1024, y), trim.darkened(0.28))
		for x in range(y % 40, 1024, 52):
			draw_line(Vector2(x, y), Vector2(x + 5, y + 16), trim.darkened(0.39))
	for i in 150:
		var speck := Vector2((i * 137) % 1024, 255 + (i * 83) % 238)
		draw_rect(Rect2(speck, Vector2(2 + i % 5, 1)), trim.darkened(0.46) if i % 3 else trim.darkened(0.14))
	if lake:
		for i in 42:
			var reed := Vector2(90 + i * 97 % 900, 286 + i * 67 % 189)
			if reed.distance_to(Vector2(741, 347)) > 125:
				draw_line(reed, reed + Vector2(-4, -7 - i % 6), trim.lightened(0.10))
				draw_line(reed, reed + Vector2(5, -5), trim)
				draw_rect(Rect2(reed + Vector2(-3, 0), Vector2(8, 2)), floor.darkened(0.33))
		for i in 16:
			var mote := Vector2(345 + i * 61 % 620, 256 + fposmod(i * 32 - clock * 5, 182))
			draw_circle(mote, 1 + i % 2 * 0.35, Color(0.38, 0.92, 0.73, 0.25 + sin(clock + i) * 0.16))
		draw_set_transform(Vector2(741, 347), 0.0, Vector2(1.0, 0.53))
		draw_circle(Vector2.ZERO, 116, trim)
		for i in 8:
			draw_arc(Vector2.ZERO, 32.0 + i * 11.0, 0, TAU, 48, neon.darkened(0.30 + i * 0.06), 1)
		draw_set_transform(Vector2.ZERO)
	else:
		for box in COVER:
			draw_rect(Rect2(box.position + Vector2(5, 5), box.size), floor.darkened(0.5))
			draw_rect(box, trim)
			draw_rect(Rect2(box.position + Vector2(4, 4), Vector2(box.size.x - 8, 5)), neon.darkened(0.48))
			for y in range(int(box.position.y) + 14, int(box.end.y) - 4, 7):
				draw_line(Vector2(box.position.x + 5, y), Vector2(box.end.x - 5, y), floor)
		for x in range(47, 980, 114):
			draw_rect(Rect2(x, 259, 55, 25), trim.darkened(0.4))
			for n in 3:
				draw_rect(Rect2(x + 6 + n * 15, 265, 9, 5), neon.darkened(0.4 + n * 0.10))
		for x in range(40, 970, 74):
			draw_rect(Rect2(x, 478, 33, 4), trim)
			draw_line(Vector2(x + 2, 480), Vector2(x + 30, 480), neon.darkened(0.62))
		match theme:
			"hideout", "garage":
				for x in [250, 483, 723]:
					draw_rect(Rect2(x, 282, 68, 13), trim)
					draw_rect(Rect2(x + 4, 295, 4, 9), trim)
					draw_rect(Rect2(x + 60, 295, 4, 9), trim)
					draw_line(Vector2(x + 11, 285), Vector2(x + 41, 285), neon.darkened(0.18), 2)
				draw_line(Vector2(687, 302), Vector2(749, 319), trim, 2)
			"echo":
				draw_rect(Rect2(452, 283, 36, 32), Color("745464"))
				draw_rect(Rect2(594, 267, 98, 44), Color("6e5361"))
				draw_rect(Rect2(600, 272, 27, 35), Color("9e8792"))
				if echo_ready:
					for i in 12:
						var p := Vector2(340 + (i * 83) % 550, 280 + fposmod(i * 34 - clock * 8, 170))
						draw_circle(p, 2.0, Color(0.96, 0.32, 0.45, 0.38))
					draw_arc(Vector2(551, 426), 13, 0, TAU, 24, Color("a35b7a"), 2.0)
			"suite":
				for x in [176, 467]:
					draw_rect(Rect2(x, 305, 89, 29), Color("3d2b45"))
					draw_rect(Rect2(x + 6, 308, 76, 18), Color("6a4561"))
					draw_line(Vector2(x + 43, 309), Vector2(x + 43, 328), floor, 2)
				draw_rect(Rect2(682, 308, 75, 5), neon.darkened(0.42))
			"hangar":
				if beat == Beat.HANGAR and point_index == 3:
					for port in PORTS:
						draw_rect(Rect2(port - Vector2(12, 9), Vector2(24, 18)), trim)
						draw_rect(Rect2(port - Vector2(9, 6), Vector2(18, 12)), neon.darkened(0.4) if _signal_open() else Color("6c344a"), false)
				for x in [180, 450, 692]:
					draw_rect(Rect2(x, 294, 68, 25), trim.darkened(0.4))
					for rack in 5:
						draw_line(Vector2(x + 7 + rack * 12, 314), Vector2(x + 15 + rack * 12, 298), neon.darkened(0.42), 2)
				draw_polyline(PackedVector2Array([Vector2(176, 310), Vector2(201, 330), Vector2(283, 330), Vector2(306, 340)]), trim, 3)
			"alley":
				draw_rect(Rect2(328, 359, 62, 12), Color("526c57"))
				draw_rect(Rect2(333, 367, 51, 32), Color("334b44"))
				for i in 4:
					draw_line(Vector2(341 + i * 11, 374), Vector2(341 + i * 11, 394), Color("597165"))
				for x in [104, 477, 875]:
					draw_rect(Rect2(x, 288, 33, 22), trim)
					draw_rect(Rect2(x + 1, 286, 31, 4), neon.darkened(0.6))
					draw_line(Vector2(x + 7, 296), Vector2(x + 25, 296), floor)
		if theme in ["hangar", "roof", "suite"]:
			var p := Vector2(883, 357 if theme != "hangar" else 330)
			draw_arc(p, 59, 0, TAU, 44, neon.darkened(0.5), 2)
			draw_colored_polygon(PackedVector2Array([p + Vector2(-39, 14), p + Vector2(-23, -18), p + Vector2(21, -18), p + Vector2(41, 14), p + Vector2(22, 24), p + Vector2(-21, 24)]), trim.lightened(0.12))
			draw_rect(Rect2(p - Vector2(14, 13), Vector2(28, 12)), floor.darkened(0.35))
			draw_line(p + Vector2(-31, 13), p + Vector2(32, 13), neon, 2)
	if beat == Beat.BOSS and not foes.is_empty():
		var boss: PixelActor = foes.back()
		if boss.health > 0 and boss.health <= 180 and fposmod(clock, 3.0) <= 1.45:
			draw_circle(boss.position + Vector2(8, -34), 4.0, Color("72eff4"))
	var point := _target()
	if point != Vector2.ZERO:
		var signal_color := Color("f45d79") if _timed_node() and not _signal_open() else Color("72eff4")
		draw_circle(point, 12.0, signal_color, false, 2)
		var tip := point + Vector2(0, -31.0 + sin(clock * 5.0) * 3.0)
		draw_polyline(PackedVector2Array([tip + Vector2(-6, -5), tip, tip + Vector2(6, -5)]), signal_color, 2)
