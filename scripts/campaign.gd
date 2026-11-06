extends "res://scripts/main.gd"

const Story = preload("res://scripts/campaign_story.gd")
const Beat = Story.Beat
const Timing = preload("res://scripts/sanctuary_timing.gd")
const Drive = preload("res://scripts/campaign_drive.gd")
const ChapterHud = preload("res://scripts/campaign_hud.gd")
const Arcade = preload("res://scripts/arcade_encounter.gd")
const Waves = preload("res://scripts/arcade_waves.gd")
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
const PORTS: = [Vector2(725, 359), Vector2(785, 350), Vector2(842, 367)]
var clock: = 0.0
var countdown: = 60.0
var ritual_flash: = 0.0
var lift_glow: = 0.0
var ritual_origin: = Vector2.ZERO
var foes: Array[PixelActor] = []
var drive: Node2D
var timing: Node2D
var echo_ready: = false
var drive_layer: CanvasLayer
var encounter: Node2D
## False between Kenzō's fall and the last lift-guard wave of the escape.
var escape_guards_cleared: = true
var fresh_entry: = false
var kenzo_body: PixelActor
var boss_spot: = Vector2(858, 340)
const LIFT_DOOR: = Vector2(512, 512)
const KENZO: = preload("res://assets/sprites/npcs/kenzo.png")

func create_hud() -> CanvasLayer:
	return ChapterHud.new()

func _ready() -> void :
	super._ready()
	var admin_chapter: int = Admin.consume_chapter(get_tree(), "res://scenes/campaign.tscn")
	if admin_chapter >= 3:
		restore_dressing_state({})
		fresh_entry = true
		_enter(Admin.first_beat(admin_chapter))
	elif ChapterFlow.consume_entry(get_tree(), "res://scenes/campaign.tscn") or not load_game():
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

func combat_ready() -> bool:
	return is_combat()

func is_combat() -> bool:
	return beat in [Beat.AMBUSH, Beat.BOSS] or (beat == Beat.ESCAPE and not escape_guards_cleared)

func _process(delta: float) -> void :
	super._process(delta)
	if raven_leads() and not in_cinematic():
		camera.position = raven.position + Vector2(0, -52)
	if beat == Beat.ECHO and not echo_ready and not in_cinematic():
		camera.position = Painted.CHAMBER_CAMERA
	ritual_flash = maxf(0.0, ritual_flash - delta)
	lift_glow = maxf(0.0, lift_glow - delta * 0.6)
	if is_busy():
		return
	clock += delta
	if beat == Beat.ESCAPE and escape_guards_cleared and not admin_enabled("freeze_timer"):
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
	fresh_entry = true
	_enter(Beat.PACT)

func _enter(next: int, saved_section: int = 0, saved_point: int = 0) -> void :
	var fresh: = fresh_entry
	fresh_entry = false
	cutscene.abort()
	ui.clear_toast()
	cancel_terminal()
	if beat == Beat.BOSS and not foes.is_empty():
		boss_spot = foes.back().position
	if is_instance_valid(kenzo_body):
		kenzo_body.queue_free()
	kenzo_body = null
	if is_instance_valid(encounter):
		remove_child(encounter)
		encounter.queue_free()
	encounter = null
	if is_instance_valid(timing):
		timing.hide()
		timing.queue_free()
		timing = null
		gamepads.assign(Input.get_connected_joypads(), false)
	echo_ready = false
	camera.zoom = Vector2.ONE * (1.15 if next == Beat.ECHO else 1.0)
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
	var music_sections := [
		"chapter_3_pact", "chapter_3_ambush", "chapter_3_chase",
		"chapter_4_garage", "chapter_4_hangar", "chapter_5_sanctuary",
		"chapter_6_flight", "chapter_6_tower", "chapter_6_boss",
		"chapter_6_escape", "chapter_7_lake", "chapter_7_finale",
	]
	set_music_section(music_sections[beat])
	var layouts: = ["hideout", "ambush", "", "garage", "hangar", "chamber", "", "roof", "suite", "suite", "lake", "lake"]
	set_dressing(layouts[beat])
	stage = 0
	point_index = 0
	if beat in [Beat.GARAGE, Beat.HANGAR, Beat.ROOF, Beat.ESCAPE]:
		point_index = clampi(saved_point, 0, 3 if beat in [Beat.HANGAR, Beat.ESCAPE] else 1)
	clock = 0.0
	countdown = 60.0
	ritual_flash = 0.0
	hack_cooldown = 0.0
	player.health = 100
	player.energy = 100.0
	player.position = PACT_SPAWN if beat == Beat.PACT else SPAWN
	if point_index > 0:
		player.position = Story.POINTS[beat][mini(point_index, Story.POINTS[beat].size() - 1)] + Vector2(-45, 20)
	if beat == Beat.ECHO:
		player.position = Painted.chamber_point(SPAWN)
		camera.position = Painted.CHAMBER_CAMERA
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
	if beat in [Beat.CHASE, Beat.FLIGHT]:
		drive = Drive.new()
		drive.world = self
		drive.flight = beat == Beat.FLIGHT
		drive_layer.add_child(drive)
		drive.completed.connect(_advance)
		drive.crashed.connect( func(): _retry("Landung abgebrochen · Kontrollpunkt" if beat == Beat.FLIGHT else "Fahrzeug ausgefallen · Kontrollpunkt"))
	if beat != Beat.ESCAPE:
		escape_guards_cleared = true
	elif fresh:
		escape_guards_cleared = false
	if beat == Beat.ESCAPE:
		_spawn_kenzo_body(boss_spot, escape_guards_cleared or not fresh)
		set_music_section("chapter_6_escape" if escape_guards_cleared else ("chapter_6_boss" if fresh else "fight"))
	if is_combat() and not (beat == Beat.ESCAPE and fresh):
		_spawn_wave(saved_section)
	autosave()
	_beat_scene(fresh)

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
				set_scene_lighting(Color("bdacba"), [[Painted.chamber_point(Vector2(446, 258)), "e4ae87", 1.32, 0.62], [Painted.chamber_point(Vector2(682, 259)), "70b0ce", 1.48, 0.62]])
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
		fresh_entry = true
		_enter(beat + 1)

func _retry(title: String) -> void :
	var saved_section: int = encounter.section_index if encounter != null else 0
	_enter(beat, saved_section, point_index)
	menu_open = true
	ui.show_menu(title)

