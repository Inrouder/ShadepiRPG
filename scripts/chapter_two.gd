extends "res://scripts/main.gd"

enum Section { YARD, HIDEOUT, DIVE, RECOVERY, END }

const ChapterHud = preload("res://scripts/chapter_two_hud.gd")
const SLOT := "user://shadepi-chapter-two.cfg"
const YARD_START := Vector2(145, 450)
const DOOR := Vector2(876, 295)
const WORKBENCH := Vector2(498, 311)
const BATH := Vector2(670, 361)
const SCANS: Array[Vector2] = [Vector2(289, 311), Vector2(504, 442), Vector2(744, 316)]
const RELAYS: Array[Vector2] = [Vector2(350, 430), Vector2(552, 300), Vector2(812, 414)]
const BLOCKS: Array[Rect2] = [Rect2(355, 263, 67, 128), Rect2(600, 386, 58, 107)]

var section := Section.YARD
var scan_index := 0
var relay_index := 0
var ice_cycle := 0.0

func create_hud() -> CanvasLayer:
	return ChapterHud.new()

func _ready() -> void:
	super._ready()
	if not load_game():
		new_game()

func world_props() -> Array[Dictionary]:
	return []

func world_walls() -> Array[Rect2]:
	var walls: Array[Rect2] = [
		Rect2(0, 0, 1024, 253), Rect2(0, 495, 1024, 145),
		Rect2(-20, 0, 20, 640), Rect2(1024, 0, 20, 640),
	]
	walls.append_array(BLOCKS)
	return walls

func _build_world() -> void:
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

func _update_raven_follower(_delta: float) -> void:
	pass

func _process(delta: float) -> void:
	super._process(delta)
	if raven_leads():
		camera.position = raven.position + Vector2(0, -45)
		if not is_busy():
			ice_cycle = fposmod(ice_cycle + delta, 2.4)

func new_game(save_checkpoint: bool = true) -> void:
	_enter(Section.YARD)
	if save_checkpoint:
		autosave()
	ui.dialogue([
		["INDUSTRIEGEBIET / DOWNTOWN", "Die Datenkarte führt zu einem stillgelegten Werk. Hinter einer Stahltür läuft noch Strom.", "industrie"],
		["SHADEPI", "Erst die Umgebung scannen. Dann klopfe ich an.", "industrie"],
	])

func _enter(next: Section) -> void:
	section = next
	stage = 0
	scan_index = 0
	relay_index = 0
	ice_cycle = 0.0
	ui.dialogue_open = false
	ui.dialogue_panel.hide()
	player.position = YARD_START if section == Section.YARD else Vector2(440, 430)
	player.reset_transients()
	reset_raven(Vector2(145, 436) if raven_leads() else BATH)
	player.visible = not raven_leads()
	raven.visible = section != Section.YARD
	effects.rain = section == Section.YARD
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
			return "Raven mit Kryospray stabilisieren"
	return "Kapitel 2 abgeschlossen"

func _ice_open() -> bool:
	return ice_cycle < 0.95

func interaction_prompt() -> String:
	if section == Section.END:
		return "E / A · Weiter zu Kapitel 3"
	var target := _target()
	var actor: PixelActor = raven if raven_leads() else player
	if target == Vector2.ZERO or actor.position.distance_to(target) >= 48.0:
		return ""
	if raven_leads():
		return "E / A · Daten abgreifen" if _ice_open() else "ICE scannt · auf Cyan warten"
	return "E / A · " + chapter_objective()

func interact(_actor: PixelActor = null) -> void:
	if section == Section.END and not is_busy():
		get_tree().change_scene_to_file("res://scenes/campaign.tscn")
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
				_enter(Section.DIVE)
				autosave()
			)
		Section.DIVE:
			_trace_relay()
		Section.RECOVERY:
			_finish_chapter()

func _trace_relay() -> void:
	if not _ice_open():
		toast("ICE hat den Zugriff blockiert. Versuch es beim nächsten cyanfarbenen Signal.")
		return
	effects.burst(raven.position, Color("5fe8fa"), 26)
	sound("hack")
	relay_index += 1
	if relay_index < RELAYS.size():
		toast(["Seriennummer bestätigt. Zahlungsweg gefunden.", "Verdecktes Arasaka-Projekt. Jemand prüft die Verbindung."][relay_index - 1])
		return
	_enter(Section.RECOVERY)
	autosave()
	shake = 8.0
	effects.burst(BATH, Color("f35075"), 32)
	ui.dialogue([
		["SHADEPIS HUD", "HEILIGTUM / Eindämmung bei 85 %. Nanitenschwarm reagiert auf das Feld.", "netz"],
		["SYSTEM", "Verbindung abgebrochen. Ravens Temperatur steigt.", "netz"],
	])

