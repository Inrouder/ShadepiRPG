extends "res://scripts/main.gd"

enum Section{YARD, HIDEOUT, DIVE, RECOVERY, END, COOLING}

const ChapterHud = preload("res://scripts/chapter_two_hud.gd")
const SLOT: = "user://shadepi-chapter-two.cfg"
const YARD_START: = Vector2(145, 420)
const DOOR: = Vector2(876, 295)
const WORKBENCH: = Vector2(498, 311)
const SPRAY: = Vector2(530, 405)
const Threat = preload("res://scripts/dive_threat.gd")
const BATH: = Vector2(670, 361)
const SCANS: Array[Vector2] = [Vector2(289, 311), Vector2(504, 442), Vector2(744, 316)]
const RELAYS: Array[Vector2] = [Vector2(350, 430), Vector2(552, 300), Vector2(812, 414)]

var section: = Section.YARD
var scan_index: = 0
var relay_index: = 0
var ice_cycle: = 0.0
var dive_hold: = 0.0
var spray_ready: = false
var threats: Array[Node2D] = []
var next_wave: = false
var previous_ice_open: = false

func create_hud() -> CanvasLayer:
	return ChapterHud.new()

func _ready() -> void :
	super._ready()
	if Admin.consume_chapter(get_tree(), "res://scenes/chapter_two.tscn") == 2:
		new_game(false)
	elif ChapterFlow.consume_entry(get_tree(), "res://scenes/chapter_two.tscn") or not load_game():
		new_game()

func world_props() -> Array[Dictionary]:
	return []

func world_walls() -> Array[Rect2]:
	return [Rect2(-20, 0, 20, 640), Rect2(1024, 0, 20, 640)]

func _build_world() -> void :
	super._build_world()
	set_gate(true)
	enemy.hide()
	ground_atmosphere.hide()
	raven.hide()
	player.position = YARD_START

func raven_leads() -> bool:
	return section == Section.DIVE

func actor_is_playable(actor: PixelActor) -> bool:
	if section == Section.END:
		return false
	return actor == (raven if raven_leads() else player)

func actor_input_prefix(_actor: PixelActor) -> String:
	return ""

func _update_raven_follower(_delta: float) -> void :
	pass

func _process(delta: float) -> void :
	super._process(delta)
	if raven_leads():
		camera.position = raven.position + Vector2(0, -45)
		if not is_busy():
			ice_cycle = fposmod(ice_cycle + delta, 2.4)
			if _ice_open() != previous_ice_open and raven.position.distance_to(_target()) < 75.0:
				sound("hack" if _ice_open() else "hit")
			previous_ice_open = _ice_open()
			if dive_hold > 0.0:
				if raven.position.distance_to(_target()) >= 48.0:
					dive_hold = 0.0
				else:
					dive_hold -= delta
					if dive_hold <= 0.0:
						_finish_download()

func new_game(save_checkpoint: bool = true) -> void :
	restore_dressing_state({})
	_enter(Section.YARD)
	if save_checkpoint:
		autosave()
	ui.dialogue([
		["INDUSTRIEGEBIET / DOWNTOWN", "Die Datenkarte führt zu einem stillgelegten Werk. Hinter einer Stahltür läuft noch Strom.", "industrie"], 
		["SHADEPI", "Erst die Umgebung scannen. Dann klopfe ich an.", "industrie"], 
	])