func _spawn_wave(saved_section: int = 0) -> void :
	if beat == Beat.BOSS:
		_spawn_foe(Vector2(858, 340), 360, -1)
		return
	var plan: Array = Waves.LIFT if beat == Beat.ESCAPE else Waves.AMBUSH
	var index := clampi(saved_section, 0, plan.size() - 1)
	if saved_section > 0:
		player.position = plan[index].start
		reset_raven(player.position + Vector2(-20, 10))
	encounter = Arcade.new()
	add_child(encounter)
	encounter.configure(self, plan, _spawn_arcade_foe, index)
	encounter.section_changed.connect(autosave)
	encounter.completed.connect(func():
		if beat == Beat.ESCAPE:
			_escape_guards_done.call_deferred()
		else:
			toast("ALLE ABSCHNITTE FREI · Zum Motorrad →")
	)

func _spawn_arcade_foe(point: Vector2, variant: int) -> PixelActor:
	return _spawn_foe(point, 64 if beat == Beat.AMBUSH else 72, variant)

func _spawn_foe(point: Vector2, hp: int, variant: int) -> PixelActor:
	var foe: = EnemyScript.new()
	foe.max_health = hp
	var sprite: Texture2D = SHOOTERS[variant] if beat == Beat.AMBUSH and variant < 2 else (GUARDS[variant] if variant >= 0 else preload("res://assets/sprites/npcs/kenzo.png"))
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
	if beat == Beat.ESCAPE and variant == 2:
		foe.front_shield = true
	foes.append(foe)
	return foe

func combat_target(origin: Vector2, include_cloaked: bool = false) -> PixelActor:
	return super.combat_target(origin, include_cloaked) if is_combat() else null

func player_strike(amount: int) -> void :
	strike_scenery(player.position, player.facing, amount)
	if not is_combat():
		return
	for foe in foes:
		if foe.health > 0 and CombatRules.can_strike(player.position, player.facing, foe.position) and _line_clear(player.position, foe.position):
			foe.take_damage(amount, player.position)

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
	if encounter != null and not encounter.finished:
		return
	if _living() != 0:
		return
	if beat == Beat.BOSS:
		_finish_encounter.call_deferred(beat)
	elif beat == Beat.AMBUSH:
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
		return PORTS[1]
	if beat == Beat.ECHO and echo_ready and point_index < Painted.ECHO_POINTS.size():
		return Painted.ECHO_POINTS[point_index]
	if (encounter != null and not encounter.finished) or (is_combat() and _living() > 0) or point_index >= Story.POINTS[beat].size():
		return Vector2.ZERO
	return Story.POINTS[beat][point_index]

func _timed_node() -> bool:
	return (beat == Beat.HANGAR and point_index in [1, 2]) or (beat == Beat.ESCAPE and point_index in [0, 2])

func _terminal_context() -> String:
	if beat == Beat.GARAGE and point_index == 1: return "garage"
	if beat == Beat.HANGAR and point_index == 0: return "power"
	if beat == Beat.HANGAR and point_index == 3: return "transponder"
	if beat == Beat.ROOF and point_index == 0: return "roof_signal"
	if beat == Beat.ROOF and point_index == 1: return "penthouse"
	if beat == Beat.ESCAPE and point_index == 1: return "charge"
	return ""

func _signal_open() -> bool:
	return fposmod(clock, 2.1) < 1.0

func chapter_objective() -> String:
	if encounter != null and not encounter.finished:
		return encounter.status_text()
	match beat:
		Beat.AMBUSH:
			return "Hinterhalt · %d Gegner" % _living() if _living() else "Zum Motorrad"
		Beat.ECHO:
			return "Erinnerungen ordnen · %d / 3" % point_index if echo_ready else "Heiligtum am Sessel prüfen"
		Beat.GARAGE:
			return "Raven: Zugangscode entschlüsseln" if point_index == 1 else Story.OBJECTIVES[beat]
		Beat.HANGAR:
			if point_index == 3:
				return "Raven: Prüf-ICE per Matrix umgehen"
			return Story.OBJECTIVES[beat] %point_index
		Beat.ROOF:
			return ["Kennung am Dachterminal prüfen", "Penthouse-Zugang öffnen"][mini(point_index, 1)]
		Beat.PACT:
			return Story.OBJECTIVES[beat] %point_index
		Beat.BOSS:
			var hp: int = foes.back().health if not foes.is_empty() else 360
			return "Kenzō · %d / 360 HP%s" % [hp, " · Hackfenster" if hp <= 180 and fposmod(clock, 3.0) <= 1.45 else ""]
		Beat.LAKE:
			return ["Mit Raven am Ufer sprechen", "Bitte am Wasser sprechen", "Antwort des Heiligtums hören", "Aufnahme vollziehen"][point_index]
		Beat.ESCAPE:
			return "%s · %02d s" % [["Daten sichern", "Sperrladung synchronisieren", "Treibstoffpumpe fernstarten", "Zum Dachausgang"][point_index], ceili(countdown)]
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
	if target == Vector2.ZERO or actor.position.distance_to(target) > 43.0:
		return ""
	if not _terminal_context().is_empty():
		return "E / A · Ravens Terminal öffnen"
	if _timed_node():
		return "E / A · Daten abgreifen" if _signal_open() else "ICE scannt · auf Cyan warten"
	return "E / A · " + chapter_objective()

func _hangar_prop() -> String:
	for item in [[Vector2(193, 289), "Klingen ansehen"], [Vector2(476, 293), "Ersatzteile ansehen"], [Vector2(899, 330), "Aerodyne ansehen"]]:
		if raven.position.distance_to(item[0]) <= 24.0:
			return item[1]
	return ""

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
			_scene_echo_end()
			return
	if beat == Beat.GARAGE and point_index == 1 and raven.position.distance_to(_target()) > 35.0:
		toast("Warte auf Raven.")
		return
	if beat == Beat.HANGAR and not _hangar_prop().is_empty():
		toast(_hangar_prop() + " · Bestände des Ordens.")
		return
	var context := _terminal_context()
	if not context.is_empty():
		var expected_beat := beat
		var expected_point := point_index
		open_terminal(context, func():
			if beat != expected_beat or point_index != expected_point:
				return
			if beat == Beat.HANGAR and point_index == 3:
				_advance()
			else:
				_complete_point()
		)
		return
	if _timed_node() and not _signal_open():
		toast("Zugriff blockiert. Warte auf das Cyan-Signal.")
		return
	if _timed_node():
		effects.burst(_target(), Color("70f5f7"), 28)
		sound("hack")
	_complete_point()