func _finish_chapter() -> void:
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
	var config := ConfigFile.new()
	if config.load(SLOT) != OK:
		return -1
	var value: Variant = config.get_value("chapter", "section", -1)
	return value if value is int and value >= Section.YARD and value <= Section.END else -1

func autosave() -> void:
	save_game()

func save_game() -> bool:
	var config := ConfigFile.new()
	config.set_value("chapter", "section", section)
	return config.save(SLOT) == OK

func load_game(_requested_mode: Variant = null) -> bool:
	var saved := saved_checkpoint()
	if saved < 0:
		return false
	_enter(saved as Section)
	return true

func _draw() -> void:
	var net := raven_leads()
	var tint := Color("225b70") if net else Color("353f4e")
	var accent := (Color("69ecff") if _ice_open() else Color("ff537e")) if net else Color("b5c575") if section == Section.YARD else Color("6dc6b6")
	draw_rect(Rect2(0, 0, 1024, 640), Color("0b1830") if net else Color("172125"))
	for y in range(260, 495, 13):
		draw_line(Vector2(0, y), Vector2(1024, y), tint)
		for x in range(y % 32, 1024, 48):
			draw_line(Vector2(x, y), Vector2(x + 7, y + 13), tint.darkened(0.27))
	draw_rect(Rect2(0, 213, 1024, 40), tint)
	for x in range(18, 1024, 72):
		draw_rect(Rect2(x, 226, 42, 7), accent.darkened(0.35))
	for block in BLOCKS:
		draw_rect(block, tint.darkened(0.35))
		draw_rect(block.grow(-3), tint, false, 2)
		for y in range(int(block.position.y) + 10, int(block.end.y), 10):
			draw_line(Vector2(block.position.x + 5, y), Vector2(block.end.x - 5, y), tint)
	if section == Section.YARD:
		draw_rect(Rect2(DOOR - Vector2(28, 77), Vector2(56, 53)), tint)
		draw_string(ThemeDB.fallback_font, DOOR - Vector2(54, 85), "WERK / DOWNTOWN", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, accent)
	elif net:
		for i in range(0, 1024, 38):
			var height := 20 + (i * 19) % 115
			draw_rect(Rect2(i, 219 - height, 24, height), tint.darkened(0.55))
			draw_line(Vector2(i, 219 - height), Vector2(i + 24, 219 - height), accent.darkened(0.4))
		draw_polyline(PackedVector2Array(RELAYS), accent.darkened(0.64), 1.0)
		for i in RELAYS.size():
			draw_circle(RELAYS[i], 15, accent.darkened(0.65) if i < relay_index else tint, false, 2)
	else:
		for x in range(75, 1024, 154):
			draw_rect(Rect2(x, 256, 98, 28), tint.darkened(0.4))
			for i in 3:
				draw_rect(Rect2(x + 7 + i * 29, 260, 25, 17), accent.darkened(0.64))
				draw_line(Vector2(x + 9 + i * 29, 268), Vector2(x + 24 + i * 29, 268), accent)
		draw_polyline(PackedVector2Array([Vector2(507, 282), Vector2(563, 325), Vector2(636, 325), BATH]), Color("161c27"), 4.0)
		for x in [466, 491, 516]:
			draw_rect(Rect2(x, 270, 22, 14), accent)
			draw_rect(Rect2(x + 2, 272, 18, 10), tint)
		draw_rect(Rect2(BATH - Vector2(24, 19), Vector2(48, 32)), accent, false, 2)
		draw_rect(Rect2(BATH - Vector2(21, 16), Vector2(42, 26)), tint)
	var marker := _target()
	if marker != Vector2.ZERO:
		draw_arc(marker, 14.0, 0, TAU, 24, accent, 1.5)
		var tip := marker + Vector2(0, -40 + sin(Time.get_ticks_msec() * 0.006) * 3)
		draw_polyline(PackedVector2Array([tip + Vector2(-5, -5), tip, tip + Vector2(5, -5)]), accent, 2)
