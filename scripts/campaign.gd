extends "res://scripts/main.gd"

const Story = preload("res://scripts/campaign_story.gd")
const Beat = Story.Beat
const Timing = preload("res://scripts/sanctuary_timing.gd")
const Drive = preload("res://scripts/campaign_drive.gd")
const ChapterHud = preload("res://scripts/campaign_hud.gd")
const SAVE: = "user://shadepi-campaign.cfg"
const SPAWN: = Vector2(134, 421)
const PACT_SPAWN: = Vector2(437, 427)
const SHOOTERS: = [preload("res://assets/sprites/npcs/shooter-visor.png"), preload("res://assets/sprites/npcs/shooter-violet.png")]
const GUARDS: = [
	preload("res://assets/sprites/npcs/punk-1.png"), preload("res://assets/sprites/npcs/punk-2.png"), 
	preload("res://assets/sprites/npcs/punk-3.png"), preload("res://assets/sprites/npcs/punk-4.png"), 
]
var beat: = Beat.PACT
var point_index: = 0
var port_index: = 0
const PORTS: = [Vector2(725, 359), Vector2(785, 350), Vector2(842, 367)]
const PORT_ORDER: = [1, 0, 2]
var clock: = 0.0
var countdown: = 60.0
var ritual_flash: = 0.0
var ritual_origin: = Vector2.ZERO
var foes: Array[PixelActor] = []
var drive: Node2D
var timing: Node2D
var echo_ready: = false
var drive_layer: CanvasLayer

func create_hud() -> CanvasLayer:
	return ChapterHud.new()

func _ready() -> void :
	super._ready()
	if ChapterFlow.consume_entry(get_tree(), "res://scenes/campaign.tscn") or not load_game():
		new_game()

func world_walls() -> Array[Rect2]:
	return [Rect2(-20, 0, 20, 640), Rect2(1024, 0, 20, 640)]

func world_props() -> Array[Dictionary]:
	return []

func _build_world() -> void :
	super._build_world()
	ground_atmosphere.hide()
	enemy.hide()
	set_gate(true)
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

func _process(delta: float) -> void :
	super._process(delta)
	if raven_leads():
		camera.position = raven.position + Vector2(0, -52)
	ritual_flash = maxf(0.0, ritual_flash - delta)
	if is_busy():
		return
	clock += delta
	if beat == Beat.ESCAPE:
		countdown = maxf(0, countdown - delta)
		if countdown == 0:
			_retry("Zeit abgelaufen · Kontrollpunkt")

func _update_raven_follower(delta: float) -> void :
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

func new_game(_save_checkpoint: bool = true) -> void :
	restore_dressing_state({})
	_enter(Beat.PACT)

func _enter(next: int) -> void :
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
	var layouts: = ["hideout", "ambush", "", "garage", "hangar", "chamber", "", "roof", "suite", "suite", "lake", "lake"]
	set_dressing(layouts[beat])
	stage = 0
	point_index = 0
	port_index = 0
	clock = 0.0
	countdown = 60.0
	ritual_flash = 0.0
	music.stream_paused = next in [Beat.LAKE, Beat.END] or not audio_on
	hack_cooldown = 0.0
	player.health = 100
	player.energy = 100.0
	player.position = PACT_SPAWN if beat == Beat.PACT else SPAWN
	player.reset_transients()
	reset_raven(player.position + Vector2(-27, 14))
	raven.visible = true
	player.visible = not raven_leads()
	var backgrounds: = ["hideout", "ambush", "", "garage", "hangar", "chamber", "", "rooftop", "suite", "suite", "lakeside", "lakeside"]
	set_painted_solids(backgrounds[beat])
	effects.rain = beat in [Beat.AMBUSH, Beat.ROOF]
	effects.steam_vents.clear()
	if beat == Beat.AMBUSH:
		effects.steam_vents.append(Vector2(160, 240))
	if beat == Beat.END:
		player.position = Story.POINTS[Beat.LAKE].back() + Vector2(-12, 0)
		raven.position = Story.POINTS[Beat.LAKE].back() + Vector2(12, 0)
		player.facing = Vector2.RIGHT
		raven.facing = Vector2.LEFT
	_update_lighting()
	ui.clear_dialogue()
	close_menu()
	autosave()
	if beat in [Beat.CHASE, Beat.FLIGHT]:
		drive = Drive.new()
		drive.world = self
		drive.flight = beat == Beat.FLIGHT
		drive_layer.add_child(drive)
		drive.completed.connect(_advance)
		drive.crashed.connect( func(): _retry("Landung abgebrochen · Kontrollpunkt" if beat == Beat.FLIGHT else "Fahrzeug ausgefallen · Kontrollpunkt"))
	if is_combat():
		_spawn_wave()
	ui.dialogue(Story.DIALOGUE[beat])