func _enter(next: Section, saved_relay: int = 0) -> void :
	section = next
	match section:
		Section.YARD:
			set_music_section("chapter_2_industry")
		Section.DIVE:
			set_music_section("chapter_2_dive")
		Section.RECOVERY, Section.COOLING, Section.END:
			set_music_section("chapter_2_recovery")
		_:
			set_music_section("chapter_2_hideout")
	set_dressing("industry" if next == Section.YARD else "dive" if next == Section.DIVE else "hideout")
	set_painted_solids("industry" if next == Section.YARD else "dive" if next == Section.DIVE else "hideout")
	stage = 0
	scan_index = 0
	relay_index = clampi(saved_relay, 0, RELAYS.size() - 1) if next == Section.DIVE else 0
	for threat in threats:
		threat.hide()
		threat.set_process(false)
		threat.queue_free()
	threats.clear()
	dive_hold = 0.0
	spray_ready = false
	next_wave = false
	previous_ice_open = false
	ice_cycle = 0.0
	ui.clear_dialogue()
	player.position = YARD_START if section == Section.YARD else Vector2(440, 430)
	player.health = 100
	player.energy = 100.0
	hack_cooldown = 0.0
	player.reset_transients()
	reset_raven((Vector2(145, 436) if relay_index == 0 else RELAYS[relay_index - 1]) if raven_leads() else BATH)
	raven.modulate = Color(0.57, 0.92, 1.0, 0.56) if raven_leads() else Color.WHITE
	if raven_leads():
		_spawn_ice()
	player.visible = not raven_leads()
	raven.visible = section != Section.YARD
	effects.rain = section == Section.YARD
	effects.steam_vents.clear()
	if effects.rain:
		effects.steam_vents.append(Vector2(855, 269))
		set_scene_lighting(Color("bac5b5"), [[DOOR - Vector2(10, 50), "adbd76", 2.7, 0.73], [Vector2(497, 360), "6f96a6", 2.6, 0.3]])
	elif raven_leads():
		set_scene_lighting(Color("c1b1ed"), [[RELAYS[1], "ba436a", 2.9, 0.46], [RELAYS[2], "6370c8", 3.1, 0.6]])
	else:
		set_scene_lighting(Color("afbecb"), [[BATH, "6fcbda", 2.2, 0.85], [WORKBENCH, "7780b8", 1.8, 0.46]])
	close_menu()

func _target() -> Vector2:
	match section:
		Section.YARD:
			return SCANS[scan_index] if scan_index < SCANS.size() else DOOR
		Section.HIDEOUT:
			return WORKBENCH
		Section.DIVE:
			return RELAYS[relay_index]
		Section.RECOVERY:
			return BATH if spray_ready else SPRAY
		Section.COOLING:
			return BATH
	return Vector2.ZERO

func chapter_objective() -> String:
	match section:
		Section.YARD:
			return "Umgebung scannen · %d / 3" % scan_index if scan_index < SCANS.size() else "An der Stahltür klopfen"
		Section.HIDEOUT:
			return "Raven das Metallfragment zeigen"
		Section.DIVE:
			return "Datenspur verfolgen · %d / 3" % relay_index
		Section.RECOVERY:
			return "Raven mit Kryospray stabilisieren" if spray_ready else "Kryospray am Überwachungstisch holen"
		Section.COOLING:
			return "Raven an das Kühlsystem anschließen"
	return "Kapitel 2 abgeschlossen"

func _ice_open() -> bool:
	return (ice_cycle >= 1.0 and ice_cycle <= 1.4) if relay_index == 0 else ice_cycle < 0.95

func interaction_prompt() -> String:
	if section == Section.END:
		return "E / A · Weiter zu Kapitel 3"
	var target: = _target()
	var actor: PixelActor = raven if raven_leads() else player
	if target == Vector2.ZERO or actor.position.distance_to(target) >= 48.0:
		return ""
	if raven_leads():
		if not threats.is_empty():
			return "ICE-Abwehr · J / X  |  Pfosten hacken · Q / RB" if relay_index == 2 else "ICE-Abwehr ausschalten · J / X"
		if dive_hold > 0.0:
			return "Verbindung halten"
		return "E / A · ICE treffen" if _ice_open() else "ICE scannt · auf Cyan warten"
	return "E / A · " + chapter_objective()

func interact(_actor: PixelActor = null) -> void :
	if section == Section.END and not is_busy():
		ChapterFlow.advance(get_tree(), "res://scenes/campaign.tscn")
		return
	if is_busy() or interaction_prompt().is_empty():
		return
	match section:
		Section.YARD:
			if scan_index < SCANS.size():
				toast(["Fluchtweg frei.", "Keine Wärmesignaturen am Gerüst.", "Stahltür lokalisiert."][scan_index])
				scan_index += 1
			else:
				_enter(Section.HIDEOUT)
				autosave()
				ui.dialogue([
					["RAVEN", "Drei Schläge. Du bist spät dran, Ninja.", "versteck"], 
					["SHADEPI", "Du hast keine Uhrzeit genannt.", "versteck"], 
				])
		Section.HIDEOUT:
			ui.dialogue([
				["SHADEPI", "Militech Minotaurus XC2534S. Das Fragment stammt von einem der Mechs. Ich suche den Betreiber.", "versteck"], 
				["SHADEPI", "Vor fünf Jahren wurde der Orden der Weißen Drachen ausgelöscht. Ich bin der Letzte.", "versteck"], 
				["RAVEN", "Dann sehe ich nach, wer die Maschinen bezahlt hat. Im Eisbad kann ich tiefer ins Netz. Behalte meine Werte im Blick.", "versteck"], 
			], func():
				_enter(Section.COOLING)
				autosave()
			)
		Section.DIVE:
			_trace_relay()
		Section.COOLING:
			_enter(Section.DIVE)
			autosave()
		Section.RECOVERY:
			if spray_ready:
				_finish_chapter()
			else:
				spray_ready = true
				toast("Kryospray aufgenommen.")