func _complete_point() -> void:
	if beat == Beat.PACT:
		toast(["Aufzug: Sicherheitskräfte eine Etage tiefer.", "Dachzugang: privater Landeplatz.", "Scanner: Kennung von Kenzōs Gleiter erforderlich."][point_index])
	if beat == Beat.HANGAR:
		effects.hack_arc(_target(), Vector2(884, 328))
		toast(["Stromversorgung aktiv.", "Kennung kopiert.", "Transponder bereit. Raven muss die Prüf-ICE-Matrix umgehen."][point_index])
	if beat == Beat.ESCAPE:
		toast(["Daten gesichert. Spuren gelöscht.", "Raven: Sperrladung scharf. Aufzug blockiert.", "Fernstart bestätigt. Zum Dachausgang!", "Dach erreicht. Der Aerodyne hebt ab."][point_index])
	point_index += 1
	if beat == Beat.PACT and point_index == Story.POINTS[beat].size():
		_scene_plan()
	elif beat == Beat.GARAGE and point_index == Story.POINTS[beat].size():
		_scene_descent()
	elif beat == Beat.ESCAPE and point_index == Story.POINTS[beat].size():
		_advance()
	elif beat != Beat.HANGAR and point_index == Story.POINTS[beat].size():
		_advance()
	else:
		autosave()

const RITUAL: = [
	[["SHADEPI", "Raven … das Heiligtum in mir hat dich erkannt. Schon in der Gasse. Es hat dich erwählt."],
		["SHADEPI", "Aber ich würde an deiner Seite stehen, selbst wenn es das nicht getan hätte. Nicht als Werkzeug einer Prophezeiung – sondern weil du mich daran erinnert hast, was es heißt, nicht nur ein Schatten zu sein."],
		["RAVEN", "Das klingt … irgendwie sehr schön. Ich würde dich ja küssen, aber mit der Maske geht das schwer."],
		["SHADEPI", "Ich kann dich im Orden aufnehmen. Wenn du es freiwillig willst. Dann kann ich mich dir auch zeigen."],
		["RAVEN", "Ich habe nichts mehr zu verlieren. Ich bin bereit, nach vorne zu blicken."]],
	[["SEE", "Sobald ihre Füße das Wasser berühren, vibriert der Boden. Ein neonblaues Leuchten steigt aus der Tiefe, Tropfen schweben in der Luft."],
		["SHADEPI", "Ich, Shadepi, Überlebender und ehemals Erster Krieger des Ordens des Weißen Drachen, erbitte dich: Nimm diese Seele in deine Obhut."]],
	[["HEILIGTUM", "Dein Wille ist stark. Ich spüre viel Gutes in dir. Ich akzeptiere dich."]],
	[["SHADEPI", "Hiermit nehme ich dich, Raven, in den Orden des Weißen Drachen auf. Ich ernenne dich zur Zweiten Kriegerin des Ordens und Behüterin des Heiligtums."]],
]