func _update_lighting() -> void :
	match beat:
		Beat.PACT:
			set_scene_lighting(Color("afbecb"), [[Vector2(670, 361), "6fcbda", 2.2, 0.85], [Vector2(498, 311), "7780b8", 1.8, 0.46]])
		Beat.AMBUSH:
			set_scene_lighting(Color("aab8d2"), [[Vector2(159, 240), "d59a7f", 2.4, 0.64], [Vector2(431, 260), "ba6b91", 2.5, 0.45], [Vector2(890, 255), "68b8d0", 2.7, 0.68]])
		Beat.GARAGE:
			set_scene_lighting(Color("bfb5a9"), [[Vector2(735, 257), "f6c68a", 2.7, 0.71], [Vector2(868, 401), "6ab8be", 1.9, 0.45]])
		Beat.HANGAR:
			set_scene_lighting(Color("afbfc9"), [[Vector2(546, 214), "70db9f", 2.7, 0.8], [Vector2(871, 300), "d3c096", 2.5, 0.64]])
		Beat.ECHO:
			if echo_ready:
				set_scene_lighting(Color("c9aed4"), [[Vector2(553, 364), "a65378", 3.1, 0.55], [Vector2(871, 346), "d96654", 2.5, 0.74]])
			else:
				set_scene_lighting(Color("bdacba"), [[Vector2(446, 258), "e4ae87", 2.4, 0.62], [Vector2(682, 259), "70b0ce", 2.7, 0.62]])
		Beat.ROOF:
			set_scene_lighting(Color("acb9d4"), [[Vector2(797, 281), "6cdf9a", 2.5, 0.83], [Vector2(305, 315), "80b8da", 2.7, 0.54]])
		Beat.BOSS, Beat.ESCAPE:
			set_scene_lighting(Color("beb9d0"), [[Vector2(626, 261), "7895da", 3.1, 0.53], [Vector2(906, 261), "c585ae", 2.8, 0.53]])
		Beat.LAKE, Beat.END:
			set_scene_lighting(Color("b0c5bf"), [[Vector2(738, 306), "7dc7c4", 3.3, 0.8], [Vector2(336, 339), "799969", 2.8, 0.44]])
		_:
			set_scene_lighting(Color.WHITE, [])

func _advance() -> void :
	if beat < Beat.END:
		_enter(beat + 1)

func _retry(title: String) -> void :
	_enter(beat)
	menu_open = true
	ui.show_menu(title)

func _spawn_wave() -> void :
	if beat == Beat.BOSS:
		_spawn_foe(Vector2(858, 340), 360, -1)
		return
	if beat == Beat.ROOF:
		_spawn_foe(Vector2(735, 335), 80, 2)
		_spawn_foe(Vector2(870, 320), 72, 1)
		return
	_spawn_foe(Vector2(481, 355), 64, 0)
	_spawn_foe(Vector2(717, 364), 72, 1)