func _spawn_ice() -> void :
	var positions: Array[Vector2] = []
	if relay_index == 1:
		positions.assign([Vector2(500, 320)] if not next_wave else [Vector2(478, 330), Vector2(550, 367)])
	elif relay_index == 2:
		positions.assign([Vector2(805, 372), Vector2(830, 435)])
	for i in positions.size():
		var threat: = Threat.new()
		threat.world = self
		threat.guardian = relay_index == 2 and i == 0
		threat.position = positions[i]
		actors.add_child(threat)
		threats.append(threat)

func raven_shot() -> void :
	if not raven_leads():
		return
	var origin: Vector2 = raven.position
	var endpoint: Vector2 = origin + raven.facing * 152.0
	var wall: = trace_scenery(origin, endpoint)
	if not wall.is_empty():
		endpoint = wall.position
	var hit_threat: Node2D
	var best: float = origin.distance_to(endpoint)
	for threat in threats:
		var offset: Vector2 = threat.position - origin
		var depth: float = offset.dot(raven.facing)
		if depth > 0.0 and depth < best and absf(offset.cross(raven.facing)) < 16.0 and _line_clear(origin, threat.position):
			best = depth
			hit_threat = threat
	if hit_threat != null:
		endpoint = origin + raven.facing * best
		if hit_threat.vulnerable():
			effects.burst(hit_threat.position, Color("97f7ff"), 24)
			threats.erase(hit_threat)
			hit_threat.set_process(false)
			hit_threat.queue_free()
			if threats.is_empty() and relay_index == 1 and not next_wave:
				next_wave = true
				_spawn_ice()
		else:
			toast("Hülle geladen. Die Entladung abwarten.")
	elif not wall.is_empty() and wall.collider is WorldProp:
		wall.collider.take_damage(17)
	effects.pulse_trace(origin, endpoint)
	sound("hack")

func raven_hack() -> bool:
	if not raven_leads() or is_busy() or hack_cooldown > 0.0:
		return false
	for threat in threats:
		if threat.guardian and minf(raven.position.distance_to(threat.position + Vector2(-115, 0)), raven.position.distance_to(threat.position + Vector2(115, 0))) < 110.0:
			threat.elapsed = 1.4
			hack_cooldown = 4.0
			effects.hack_arc(raven.position, threat.position)
			sound("hack")
			return true
	return false

func admin_defeat_enemies() -> int:
	var amount := super.admin_defeat_enemies()
	if section == Section.DIVE:
		amount += threats.size()
		for threat in threats:
			threat.set_process(false)
			threat.queue_free()
		threats.clear()
		next_wave = true
	return amount

func player_defeated() -> void :
	_enter.call_deferred(section, relay_index)

func _trace_relay() -> void :
	if not threats.is_empty() or dive_hold > 0.0:
		return
	if not _ice_open():
		toast("ICE hat den Zugriff blockiert. Versuch es beim nächsten cyanfarbenen Signal.")
		return
	effects.burst(raven.position, Color("5fe8fa"), 26)
	sound("hack")
	if relay_index == 2:
		dive_hold = 0.55
		return
	relay_index += 1
	autosave()
	_spawn_ice()
	toast(["Seriennummer bestätigt. Zahlungsweg suchen.", "Zahlungsweg gesichert. Verdecktes Projekt gefunden."][relay_index - 1])

func _finish_download() -> void :
	effects.burst(raven.position, Color("b992ff"), 55)
	_enter(Section.RECOVERY)
	autosave()
	shake = 8.0
	effects.burst(BATH, Color("f35075"), 32)
	ui.dialogue([
		["SHADEPIS HUD", "HEILIGTUM / Eindämmung bei 85 %. Nanitenschwarm reagiert auf das Feld.", "rueckkehr"],
		["SYSTEM", "Verbindung abgebrochen. Zurück im Versteck: Ravens Temperatur steigt. Hole das Kryospray.", "rueckkehr"],
	])