func _ritual_step() -> void :
	var step: = point_index
	var spot: Vector2 = _target()
	var cs = begin_cutscene()
	cs.camera(spot + Vector2(-10, -42), 1.0, 1.25)
	cs.walk(player, spot + Vector2(-30, 6), 64)
	await cs.walk(raven, spot + Vector2(16, 4), 64)
	cs.face(raven, spot + Vector2(60, -30))
	cs.face(player, raven.position)
	cs.pose(raven, "idle")
	cs.pose(player, "idle")
	if step > 0:
		cs.do(func():
			ritual_flash = 1.4
			ritual_origin = spot
			effects.burst(spot, Color("72eff4"), 30)
			effects.water_step(spot)
			sound("hack")
		)
		await cs.wait(0.5)
	for line: Array in RITUAL[step]:
		await cs.say(line[0], line[1])
	cs.end(func():
		point_index = step + 1
		if point_index == Story.POINTS[Beat.LAKE].size():
			_advance()
		else:
			autosave()
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
	camera.zoom = Vector2.ONE
	set_music_section("chapter_5_echo")
	reset_raven(SPAWN)
	set_painted_solids("memory")
	set_dressing("")
	_update_lighting()
	player.hide()
	_scene_containment()

func saved_checkpoint() -> int:
	var config: = ConfigFile.new()
	if config.load(Admin.checkpoint_path(SAVE, get_tree())) != OK:
		return -1
	var value: Variant = config.get_value("campaign", "beat", -1)
	return value if value is int and value >= Beat.PACT and value <= Beat.END else -1

func autosave() -> void :
	if not save_game():
		toast("Kontrollpunkt konnte nicht gespeichert werden.")

func save_game() -> bool:
	var config: = ConfigFile.new()
	config.set_value("campaign", "beat", beat)
	config.set_value("campaign", "point", point_index)
	config.set_value("campaign", "arcade_section", encounter.section_index if encounter != null else 0)
	config.set_value("campaign", "escape_guards_cleared", escape_guards_cleared)
	config.set_value("props", "state", dressing_state())
	return config.save(Admin.checkpoint_path(SAVE, get_tree())) == OK

func load_game(_requested_mode: Variant = null) -> bool:
	var saved: = saved_checkpoint()
	if saved < 0:
		return false
	var config: = ConfigFile.new()
	config.load(Admin.checkpoint_path(SAVE, get_tree()))
	restore_dressing_state(config.get_value("props", "state", {}))
	var saved_section: Variant = config.get_value("campaign", "arcade_section", 0)
	var saved_point: Variant = config.get_value("campaign", "point", 0)
	var cleared: Variant = config.get_value("campaign", "escape_guards_cleared", true)
	escape_guards_cleared = (cleared if cleared is bool else true) or saved != Beat.ESCAPE
	# Saves from v0.16.0 could stop at the old roof guard fight (point 2);
	# those guards now follow Kenzō, so resume directly at the penthouse.
	if saved == Beat.ROOF and saved_point is int and saved_point >= 2:
		saved = Beat.BOSS
		saved_point = 0
	_enter(saved, saved_section if saved_section is int else 0, saved_point if saved_point is int else 0)
	return true

func _draw() -> void :
	var art: Texture2D = Story.LEVEL_ART[beat]
	if beat == Beat.ECHO and echo_ready:
		art = Painted.ART.memory
	if beat == Beat.ECHO and not echo_ready:
		draw_rect(Rect2(0, 0, 1024, 640), Color("080c11"))
		draw_texture_rect(art, Painted.CHAMBER_RECT, false)
	else:
		draw_texture_rect(art, Rect2(0, 0, 1024, 640), false)
	if beat == Beat.HANGAR and point_index == 3:
		for port in PORTS:
			draw_rect(Rect2(port - Vector2(12, 9), Vector2(24, 18)), Color("253747"))
			draw_rect(Rect2(port - Vector2(9, 6), Vector2(18, 12)), Color("69dae0") if port == PORTS[1] else Color("315667"), false, 2)
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
	if beat == Beat.ESCAPE and lift_glow > 0.0:
		# Light spilling from the opening lift doors onto the marble floor.
		var glow: = minf(1.0, lift_glow)
		draw_set_transform(LIFT_DOOR + Vector2(0, -8), 0.0, Vector2(1.0, 0.38))
		for ring in 5:
			draw_circle(Vector2.ZERO, 26.0 + ring * 15.0, Color(0.5, 0.9, 1.0, 0.07 * glow))
		draw_set_transform(Vector2.ZERO)
		var gap: = 14.0 * glow
		draw_line(LIFT_DOOR + Vector2(-gap, -18), LIFT_DOOR + Vector2(-gap, 6), Color(0.75, 0.97, 1.0, 0.8 * glow), 2.0)
		draw_line(LIFT_DOOR + Vector2(gap, -18), LIFT_DOOR + Vector2(gap, 6), Color(0.75, 0.97, 1.0, 0.8 * glow), 2.0)
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
	var point: = Vector2.ZERO if in_cinematic() else _target()
	if point != Vector2.ZERO:
		var signal_color: = Color("f45d79") if _timed_node() and not _signal_open() else Color("72eff4")
		draw_circle(point, 12.0, signal_color, false, 2)
		var tip: = point + Vector2(0, -31.0 + sin(clock * 5.0) * 3.0)
		draw_polyline(PackedVector2Array([tip + Vector2(-6, -5), tip, tip + Vector2(6, -5)]), signal_color, 2)

# --- Scripted scenes ---------------------------------------------------------

func _spawn_kenzo_body(point: Vector2, fallen: bool) -> void:
	var body: = EnemyScript.new()
	body.setup(KENZO, self)
	body.position = point
	actors.add_child(body)
	body.reset_fight(1)
	body.active = false
	body.facing = Vector2.LEFT
	if fallen:
		_lay_down(body)
	kenzo_body = body

func _lay_down(body: PixelActor) -> void:
	body.health = 0
	body.visual.modulate = Color(0.45, 0.5, 0.6, 0.8)
	body.visual.rotation = PI * 0.5
	body.visual.position.y = -10
	body.queue_redraw()

func _escape_guards_done() -> void:
	if beat != Beat.ESCAPE or escape_guards_cleared:
		return
	escape_guards_cleared = true
	countdown = 60.0
	set_music_section("chapter_6_escape")
	autosave()
	play_lines([
		["SYSTEM / NOTFALLPROTOKOLL", "Kenzōs Sicherheitssystem überlastet die Energieversorgung. Kritischer Zustand in sechzig Sekunden."],
		["SHADEPI", "Daten sammeln, Spuren verwischen!"],
		["RAVEN", "Weitere Teams im Schacht. Ich synchronisiere die Sperrladung am Aufzug – dann starte die Treibstoffpumpe per Fernzugriff."],
	], func(): toast("T-60 · Daten sichern"))

# --- Zwischensequenzen der Kampagne ----------------------------------------
# Texte folgen „Shadepi – Im Schatten des Raben“ (Archiv). Spielerische
# Abweichungen (Gegnerwellen, Rätsel) bleiben, die Szenen erzählen die Story.

func _beat_scene(fresh: bool) -> void:
	match beat:
		Beat.PACT:
			if fresh: _scene_pact()
		Beat.AMBUSH:
			if fresh: _scene_ambush()
			else: toast("Hinterhalt · Welle %d" % (encounter.wave_index + 1 if encounter != null else 1))
		Beat.CHASE:
			if fresh: _scene_chase()
		Beat.GARAGE:
			if fresh: _scene_garage()
		Beat.HANGAR:
			if fresh: _scene_hangar()
		Beat.ECHO:
			if fresh: _scene_sanctuary()
		Beat.FLIGHT:
			if fresh: _scene_flight()
		Beat.ROOF:
			if fresh: _scene_roof()
		Beat.BOSS:
			if fresh: _scene_penthouse()
			else: toast("Kenzō · Hackfenster nur beim Flackern am Schulterservo")
		Beat.ESCAPE:
			if fresh: _scene_kenzo_falls()
			elif not escape_guards_cleared: toast("Kenzōs Aufzugwachen · Halte sie von Raven fern")
			else: toast("Daten sichern · Aufzug sperren · Pumpe starten · zum Dach")
		Beat.LAKE:
			if fresh: _scene_lake()
		Beat.END:
			if fresh: _scene_finale()
	if not fresh and not in_cinematic() and beat not in [Beat.AMBUSH, Beat.BOSS, Beat.ESCAPE]:
		toast(chapter_objective())

func camera_home() -> Vector2:
	if beat == Beat.ECHO and not echo_ready:
		return Painted.CHAMBER_CAMERA
	if raven_leads():
		return raven.position + Vector2(0, -52)
	return super.camera_home()

func _two_shot(zoom: float = 1.25) -> void:
	cutscene.camera(player.position.lerp(raven.position, 0.5) + Vector2(0, -42), 0.0, zoom)

## Kapitel 3: Der Pakt.
func _scene_pact() -> void:
	var cs = begin_cutscene()
	cs.pose(player, "idle")
	cs.pose(raven, "idle")
	cs.face(player, raven.position)
	cs.face(raven, player.position)
	_two_shot(1.3)
	await cs.fade(Color.BLACK, 0.0)
	await cs.fade(Color(0, 0, 0, 0), 0.9)
	await cs.title("KAPITEL 3", "Der Pakt", 2.2)
	await cs.lines([
		["RAVEN", "Du hörst dich an wie aus einem billigen Theaterstück. Es ist lieb von dir, aber diese Typen sind Monster. Ich brauche keinen Schutz."],
		["RAVENS VERSTECK", "Doch seine unerschütterliche Entschlossenheit bricht etwas in ihr auf. Die Dämme um ihre Vergangenheit bekommen Risse – und sie erzählt ihm alles."],
		["RAVEN", "Mein Vater war Programmierer bei Arasaka. Kenzō Moriyama ließ meine Eltern ermorden und hielt mich jahrelang gefangen – ein Spielzeug, das er nach Belieben quälte."],
		["RAVEN", "Ich bin geflohen, habe meine Identität gelöscht. Chrome Jackal war kein zufälliges Kopfgeld. Er war einer von Kenzōs Bluthunden. Ich habe ihn gejagt, bevor er mich jagen konnte."],
	])
	cs.pose(player, "attack")
	cs.do(func(): sound("prop_metal"))
	await cs.wait(0.35)
	cs.pose(player, "idle")
	await cs.lines([
		["SHADEPI", "Das tut mir leid, was du erleben musstest. Ich kann es nicht ungeschehen machen. Aber ich biete dir meine Dienste an."],
		["RAVEN", "Ich würde Kenzō gerne tot sehen. Ich kann nicht mein Leben lang fliehen. Ich helfe dir. Aber wir sind keine Freunde."],
		["SHADEPI", "Perfekt. Damit komme ich klar. Wie finden wir Kenzō?"],
	])
	var terminal: Vector2 = Story.POINTS[Beat.PACT][0]
	cs.camera(terminal + Vector2(0, -30), 1.0, 1.3)
	await cs.walk(raven, terminal + Vector2(26, 12), 70)
	cs.face(raven, terminal)
	cs.pose(raven, "attack")
	cs.do(func():
		effects.burst(terminal, Color("6fdcf0"), 18)
		sound("hack")
	)
	await cs.wait(0.4)
	cs.pose(raven, "idle")
	await cs.say("RAVEN", "Ich weiß, wo er wohnt. Immerhin war ich jahrelang sein Spielzeug. Hier – die Baupläne des Arasaka-Towers.")
	cs.end(func(): toast("Towerplan am Terminal prüfen"))

func _scene_plan() -> void:
	var cs = begin_cutscene()
	cs.pose(player, "idle")
	cs.pose(raven, "idle")
	cs.face(player, raven.position)
	await cs.camera(player.position.lerp(raven.position, 0.5) + Vector2(0, -42), 0.6, 1.3)
	await cs.lines([
		["RAVEN", "Er hat einen privaten Landeplatz. Entweder wir dringen von oben ein, oder wir marschieren durch den Hauptaufzug direkt in sein Penthouse."],
		["SHADEPI", "Dieser Sensor scannt jeden Gleiter vor der Landung. Wenn du die Kennung von Kenzōs Flieger auf einen anderen überträgst … ich weiß, wo ich einen herbekomme."],
		["RAVEN", "Das kann ich. Aber ich komme mit. Morgen Abend schickt er seine Angestellten weg. Seine Wachen sind eine Etage tiefer, und er nutzt keine Kameras."],
		["RAVEN", "Aber Kenzō selbst ist bis an die Zähne mit Militärtechnologie ausgestattet. Wir werden uns mit ihm einschließen."],
		["SHADEPI", "Ich habe immer gern einen Plan C. Dann lass uns den Aerodyne holen. Komm mit."],
	])
	await cs.fade(Color.BLACK, 0.6)
	cs.do(func(): _advance())

## Kapitel 3: Hinterhalt vor dem Versteck.
func _scene_ambush() -> void:
	var door: = Vector2(178, 262)
	player.position = door + Vector2(18, 18)
	raven.position = door + Vector2(-8, 6)
	player.facing = Vector2.DOWN
	raven.facing = Vector2.UP
	var cs = begin_cutscene()
	cs.pose(player, "idle")
	cs.pose(raven, "idle")
	await cs.camera(door + Vector2(60, 40), 0.0, 1.2)
	await cs.fade(Color.BLACK, 0.0)
	await cs.fade(Color(0, 0, 0, 0), 0.7)
	await cs.say("GASSE VOR DEM VERSTECK", "Sie treten in die feuchte Nachtluft. Raven schließt die Tür ab –")
	for i in 3:
		cs.do(func():
			var hit: = door + Vector2(randf_range(10, 70), randf_range(-30, 0))
			effects.burst(hit, Color("ffcf7a"), 10)
			sound("drive_shot")
			shake = 4.0
		)
		await cs.wait(0.14)
	cs.walk(raven, Vector2(150, 420), 260)
	await cs.walk(player, door + Vector2(46, 110), 220)
	cs.face(player, Vector2(450, 400))
	cs.do(func():
		sound("slash")
		effects.burst(player.position + Vector2(8, -22), Color("ff4f70"), 14)
	)
	await cs.camera(Vector2(330, 360), 0.8, 1.0)
	await cs.lines([
		["SHADEPI", "Rechts in der Gasse – kannst du ihn hacken? Er muss künstliche Augen haben! Ich übernehme den linken."],
		["RAVEN", "Gib mir eine freie Verbindung, dann flute ich seine Optik mit Rauschen."],
	])
	cs.end(func(): toast("Hinterhalt · Nutze die Deckung"))

func _scene_chase() -> void:
	var cs = begin_cutscene()
	await cs.lines([
		["SHADEPI", "*pfeift* – Ein mattschwarzes Motorrad rollt wie von Geisterhand aus der Seitenstraße. Kommst du mit?"],
		["RAVEN", "Ein bisschen eng."],
		["SHADEPI", "Airbags im Rücken, perfekt! Der Wagen kommt hinter uns aus der Gasse – festhalten!"],
		["RAVEN", "Du fährst, ich decke uns nach hinten. Bring mich auf seine Spur, dann hacke ich seine Lenkung."],
	])
	cs.end()

## Kapitel 4: Die Höhle des Drachen.
func _scene_garage() -> void:
	player.position = Vector2(60, 420)
	raven.position = Vector2(30, 440)
	var cs = begin_cutscene()
	await cs.camera(Vector2(320, 360), 0.0, 1.1)
	await cs.fade(Color.BLACK, 0.0)
	await cs.fade(Color(0, 0, 0, 0), 0.8)
	await cs.title("KAPITEL 4", "Die Höhle des Drachen", 2.2)
	cs.walk(raven, Vector2(300, 440), 80)
	await cs.walk(player, Vector2(340, 410), 80)
	cs.face(raven, Vector2(600, 300))
	cs.face(player, raven.position)
	cs.pose(player, "idle")
	cs.pose(raven, "idle")
	await cs.lines([
		["RAVEN", "Und das ist dein Zuhause? Eine rostige Garage?"],
		["SHADEPI", "Genau das ist es. Sieh dir die Werkbank an."],
	])
	cs.end(func(): toast("Geheimes Werkbanksymbol finden"))

func _scene_descent() -> void:
	var cs = begin_cutscene()
	await cs.camera(Vector2(760, 320), 0.6, 1.2)
	cs.do(func():
		sound("prop_metal")
		shake = 6.0
	)
	await cs.say("GARAGE", "Ein verstecktes Symbol leuchtet auf. Mit hydraulischem Zischen gleitet der Betonboden unter ihnen in die Tiefe.")
	await cs.fade(Color.BLACK, 0.8)
	cs.do(func(): _advance())

func _scene_hangar() -> void:
	player.position = Vector2(300, 420)
	raven.position = Vector2(270, 436)
	player.show()
	var cs = begin_cutscene()
	cs.pose(player, "idle")
	cs.pose(raven, "idle")
	await cs.camera(Vector2(420, 330), 0.0, 1.0)
	await cs.fade(Color.BLACK, 0.0)
	await cs.fade(Color(0, 0, 0, 0), 1.0)
	await cs.say("SANKTUARIUM DES ORDENS", "Unten erstreckt sich eine höhlenartige Halle: exotische Fahrzeuge, Klingen aus einer anderen Zeit, Kisten voller Technologie.")
	await cs.walk(raven, Vector2(380, 420), 60)
	cs.face(raven, Vector2(560, 260))
	cs.pose(raven, "idle")
	await cs.say("RAVEN", "Wow. Beeindruckend.")
	cs.face(player, raven.position)
	await cs.lines([
		["SHADEPI", "Schau dich gerne um. Ich gehe kurz hoch, meine Ausrüstung tauschen. Ein Servo macht Probleme."],
		["SHADEPI", "Der Aerodyne unter der Plane – kannst du ihn präparieren? Vielleicht noch ein Update. Und er braucht die Kennung von Kenzōs Gleiter."],
		["RAVEN", "Das kann ich tun. Ich prüfe den Stromkreis, kopiere die Kennung und teste das ARToS-System."],
	])
	cs.release(player)
	await cs.walk(player, Vector2(40, 410), 90)
	cs.do(func(): player.hide())
	cs.end(func(): toast("Aerodyne vorbereiten"))

## Kapitel 5: Heiligtum.
func _scene_sanctuary() -> void:
	var cs = begin_cutscene()
	cs.pose(player, "idle")
	cs.pose(raven, "idle")
	await cs.fade(Color.BLACK, 0.0)
	await cs.fade(Color(0, 0, 0, 0), 1.0)
	await cs.title("KAPITEL 5", "Eine Verbindung aus Feuer und Fleisch", 2.4)
	await cs.lines([
		["RAVEN", "Sag mal … steckt unter der Rüstung ein Mensch oder nur Metall?"],
		["SHADEPI", "Tatsächlich ist noch viel Menschliches an mir. Biologisch bin ich organisch, nur neuroelektronisch ergänzt. Mein Geist ist kein Computer."],
		["SANKTUARIUM", "Er erzählt von der Nacht des Massakers. Von den gesichtslosen Militech-Minotauren, die wie eine Welle des Todes über das Kloster herfielen. Vom Tod seiner Brüder und Schwestern."],
		["SHADEPI", "Das Heiligtum ist ein uralter Nanitenschwarm – das Herz unseres Ordens. Ich habe es mit letzter Kraft in mich aufgenommen, um es vor den Angreifern zu retten. Seitdem lebt es in mir."],
		["SHADEPI", "Das Kloster selbst war nach dem Angriff spurlos verschwunden. Als hätte die Erde es verschluckt."],
	])
	cs.do(func():
		shake = 5.0
		sound("hack")
	)
	await cs.flash(Color(1, 0.18, 0.3, 0.45), 0.4)
	await cs.lines([
		["SHADEPIS HUD", "WARNUNG · Eindämmungsstatus des Heiligtums kritisch: 96 %."],
		["SHADEPI", "Es reagiert auf dich … Ich muss es am Sessel stabilisieren. Halt Abstand."],
	])
	cs.end(func(): toast("Heiligtum am Sessel prüfen"))

func _scene_containment() -> void:
	var cs = begin_cutscene()
	cs.pose(raven, "idle")
	await cs.flash(Color(0.6, 0.95, 1.0, 0.8), 0.6)
	await cs.lines([
		["SHADEPIS HUD", "EINDÄMMUNG GESCHEITERT."],
		["HEILIGTUM", "Ein Teil des Schwarms geht auf Raven über. Sie sieht, was er gesehen hat. Finde die stabilen Erinnerungsanker."],
	])
	cs.end(func(): toast("Erinnerungen ordnen"))

func _scene_echo_end() -> void:
	var cs = begin_cutscene()
	cs.pose(raven, "idle")
	await cs.flash(Color(1, 1, 1, 0.7), 0.6)
	await cs.lines([
		["RAVEN", "Ich habe gesehen, was du verloren hast. Das Kloster. Die Träger vor dir. Die Nacht des Angriffs."],
		["SHADEPI", "Das Heiligtum hat dich nicht verletzt. Es hat dich … erkannt."],
	])
	await cs.fade(Color.BLACK, 0.8)
	cs.do(func(): _advance())

## Kapitel 6: Die Rache.
func _scene_flight() -> void:
	var cs = begin_cutscene()
	await cs.fade(Color.BLACK, 0.0)
	await cs.title("KAPITEL 6", "Die Rache", 2.2)
	await cs.lines([
		["AM NÄCHSTEN ABEND", "Die Anspannung ist elektrisch. Zwischen ihnen liegt ein neues, unausgesprochenes Band des Vertrauens."],
		["SHADEPI", "Ich kann mich nicht mit irgendjemandem verbinden. Du wurdest mir prophezeit."],
	])
	await cs.fade(Color(0, 0, 0, 0), 0.8)
	await cs.lines([
		["ARTOS", "A-a-artos-System … b-bootet … alle Parameter … instabil."],
		["SHADEPI", "Festhalten. Ich halte uns zwischen den Baken. Raven, sende die kopierte Kennung, sobald der Scanner in Reichweite ist."],
		["RAVEN", "Ich mag lieber Motorräder."],
	])
	cs.end()

func _scene_roof() -> void:
	player.position = Vector2(300, 330)
	raven.position = Vector2(330, 350)
	player.show()
	var cs = begin_cutscene()
	cs.pose(player, "idle")
	cs.pose(raven, "idle")
	cs.face(raven, Vector2(770, 260))
	cs.face(player, raven.position)
	await cs.camera(Vector2(420, 300), 0.0, 1.1)
	cs.do(func():
		shake = 6.0
		sound("drive_knock")
	)
	await cs.say("ARASAKA TOWER / LANDEPLATZ", "Bremsdüsen brüllen, heiße Luft peitscht über die Plattform. Das Aufsetzen ist hart.")
	await cs.lines([
		["SHADEPI", "Hals- und Beinbruch. Ich muss innerhalb von zwanzig Sekunden drin sein, dann fällt meine Tarnung."],
		["RAVEN", "Dann lass mich vorgehen. Ich lenke ihn ab. Keine Angst – er wird sein Lieblingsspielzeug nicht töten wollen."],
	])
	cs.do(func():
		player.set_cloaked(true)
		effects.burst(player.position + Vector2(0, -20), Color("7fe3ee"), 12)
	)
	await cs.wait(0.6)
	cs.do(func(): player.hide())
	cs.end(func(): toast("Kennung am Dachterminal prüfen"))

## Kapitel 6: Raven betritt das Penthouse, Shadepi folgt im Tarnfeld.
func _scene_penthouse() -> void:
	var kenzo: PixelActor = foes.back()
	var chair: = Vector2(612, 306)
	kenzo.position = chair
	kenzo.facing = Vector2.DOWN
	player.position = Vector2(36, 446)
	raven.position = Vector2(60, 414)
	player.facing = Vector2.RIGHT
	raven.facing = Vector2.RIGHT
	player.set_cloaked(true)
	var cs = begin_cutscene()
	for actor in [kenzo, player, raven]:
		cs.pose(actor, "idle")
	await cs.camera(chair + Vector2(0, -10), 0.0, 1.35)
	await cs.fade(Color.BLACK, 0.0)
	await cs.fade(Color(0, 0, 0, 0), 0.9)
	await cs.say("PENTHOUSE", "Ein protziger Tempel des Exzesses. Kenzō Moriyama sitzt in echtem Leder und trinkt einen sündhaft teuren Whisky.")
	cs.camera(Vector2(400, 370), 1.6, 1.1)
	cs.walk(player, Vector2(300, 448), 72)
	await cs.walk(raven, Vector2(420, 396), 72)
	cs.walk(player, Vector2(430, 446), 50)
	await cs.walk(raven, Vector2(540, 386), 60)
	cs.pose(raven, "idle")
	cs.pose(player, "idle")
	cs.face(kenzo, raven.position)
	await cs.camera(Vector2(570, 340), 0.8, 1.2)
	await cs.say("RAVEN", "Lange nicht gesehen.")
	await cs.walk(kenzo, raven.position + Vector2(30, -8), 46)
	cs.face(kenzo, raven.position)
	cs.pose(kenzo, "attack")
	cs.pose(raven, "hurt")
	cs.do(func(): raven.visual.position.y = raven.standing_visual_position.y - 12.0)
	await cs.wait(0.5)
	cs.do(func():
		raven.visual.position.y = raven.standing_visual_position.y
		shake = 5.0
		sound("hit")
	)
	await cs.leap(raven, Vector2(372, 404), 34.0, 0.5)
	cs.pose(kenzo, "idle")
	cs.face(kenzo, raven.position)
	await cs.say("KENZŌ MORIYAMA", "Dummes Mädchen. Ich habe ewig nach dir gesucht.")
	await cs.say("SHADEPIS HUD", "Tarnfeld · 3 … 2 … 1 … NULL.")
	cs.do(func():
		player.set_cloaked(false)
		effects.burst(player.position + Vector2(0, -20), Color("ff4f70"), 22)
		sound("slash")
	)
	await cs.walk(player, kenzo.position + Vector2(-30, 10), 520)
	cs.do(func():
		effects.slash(kenzo.position + Vector2(8, -30), Vector2.RIGHT)
		effects.burst(kenzo.position + Vector2(10, -30), Color("ffb36b"), 22)
		shake = 9.0
		sound("hit")
	)
	cs.pose(kenzo, "hurt")
	cs.flash(Color(1, 0.25, 0.35, 0.5), 0.35)
	await cs.walk(kenzo, kenzo.position + Vector2(64, -18), 280)
	cs.face(kenzo, player.position)
	cs.face(player, kenzo.position)
	cs.pose(kenzo, "idle")
	cs.pose(player, "idle")
	await cs.lines([
		["PENTHOUSE", "Der erste Schlag ist kein Todesstoß. Er ist eine Botschaft – die Servos in Kenzōs rechter Schulter sprühen Funken."],
		["KENZŌ MORIYAMA", "Die Maske aus dem Kloster. Die Minotauren haben gründlich gearbeitet – nur bei dir nicht."],
		["SHADEPI", "Raven – stör seine Implantate. Wenn er die Leitung sperrt, warte auf das Flackern am Schulterservo."],
	])
	cs.release(raven)
	await cs.walk(raven, Vector2(430, 420), 90)
	cs.end(func(): toast("KENZŌ MORIYAMA · Hackfenster am Schulterservo nutzen"))

## Kapitel 6: Kenzōs Ende – und die Wahrheit über das Massaker.
func _scene_kenzo_falls() -> void:
	var body: PixelActor = kenzo_body
	body.visual.rotation = 0.2
	body.visual.position.y = body.standing_visual_position.y + 7
	player.position = body.position + Vector2(-66, 26)
	raven.position = body.position + Vector2(-190, 74)
	var cs = begin_cutscene()
	cs.face(player, body.position)
	cs.face(raven, body.position)
	cs.face(body, player.position)
	cs.pose(body, "hurt")
	cs.pose(player, "idle")
	cs.pose(raven, "idle")
	await cs.camera(body.position + Vector2(-70, -40), 0.0, 1.25)
	await cs.say("PENTHOUSE", "Kenzō liegt gelähmt und blutend am Boden. Ein Monster aus Chrom und Hass – allein gegen zwei Geister der Rache.")
	await cs.walk(player, player.position + Vector2(-44, 22), 48)
	cs.face(player, body.position)
	cs.pose(player, "idle")
	await cs.say("SHADEPI", "Nicht ich töte dich. Das ist ihr Vergnügen.")
	await cs.walk(raven, body.position + Vector2(-40, 16), 54)
	cs.face(raven, body.position)
	cs.pose(raven, "idle")
	await cs.say("RAVEN", "Jahrelang bin ich vor dir geflohen, Kenzō. Wurde auch Zeit, dass dir jemand ein Ende setzt!")
	cs.pose(raven, "attack")
	cs.do(func(): sound("hack"))
	for i in 6:
		cs.do(func():
			var to: = body.position + Vector2(randf_range(-9, 9), randf_range(-30, -10))
			effects.hack_arc(raven.position + Vector2(4, -22), to)
			effects.burst(to, Color("72eff4"), 8)
		)
		await cs.wait(0.14)
	cs.do(func(): shake = 7.0)
	await cs.flash(Color(0.45, 0.95, 1.0, 0.6), 0.45)
	cs.release(body)
	cs.do(func(): _lay_down(body))
	cs.pose(raven, "idle")
	await cs.wait(1.0)
	await cs.say("PENTHOUSE", "Ihre unsichtbaren Fäden spannen sich ein letztes Mal. Ein Akt der Befreiung.")
	cs.pose(raven, "attack")
	cs.do(func():
		effects.hack_arc(raven.position + Vector2(4, -22), body.position + Vector2(0, -8))
		sound("hack")
	)
	await cs.wait(0.6)
	cs.pose(raven, "idle")
	cs.face(raven, player.position)
	await cs.lines([
		["RAVEN", "Sein Deck ist offen … Da. Die Minotauren, die dein Kloster überrannt haben. Militech-Einheiten – angefordert und bezahlt über Kenzōs verdeckte Projekte."],
		["RAVEN", "Er hat das Massaker inszeniert. Es war von Anfang an er."],
		["SHADEPI", "Fünf Jahre. Und am Ende ein Mann in einem Penthouse."],
		["SHADEPI", "Mein Orden ist gerächt. Zieh alles über die Minotauren – Lieferketten, Black-Sites, Testserien."],
	])
	cs.do(func():
		set_music_section("fight")
		sound("drive_engine_fail")
	)
	await cs.flash(Color(1, 0.08, 0.16, 0.45), 0.3)
	await cs.flash(Color(1, 0.08, 0.16, 0.45), 0.3)
	await cs.say("SYSTEM / TOTMANNSCHALTER", "Vitalzeichen des Eigentümers erloschen. Sicherheitsteams angefordert. Aufzug fährt hoch.")
	await cs.camera(LIFT_DOOR + Vector2(0, -60), 1.1, 1.15)
	cs.do(func(): lift_glow = 2.4)
	await cs.wait(0.5)
	cs.do(func(): _spawn_wave())
	await cs.wait(0.7)
	await cs.lines([
		["SHADEPI", "Seine Wachen von unten. Bleib an seinem Deck, Raven – ich halte sie dir vom Leib."],
		["RAVEN", "Gib mir eine Lücke, dann blende ich ihre Optik."],
	])
	cs.end(func():
		autosave()
		toast("Kenzōs Aufzugwachen · Halte sie von Raven fern")
	)

## Kapitel 7: Flucht, Explosion und der See.
func _scene_lake() -> void:
	player.position = Vector2(150, 430)
	raven.position = Vector2(118, 446)
	player.facing = Vector2.RIGHT
	raven.facing = Vector2.RIGHT
	var cs = begin_cutscene()
	cs.pose(player, "idle")
	cs.pose(raven, "idle")
	await cs.fade(Color.BLACK, 0.0)
	await cs.lines([
		["ARTOS", "SCHHUUIII – PUFF – PUFF. Triebwerke … instabil."],
		["SHADEPI", "Ach, scheiß Kiste!"],
		["AERODYNE", "T-6 … er tritt gegen die Pumpeneinheit. T-4 … die Triebwerke zünden. T-2 … der Aerodyne kippt über die Kante."],
		["SHADEPI", "HALT DICH GUT FEST, JETZT WIRD'S HOLPRIG!"],
	])
	cs.do(func():
		shake = 14.0
		sound("drive_explosion")
	)
	await cs.flash(Color(1, 0.92, 0.75, 1.0), 0.9)
	await cs.say("NACHT", "Hinter ihnen zerfetzt eine gewaltige Explosion das Penthouse. Shadepi fängt das taumelnde Fluggerät ab – weg von den Flammen, weg von der Vergangenheit.")
	await cs.camera(Vector2(330, 380), 0.0, 1.1)
	await cs.fade(Color(0, 0, 0, 0), 1.4)
	await cs.title("KAPITEL 7", "Der neue Orden", 2.4)
	await cs.say("AUSSERHALB DER STADT", "Ein kleiner Wald aus uralten Bäumen. In seiner Mitte ein kristallklarer See, der im Mondlicht schimmert wie ein gefallener Stern.")
	cs.walk(player, Vector2(300, 420), 60)
	await cs.walk(raven, Vector2(330, 440), 60)
	cs.face(raven, Vector2(620, 330))
	cs.face(player, raven.position)
	await cs.lines([
		["RAVEN", "Was ist das hier?"],
		["SHADEPI", "Ein Ort, den der Orden nie vergessen hat. Komm mit ans Wasser."],
	])
	cs.end(func(): toast("Raven zum Wasser folgen"))

## Kapitel 7: Maskenkodex und Kuss – der Orden ist wiedergeboren.
func _scene_finale() -> void:
	var center: Vector2 = player.position.lerp(raven.position, 0.5)
	var cs = begin_cutscene()
	cs.pose(player, "idle")
	cs.pose(raven, "idle")
	await cs.camera(center + Vector2(0, -30), 1.6, 1.6)
	await cs.say("SEE", "Langsam, fast zögerlich, greift er zu seiner Maske. Sein Kodex verbietet es, sein Gesicht jemandem außerhalb des Ordens zu zeigen. Raven gehört jetzt dazu.")
	await cs.fade(Color(1, 1, 1, 0.55), 1.1)
	await cs.lines([
		["SEE", "Darunter: das Gesicht eines Mannes, gezeichnet von Kampf und Verlust. Ein dunkles, menschliches Auge – und ein leuchtend rotes."],
		["RAVEN", "Oh."],
		["SEE", "Sie stellt sich auf die Zehenspitzen und küsst ihn. Ein Teil des Heiligtums geht endgültig und willentlich auf sie über."],
	])
	await cs.fade(Color(0, 0, 0, 0.82), 1.0)
	await cs.title("DER ORDEN DES WEISSEN DRACHEN", "ist in der Stille der Nacht wiedergeboren", 3.4)
	await cs.fade(Color(0, 0, 0, 0), 1.0)
	cs.end(func(): toast("Geschichte abgeschlossen · Danke fürs Spielen"))