func _spawn_foe(point: Vector2, hp: int, variant: int) -> void :
	var foe: = EnemyScript.new()
	foe.max_health = hp
	var sprite: Texture2D = SHOOTERS[variant] if beat == Beat.AMBUSH else (GUARDS[variant] if variant >= 0 else preload("res://assets/sprites/npcs/kenzo.png"))
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
		foe.flash_time = 0.16
	if beat == Beat.ROOF and variant == 2:
		foe.front_shield = true
	foes.append(foe)

func combat_target(origin: Vector2, include_cloaked: bool = false) -> PixelActor:
	return super.combat_target(origin, include_cloaked) if is_combat() else null

func player_strike(amount: int) -> void :
	strike_scenery(player.position, player.facing, amount)
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
	var nearest: = 250.0
	for foe in foes:
		var distance: float = raven.position.distance_to(foe.position)
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

func enemy_defeated(_foe: PixelActor = null) -> void :
	if _living() != 0:
		return
	if beat in [Beat.ROOF, Beat.BOSS]:
		_finish_encounter.call_deferred(beat)
	else:
		toast("Die Gasse ist frei. Zum Motorrad!")

func _finish_encounter(expected: int) -> void :
	if beat == expected and not foes.is_empty() and _living() == 0:
		_advance()

func _living() -> int:
	var amount: = 0
	for foe in foes:
		if foe.health > 0:
			amount += 1
	return amount

func player_defeated() -> void :
	_retry.call_deferred("Systemausfall · Kontrollpunkt")

func chapter_label() -> String:
	var chapter: int = Story.CHAPTERS[beat]
	if chapter == 5:
		return "KAPITEL 5 / HEILIGTUM"
	if chapter == 4:
		return "KAPITEL 4 / DRACHENHÖHLE"
	return "KAPITEL %d / %s" % [chapter, Story.TITLES[chapter - 3]]

func _target() -> Vector2:
	if beat == Beat.HANGAR and point_index == 3:
		return PORTS[PORT_ORDER[port_index]]
	if beat == Beat.ECHO and echo_ready and point_index < Painted.ECHO_POINTS.size():
		return Painted.ECHO_POINTS[point_index]
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
			return "Erinnerungen ordnen · %d / 3" % point_index if echo_ready else "Heiligtum am Sessel prüfen"
		Beat.GARAGE:
			return "Gemeinsam auf die Plattform" if point_index == 1 else Story.OBJECTIVES[beat]
		Beat.HANGAR:
			if point_index == 3:
				return "Prüf-ICE · Portfolge 2, 1, 3 · %d / 3" % port_index
			return Story.OBJECTIVES[beat] %point_index
		Beat.ROOF:
			return "Aufzugwachen ausschalten" if point_index == 2 else ["Kennung am Dachterminal prüfen", "Penthouse-Zugang öffnen"][point_index]
		Beat.PACT:
			return Story.OBJECTIVES[beat] %point_index
		Beat.BOSS:
			var hp: int = foes.back().health if not foes.is_empty() else 360
			return "Kenzō · %d / 360 HP%s" % [hp, " · Hackfenster" if hp <= 180 and fposmod(clock, 3.0) <= 1.45 else ""]
		Beat.LAKE:
			return ["Mit Raven am Ufer sprechen", "Bitte am Wasser sprechen", "Antwort des Heiligtums hören", "Aufnahme vollziehen"][point_index]
		Beat.ESCAPE:
			return "%s · %02d s" % [["Daten sichern", "Aufzug blockieren", "Treibstoffpumpe fernstarten", "Zum Dachausgang"][point_index], ceili(countdown)]
	return Story.OBJECTIVES[beat]

func interaction_prompt() -> String:
	if timing != null:
		return ""
	if beat == Beat.ECHO and echo_ready and raven.position.distance_to(Vector2(551, 426)) < 28.0:
		return "E / A · Flimmerndes Echo prüfen"
	var target: = _target()
	var actor: PixelActor = raven if raven_leads() else player
	if beat == Beat.HANGAR:
		var prop: = _hangar_prop()
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