func _finish_chapter() -> void :
	effects.burst(BATH, Color("a3eafa"), 30)
	ui.dialogue([
		["RAVEN", "Kenzō Moriyama. Die Spur der Minotauren führt zu einem seiner verdeckten Arasaka-Projekte.", "rueckkehr"], 
		["RAVEN", "Ob er den Angriff befohlen hat, weiß ich nicht. Aber ich stehe selbst auf seiner Liste. Bleib lieber weg von ihm.", "rueckkehr"], 
		["SHADEPI", "Ich lasse nicht zu, dass dir etwas geschieht. Ich finde heraus, wer dafür verantwortlich ist. Das schwöre ich dir.", "rueckkehr"], 
		["KAPITEL 2 / ENDE", "Auf den Monitoren bleibt ein Name stehen. Kenzō Moriyama.", "rueckkehr"], 
	], func():
		_enter(Section.END)
		autosave()
	)

func saved_checkpoint() -> int:
	var config: = ConfigFile.new()
	if config.load(Admin.checkpoint_path(SLOT, get_tree())) != OK:
		return -1
	var value: Variant = config.get_value("chapter", "section", -1)
	return value if value is int and value >= Section.YARD and value <= Section.COOLING else -1

func autosave() -> void :
	if not save_game():
		toast("Kontrollpunkt konnte nicht gespeichert werden.")

func save_game() -> bool:
	var config: = ConfigFile.new()
	config.set_value("chapter", "section", section)
	config.set_value("chapter", "relay", relay_index)
	config.set_value("props", "state", dressing_state())
	return config.save(Admin.checkpoint_path(SLOT, get_tree())) == OK

func load_game(_requested_mode: Variant = null) -> bool:
	var saved: = saved_checkpoint()
	if saved < 0:
		return false
	var config: = ConfigFile.new()
	config.load(Admin.checkpoint_path(SLOT, get_tree()))
	restore_dressing_state(config.get_value("props", "state", {}))
	_enter(saved as Section, int(config.get_value("chapter", "relay", 0)))
	return true

func _draw() -> void :
	var net: = raven_leads()
	var tint: = Color("225b70") if net else Color("353f4e")
	var accent: = (Color("69ecff") if _ice_open() else Color("ff537e")) if net else Color("b5c575") if section == Section.YARD else Color("6dc6b6")
	if section == Section.YARD:
		draw_texture_rect(Painted.ART.industry, Rect2(0, 0, 1024, 640), false)
	elif net:
		draw_texture_rect(Painted.ART.dive, Rect2(0, 0, 1024, 640), false)
		if not _ice_open():
			var scan_y: = 271.0 + fposmod(ice_cycle * 114.0, 211.0)
			draw_rect(Rect2(0, scan_y, 1024, 2), Color(0.76, 0.16, 0.33, 0.45))
			draw_rect(Rect2(0, scan_y - 5, 1024, 5), Color(0.62, 0.1, 0.24, 0.18))
		draw_polyline(PackedVector2Array(RELAYS), accent.darkened(0.64), 1.0)
		var avatar: Vector2 = raven.position - Vector2(0, 24)
		for y in range(-17, 16, 5):
			draw_line(avatar + Vector2(-8, y), avatar + Vector2(8, y), Color(0.3, 0.84, 1.0, 0.38))
		if relay_index == 0 and raven.position.distance_to(RELAYS[0]) < 75.0:
			var gauge: = RELAYS[0] + Vector2(-48, -66)
			draw_rect(Rect2(gauge, Vector2(96, 8)), Color("221b37"))
			draw_rect(Rect2(gauge + Vector2(40, 0), Vector2(16, 8)), Color("45cad8"))
			draw_rect(Rect2(gauge + Vector2(ice_cycle * 40.0, -2), Vector2(2, 12)), Color.WHITE)
		for i in RELAYS.size():
			draw_circle(RELAYS[i], 15, accent.darkened(0.65) if i < relay_index else tint, false, 2)
	else:
		draw_texture_rect(Painted.ART.hideout, Rect2(0, 0, 1024, 640), false)
		if section == Section.RECOVERY:
			draw_rect(Rect2(SPRAY + Vector2(-4, -11), Vector2(8, 11)), tint if spray_ready else Color("a5e3e8"))
	var marker: = _target()
	if marker != Vector2.ZERO:
		draw_arc(marker, 14.0, 0, TAU, 24, accent, 1.5)
		var tip: = marker + Vector2(0, -40 + sin(Time.get_ticks_msec() * 0.006) * 3)
		draw_polyline(PackedVector2Array([tip + Vector2(-5, -5), tip, tip + Vector2(5, -5)]), accent, 2)