func interact(_actor: PixelActor = null) -> void :
	if is_busy() or interaction_prompt().is_empty():
		return
	if beat == Beat.LAKE:
		_ritual_step()
		return
	if beat == Beat.ECHO:
		if not echo_ready:
			_start_echo()
			return
		if raven.position.distance_to(Vector2(551, 426)) < 28.0:
			raven.position = SPAWN if point_index == 0 else Painted.ECHO_POINTS[point_index - 1]
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
		toast(["Daten gesichert. Spuren gelöscht.", "Aufzug blockiert.", "Fernstart bestätigt. Zum Dachausgang!", "Dach erreicht. Der Aerodyne hebt ab."][point_index])
	point_index += 1
	if beat == Beat.ROOF and point_index == 2:
		player.position = raven.position + Vector2(-50, 15)
		player.show()
		ui.dialogue([["RAVEN", "Zwei Wachen am Aufzug. Ich störe auf dein Signal ihre Implantate. Du musst den Schild umgehen oder im Hackfenster zuschlagen.", "tower"]])
		_spawn_wave()
		return
	if beat != Beat.HANGAR and point_index == Story.POINTS[beat].size():
		_advance()

func _ritual_step() -> void :
	var lines: Array = [
		[["SHADEPI", "Das Heiligtum hat dich erkannt. Wenn du es freiwillig willst, kannst du dem Orden beitreten.", ""], 
			["RAVEN", "Ich will nach vorne blicken. Ja.", "see"]], 
		[["SHADEPI", "Heiligtum, höre unsere Bitte. Raven tritt aus freiem Willen vor dich.", ""]], 
		[["HEILIGTUM", "Dein Wille ist stark. Ich nehme dich in meine Obhut.", ""]], 
		[["SHADEPI", "Raven, ich nehme dich als Zweite Kriegerin und Behüterin des Heiligtums in den Orden des Weißen Drachen auf.", ""]], 
	]
	raven.position = _target() + Vector2(18, 5)
	if point_index > 0:
		ritual_flash = 1.4
		ritual_origin = _target()
		effects.burst(ritual_origin, Color("72eff4"), 30)
		effects.water_step(ritual_origin)
	ui.dialogue(lines[point_index], func():
		point_index += 1
		if point_index == Story.POINTS[Beat.LAKE].size():
			_advance()
	)

func _start_echo() -> void :
	timing = Timing.new()
	timing.world = self
	drive_layer.add_child(timing)
	timing.completed.connect(_enter_echo)

func _enter_echo() -> void :
	timing.hide()
	timing.queue_free()
	timing = null
	gamepads.assign(Input.get_connected_joypads(), false)
	echo_ready = true
	reset_raven(SPAWN)
	set_painted_solids("memory")
	set_dressing("")
	_update_lighting()
	player.hide()
	ui.dialogue([["HEILIGTUM", "Eindämmung bricht. Ein Teil des Schwarms geht auf Raven über. Finde die stabilen Erinnerungsanker.", "echo"]])

func saved_checkpoint() -> int:
	var config: = ConfigFile.new()
	if config.load(SAVE) != OK:
		return -1
	var value: Variant = config.get_value("campaign", "beat", -1)
	return value if value is int and value >= Beat.PACT and value <= Beat.END else -1

func autosave() -> void :
	if not save_game():
		toast("Kontrollpunkt konnte nicht gespeichert werden.")

func save_game() -> bool:
	var config: = ConfigFile.new()
	config.set_value("campaign", "beat", beat)
	config.set_value("props", "state", dressing_state())
	return config.save(SAVE) == OK

func load_game(_requested_mode: Variant = null) -> bool:
	var saved: = saved_checkpoint()
	if saved < 0:
		return false
	var config: = ConfigFile.new()
	config.load(SAVE)
	restore_dressing_state(config.get_value("props", "state", {}))
	_enter(saved)
	return true

func _draw() -> void :
	var art: Texture2D = Story.LEVEL_ART[beat]
	if beat == Beat.ECHO and echo_ready:
		art = Painted.ART.memory
	draw_texture_rect(art, Rect2(0, 0, 1024, 640), false)
	if beat == Beat.HANGAR and point_index == 3:
		for port in PORTS:
			draw_rect(Rect2(port - Vector2(12, 9), Vector2(24, 18)), Color("253747"))
			draw_rect(Rect2(port - Vector2(9, 6), Vector2(18, 12)), Color("69dae0") if _signal_open() else Color("b65869"), false, 2)
	if beat == Beat.ECHO and echo_ready:
		for i in 15:
			var p: = Vector2(340 + (i * 83) % 550, 280 + fposmod(i * 34 - clock * 8, 170))
			draw_circle(p, 1.5, Color(0.96, 0.32, 0.45, 0.48))
		var decoy: = Vector2(551, 426)
		draw_arc(decoy, 15, clock * 2.0, clock * 2.0 + PI, 24, Color("a35b7a"), 2)
		draw_line(decoy + Vector2(-7, -2), decoy + Vector2(12, -2), Color("bf6d91"))
	if beat == Beat.ESCAPE:
		var pulse: = 0.06 + 0.08 * (1.0 + sin(clock * 6.0))
		draw_rect(Rect2(0, 216, 1024, 280), Color(0.82, 0.06, 0.14, pulse))
		for x in range(85, 1000, 115):
			draw_polyline(PackedVector2Array([Vector2(x, 466), Vector2(x + 7, 471), Vector2(x, 476)]), Color("df7778"), 2)
	if beat in [Beat.LAKE, Beat.END] and ritual_flash > 0.0:
		draw_set_transform(ritual_origin, 0.0, Vector2(1.0, 0.52))
		draw_arc(Vector2.ZERO, 14.0 + (1.4 - ritual_flash) * 49.0, 0, TAU, 48, Color(0.46, 0.93, 1.0, ritual_flash / 1.4), 2)
		draw_set_transform(Vector2.ZERO)
	if beat in [Beat.LAKE, Beat.END]:
		for i in (18 if visual_quality > 0 else 6):
			var p: = Vector2(105 + i * 127 % 848, 271 + i * 73 % 196)
			p += Vector2(sin(clock * 0.7 + i) * 3.0, cos(clock * 0.9 + i) * 4.0)
			var alpha: = 0.3 + sin(clock * 1.6 + i * 2.0) * 0.22
			draw_circle(p, 1.0 if i % 4 else 1.65, Color(0.62, 0.92, 0.65, alpha))
		if beat == Beat.END or (ritual_flash > 0.0 and point_index == 3):
			var center: Vector2 = player.position.lerp(raven.position, 0.5) - Vector2(0, 23) if beat == Beat.END else ritual_origin - Vector2(0, 21)
			draw_arc(center, 26, 0.06, PI - 0.2, 30, Color("6adddf"), 1.7)
			draw_arc(center + Vector2(0, 5), 28, PI + 0.15, TAU - 0.1, 30, Color("df5b76"), 1.7)
	if beat == Beat.BOSS and not foes.is_empty():
		var boss: PixelActor = foes.back()
		if boss.health > 0 and boss.health <= 180 and fposmod(clock, 3.0) <= 1.45:
			draw_circle(boss.position + Vector2(8, -34), 4.0, Color("72eff4"))
	var point: = _target()
	if point != Vector2.ZERO:
		var signal_color: = Color("f45d79") if _timed_node() and not _signal_open() else Color("72eff4")
		draw_circle(point, 12.0, signal_color, false, 2)
		var tip: = point + Vector2(0, -31.0 + sin(clock * 5.0) * 3.0)
		draw_polyline(PackedVector2Array([tip + Vector2(-6, -5), tip, tip + Vector2(6, -5)]), signal_color, 2)
