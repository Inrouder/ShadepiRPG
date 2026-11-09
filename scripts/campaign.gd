extends "res://scripts/main.gd"

const Story = preload("res://scripts/campaign_story.gd")
const Beat = Story.Beat
const SanctuaryStory = preload("res://scripts/sanctuary_story.gd")
const SanctuaryTableau = preload("res://scripts/sanctuary_tableau.gd")
const TowerStory = preload("res://scripts/tower_story.gd")
const TowerExtraction = preload("res://scripts/tower_extraction.gd")
const TowerKenzo = preload("res://scripts/tower_kenzo.gd")
const TowerEscape = preload("res://scripts/tower_escape.gd")
const LakeSequence = preload("res://scripts/lake_sequence.gd")
const HangarArt = preload("res://scripts/hangar_art.gd")
const HangarDiscovery = preload("res://scripts/hangar_discovery.gd")
const HangarWorld = preload("res://scripts/hangar_world.gd")
const Drive = preload("res://scripts/campaign_drive.gd")
const AerodyneFlight = preload("res://scripts/aerodyne_flight.gd")
const ParkedAerodyne = preload("res://scripts/parked_aerodyne.gd")
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
# 0: living quarters / rest; 1: two hours later; 2: compensator room.
var sanctuary_stage := 0
var sanctuary_tableau: Node2D
var memory_scene: Node2D
var memory_layer: CanvasLayer
var memory_serial := 0
var memory_attack_complete := false
var memory_sacrifice_complete := false
var memory_legacy_complete := false
var memory_anchor := -1
var memory_return_music := "chapter_5_echo"
var drive_layer: CanvasLayer
var encounter: Node2D
## False between Kenzō's fall and the last lift-guard wave of the escape.
var escape_guards_cleared: = true
var fresh_entry: = false
var kenzo_body: PixelActor
## 0 protection, 1 data secured/resolution pending, 2 bomb/escape, 3 departure.
var tower_stage := 2
var tower: Node2D
var tower_grip: Node2D
var tower_departure: Node2D
var boss_spot: = Vector2(858, 340)
const LIFT_DOOR: = Vector2(512, 512)
const KENZO: = preload("res://assets/sprites/npcs/kenzo.png")
const VEHICLES: = preload("res://assets/world/hq/vehicles.png")
const PARKED_BIKE: = preload("res://assets/world/hq/bike-parked.png")
## Garage arrival: middle roller door, motorcycle path and its parking spot.
const GARAGE_DOOR: = Rect2(238, 104, 152, 136)
const BIKE_PARK: = Vector2(902, 386)
var garage_door: = 0.0
var bike_mode: = ""
## Aerodyne on the tower pad (ROOF): touchdown point from the landing.
var aerodyne_spot := AerodyneFlight.PAD_WORLD
var parked_aerodyne: Node2D
## After a crash the repaired engine is not failing a second time.
var flight_engine_repaired := false
var departure: Node2D
var flight_intro_pending := false
var lake_scene_pending := false
var lake_sequence: Node2D
var discovery_pending := false
var hangar_discovery: Node2D
var hangar_world: Node2D
var bike_pos: = BIKE_PARK
var bike_rot: = 0.0

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
	return (beat == Beat.HANGAR or (beat == Beat.ROOF and point_index < 2)) or beat == Beat.ECHO

func actor_is_playable(actor: PixelActor) -> bool:
	return drive == null and timing == null and beat != Beat.END and actor == (raven if raven_leads() else player)

func actor_input_prefix(_actor: PixelActor) -> String:
	return ""

func atmosphere_profile() -> String:
	if beat in [Beat.CHASE, Beat.FLIGHT]: return ""
	if beat == Beat.ECHO and not echo_ready: return "compensator" if sanctuary_stage == 2 else "chamber"
	return painted_layout

func atmosphere_rect() -> Rect2:
	return Painted.CHAMBER_RECT if beat == Beat.ECHO and not echo_ready else Rect2(0,0,1024,640)

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
	if beat == Beat.ESCAPE and tower_stage==2 and escape_guards_cleared and not admin_enabled("freeze_timer"):
		countdown = maxf(0, countdown - delta)
		if countdown == 0:
			_retry("Zeit abgelaufen · Kontrollpunkt")

func _update_raven_follower(delta: float) -> void :
	if is_instance_valid(tower) and tower.active: return
	if beat==Beat.BOSS:
		raven.animate("idle",delta)
		return
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

func _enter(next: int, saved_section: int = 0, saved_point: int = 0, saved_echo: bool = false, seen_attack: bool = false, seen_sacrifice: bool = false, seen_legacy: bool = false, saved_sanctuary_stage: int = 0, saved_flight_intro: bool = false, saved_tower_stage: int = -1, saved_lake_pending: bool = false, saved_discovery: bool = false) -> void :
	_close_memory(false)
	var fresh: = fresh_entry
	fresh_entry = false
	cutscene.abort()
	if is_instance_valid(hangar_discovery):
		hangar_discovery.restore()
		hangar_discovery.get_parent().remove_child(hangar_discovery)
		hangar_discovery.queue_free()
	hangar_discovery = null
	if is_instance_valid(hangar_world):
		hangar_world.get_parent().remove_child(hangar_world)
		hangar_world.queue_free()
	hangar_world = null
	discovery_pending = next in [Beat.GARAGE,Beat.HANGAR] and (saved_discovery or (next==Beat.HANGAR and fresh))
	if is_instance_valid(lake_sequence):
		lake_sequence.hide()
		lake_sequence.get_parent().remove_child(lake_sequence)
		lake_sequence.queue_free()
	lake_sequence = null
	lake_scene_pending = next in [Beat.LAKE,Beat.END] and (fresh or saved_lake_pending)
	for node in [tower,tower_grip,tower_departure]:
		if is_instance_valid(node):
			if node==tower:
				tower.active = false
				if is_instance_valid(tower.tableau): tower.tableau.hide()
			node.hide()
			node.set_process(false)
			node.get_parent().remove_child(node)
			node.queue_free()
	tower = null
	tower_grip = null
	tower_departure = null
	if is_instance_valid(departure):
		departure.hide()
		departure.queue_free()
	departure = null
	flight_intro_pending = next == Beat.FLIGHT and (fresh or saved_flight_intro)
	ui.clear_toast()
	cancel_terminal()
	if beat == Beat.BOSS and not foes.is_empty():
		boss_spot = foes.back().position.clamp(Vector2(180,350),Vector2(880,410))
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
	sanctuary_stage = clampi(saved_sanctuary_stage, 0, 2)
	if is_instance_valid(sanctuary_tableau):
		sanctuary_tableau.hide()
		sanctuary_tableau.queue_free()
	sanctuary_tableau = null
	memory_attack_complete = false
	memory_sacrifice_complete = false
	memory_legacy_complete = false
	camera.zoom = Vector2.ONE * (1.15 if next == Beat.ECHO else 1.0)
	if is_instance_valid(drive):
		drive.hide()
		drive.queue_free()
	drive = null
	if is_instance_valid(parked_aerodyne):
		parked_aerodyne.queue_free()
	parked_aerodyne = null
	for foe in foes:
		foe.hide()
		foe.set_physics_process(false)
		foe.queue_free()
	foes.clear()
	beat = next
	garage_door = 0.0
	bike_mode = "parked" if beat == Beat.GARAGE else ""
	bike_pos = BIKE_PARK
	bike_rot = 0.0
	var music_sections := [
		"chapter_3_pact", "chapter_3_ambush", "chapter_3_chase",
		"chapter_4_garage", "chapter_4_hangar", "chapter_5_sanctuary",
		"chapter_6_flight", "chapter_6_tower", "chapter_6_boss",
		"chapter_6_escape", "chapter_7_lake", "chapter_7_finale",
	]
	set_music_section(music_sections[beat])
	var layouts: = ["hideout", "ambush", "", "garage", "hangar", "", "", "roof", "suite", "suite", "lake", "lake"]
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
		player.position = Vector2(365, 365)
		camera.position = Painted.CHAMBER_CAMERA
	player.reset_transients()
	reset_raven(player.position + Vector2(-27, 14))
	raven.visible = true
	for actor in [player,raven]:
		actor.modulate = Color.WHITE
		actor.z_index = 0
		actor.visual.show()
		actor.cast_shadow.show()
	player.visible = not raven_leads()
	var backgrounds: = ["hideout", "ambush", "", "garage", "hangar", "chamber", "", "rooftop", "suite", "suite", "lakeside", "lakeside"]
	set_painted_solids(backgrounds[beat])
	if beat==Beat.HANGAR:
		hangar_world = HangarWorld.new()
		hangar_world.world = self
		actors.add_child(hangar_world)
		if not discovery_pending and point_index==0: reset_raven(Vector2(438,468))
	if beat == Beat.ECHO:
		sanctuary_tableau = SanctuaryTableau.new()
		actors.add_child(sanctuary_tableau)
		_set_sanctuary_room()
		reset_raven(SanctuaryTableau.ENTRY if sanctuary_stage == 2 else SanctuaryTableau.BEDSIDE if sanctuary_stage == 1 else Vector2(365, 365))
	if beat == Beat.ECHO and saved_echo:
		echo_ready = true
		sanctuary_tableau.hide()
		memory_attack_complete = seen_attack
		memory_sacrifice_complete = seen_attack and seen_sacrifice
		memory_legacy_complete = memory_sacrifice_complete and seen_legacy
		# Old saves reached point 2 through a note; resume at the new second memory.
		point_index = clampi(saved_point,0,2 if memory_sacrifice_complete else 1) if seen_attack else 0
		reset_raven(SPAWN if point_index==0 else Painted.ECHO_POINTS[point_index-1])
		player.hide()
		camera.zoom = Vector2.ONE
		camera.position = raven.position+Vector2(0,-52)
		set_painted_solids("memory")
		set_dressing("")
		set_music_section("chapter_5_echo")
	if beat == Beat.ROOF:
		# The Aerodyne stays where it touched down on Kenzō's pad.
		parked_aerodyne = ParkedAerodyne.new()
		parked_aerodyne.place(aerodyne_spot)
		actors.add_child(parked_aerodyne)
		painted_solids.append(_collider(parked_aerodyne.footprint(), false))
	effects.rain = beat in [Beat.AMBUSH, Beat.ROOF]
	effects.steam_vents.clear()
	if beat == Beat.AMBUSH:
		effects.steam_vents.append(Vector2(160, 240))
	if beat == Beat.END:
		player.position = Story.POINTS[Beat.LAKE].back() + Vector2(-12, 0)
		raven.position = Story.POINTS[Beat.LAKE].back() + Vector2(12, 0)
		player.facing = Vector2.RIGHT
		raven.facing = Vector2.LEFT
	if beat in [Beat.LAKE,Beat.END]:
		lake_sequence = LakeSequence.new()
		lake_sequence.world = self
		actors.add_child(lake_sequence)
		if beat==Beat.LAKE and not lake_scene_pending and point_index==0:
			player.position = LakeSequence.SHORE[0]
			raven.position = LakeSequence.SHORE[1]
	_update_lighting()
	ui.clear_dialogue()
	close_menu()
	if beat in [Beat.CHASE, Beat.FLIGHT]:
		drive = AerodyneFlight.new() if beat == Beat.FLIGHT else Drive.new()
		drive.world = self
		drive.flight = beat == Beat.FLIGHT
		if beat == Beat.FLIGHT:
			drive.engine_repaired = flight_engine_repaired
		drive_layer.add_child(drive)
		var vehicle = drive
		drive.completed.connect(func():
			if beat == Beat.FLIGHT:
				aerodyne_spot = vehicle.touchdown_world()
			_advance())
		drive.crashed.connect( func():
			if beat == Beat.FLIGHT and vehicle.engine_repaired:
				flight_engine_repaired = true
			_retry("Landung abgebrochen · Kontrollpunkt" if beat == Beat.FLIGHT else "Fahrzeug ausgefallen · Kontrollpunkt"))
	if beat != Beat.ESCAPE:
		escape_guards_cleared = true
	elif fresh:
		escape_guards_cleared = false
	if beat == Beat.ESCAPE:
		tower_stage = 0 if fresh else (clampi(saved_tower_stage,0,3) if saved_tower_stage>=0 else 2 if escape_guards_cleared else 0)
		escape_guards_cleared = tower_stage>=2
		if tower_stage>=2: point_index = maxi(1,point_index)
		_spawn_kenzo_body(boss_spot,tower_stage>=2)
		tower = TowerExtraction.new()
		tower.world = self
		add_child(tower)
		set_music_section("chapter_6_escape" if escape_guards_cleared else ("chapter_6_boss" if fresh else "fight"))
	if is_combat() and beat!=Beat.ESCAPE:
		_spawn_wave(saved_section)
	queue_redraw()
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
	var foe = TowerKenzo.new() if variant<0 else EnemyScript.new()
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
	if is_instance_valid(tower) and tower.active:
		if origin.distance_to(player.position)<55 and player.cloak_time<=0: return player
		return raven
	return super.combat_target(origin, include_cloaked) if is_combat() else null

func hero_damaged(actor: PixelActor, _amount: int) -> void:
	if actor==raven and is_instance_valid(tower): tower.struck()

func player_strike(amount: int) -> void :
	strike_scenery(player.position, player.facing, amount)
	if not is_combat():
		return
	for foe in foes:
		if foe.health > 0 and CombatRules.can_strike(player.position, player.facing, foe.position) and _line_clear(player.position, foe.position):
			foe.take_damage(amount, player.position)

func raven_hack() -> bool:
	if is_instance_valid(tower) and tower.active:
		toast("Raven extrahiert Daten · Shadepi muss die Wachen abfangen")
		return false
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
	if beat==Beat.ESCAPE and tower_stage!=2: return Vector2.ZERO
	if beat == Beat.HANGAR and point_index == 3:
		return PORTS[1]
	if beat == Beat.ECHO and not echo_ready:
		return [SanctuaryTableau.BEDSIDE, SanctuaryTableau.DOOR, SanctuaryTableau.APPROACH][sanctuary_stage]
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
	if is_instance_valid(tower) and tower.active: return tower.status_text()
	if encounter != null and not encounter.finished:
		return encounter.status_text()
	match beat:
		Beat.AMBUSH:
			return "Hinterhalt · %d Gegner" % _living() if _living() else "Zum Motorrad"
		Beat.ECHO:
			return "Erinnerungen ordnen · %d / 3" % point_index if echo_ready else ["Raven: Am Bett ausruhen", "Raven: Durch die Tür nachsehen", "Raven: Shadepi am Sessel prüfen"][sanctuary_stage]
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
			if tower_stage==3: return "Zum Aerodyne · Abflug"
			if tower_stage==1: return "Daten gesichert · Kenzō stellen"
			return "%s · %02d s" % [["Raven schützen", "Sperrladung synchronisieren", "Treibstoffpumpe fernstarten", "Zum Dachausgang"][mini(3,point_index)], ceili(countdown)]
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
	for item in [[Vector2(193, 289), "Klingen ansehen"], [Vector2(476, 293), "Ersatzteile ansehen"], [Vector2(895, 380), "Aerodyne ansehen"]]:
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
			match sanctuary_stage:
				0: SanctuaryStory.sleep(self)
				1: SanctuaryStory.enter_room(self)
				2: _start_echo()
			return
		if raven.position.distance_to(Vector2(551, 426)) < 28.0:
			raven.position = SPAWN if point_index == 0 else Painted.ECHO_POINTS[point_index - 1]
			toast("Das Bild zerfällt. Zur letzten stabilen Erinnerung.")
			return
		if point_index == 0 and not memory_attack_complete:
			_open_first_memory()
			return
		if point_index == 1 and not memory_sacrifice_complete:
			_open_memory(1)
			return
		if point_index == 2 and not memory_legacy_complete:
			_open_memory(2)
			return
		toast(["Das Kloster.", "Lys Opfer.", "Das Vermächtnis."][point_index])
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
	if beat==Beat.ESCAPE and tower_stage!=2: return
	if beat == Beat.PACT:
		toast(["Aufzug: Sicherheitskräfte eine Etage tiefer.", "Dachzugang: privater Landeplatz.", "Scanner: Kennung von Kenzōs Gleiter erforderlich."][point_index])
	if beat == Beat.HANGAR:
		effects.hack_arc(_target(), Vector2(884, 328))
		toast(["Stromversorgung aktiv.", "Kennung kopiert.", "Aerodyne gangbar. Noch die Prüf-ICE am Transponder umgehen."][point_index])
	if beat == Beat.ESCAPE:
		toast(["Daten gesichert. Spuren gelöscht.", "Raven: Sperrladung scharf. Aufzug blockiert.", "Fernstart bestätigt. Zum Dachausgang!", "Dach erreicht. Der Aerodyne hebt ab."][point_index])
	point_index += 1
	if beat == Beat.PACT and point_index == Story.POINTS[beat].size():
		_scene_plan()
	elif beat == Beat.GARAGE and point_index == Story.POINTS[beat].size():
		_scene_descent()
	elif beat == Beat.ESCAPE and point_index == Story.POINTS[beat].size():
		tower_stage = 3
		autosave()
		_scene_tower_departure()
	elif beat != Beat.HANGAR and point_index == Story.POINTS[beat].size():
		_advance()
	else:
		autosave()

const RITUAL: = [
	[["SHADEPI", "Raven … das Heiligtum in mir hat dich erkannt. Schon in der Gasse. Es hat dich erwählt."],
		["RAVEN", "Und du?"],
		["SHADEPI", "Ich brauche keinen Schwur, um bei dir zu bleiben."],
		["RAVEN", "Gut. Das wollte ich hören."],
		["SHADEPI", "Die Aufnahme in den Orden muss deine Entscheidung sein."],
		["RAVEN", "Dann ist sie das. Ich will."]],
	[["SHADEPI", "Orden des Weißen Drachen … ich bitte dich: Nimm Raven in deine Obhut."]],
	[["HEILIGTUM", "Dein Wille ist stark. Ich spüre viel Gutes in dir. Ich akzeptiere dich."]],
	[["SHADEPI", "Hiermit nehme ich dich, Raven, in den Orden des Weißen Drachen auf. Ich ernenne dich zur Zweiten Kriegerin des Ordens und Behüterin des Heiligtums."]],
]

func _ritual_step() -> void :
	var step: = point_index
	var spot: Vector2 = _target()
	var cs = begin_cutscene()
	var ticket: int = cs.generation
	cs.camera(spot + Vector2(-10, -42), 1.0, 1.25)
	cs.walk(player, spot + Vector2(-30, 6), 64)
	await cs.walk(raven, spot + Vector2(16, 4), 64)
	if not cs.alive(ticket): return
	cs.face(raven, spot + Vector2(60, -30))
	cs.face(player, raven.position)
	cs.pose(raven, "idle")
	cs.pose(player, "idle")
	if is_instance_valid(lake_sequence): lake_sequence.ritual_step(step)
	if step > 0:
		cs.do(func():
			ritual_flash = 1.4
			ritual_origin = spot
			effects.burst(spot, Color("72eff4"), 30)
			effects.water_step(spot)
			sound("hack")
		)
		await cs.wait(0.5)
		if not cs.alive(ticket): return
	for line: Array in RITUAL[step]:
		await cs.say(line[0], line[1])
		if not cs.alive(ticket): return
	cs.end(func():
		point_index = step + 1
		if point_index == Story.POINTS[Beat.LAKE].size():
			_advance()
		else:
			autosave()
	)

func _set_sanctuary_room() -> void:
	set_dressing("")
	set_painted_solids("chamber" if sanctuary_stage < 2 else "compensator")
	sanctuary_tableau.show_room(sanctuary_stage == 2)
	player.hide()
	_update_lighting()
	queue_redraw()

func _start_echo() -> void:
	SanctuaryStory.contact(self)

func _enter_echo() -> void:
	if echo_ready: return
	gamepads.assign(Input.get_connected_joypads(), false)
	echo_ready = true
	if is_instance_valid(sanctuary_tableau): sanctuary_tableau.hide()
	camera.zoom = Vector2.ONE
	set_music_section("chapter_5_echo")
	reset_raven(SPAWN)
	raven.show()
	set_painted_solids("memory")
	set_dressing("")
	_update_lighting()
	player.hide()
	_scene_containment()
	autosave()

func is_busy() -> bool:
	return is_instance_valid(memory_scene) or super.is_busy()

func in_cinematic() -> bool:
	return is_instance_valid(memory_scene) or super.in_cinematic()

func _input(event: InputEvent) -> void:
	if is_instance_valid(memory_scene) and memory_scene.handle_event(event):
		get_viewport().set_input_as_handled()

func _open_first_memory() -> void:
	_open_memory(0)

func _open_memory(anchor: int) -> void:
	if is_instance_valid(memory_scene) or beat!=Beat.ECHO or point_index!=anchor or anchor not in [0,1,2]: return
	memory_serial += 1
	var ticket := memory_serial
	memory_anchor = anchor
	memory_return_music = music_section
	memory_layer = CanvasLayer.new()
	memory_layer.layer = 30
	add_child(memory_layer)
	var container := SubViewportContainer.new()
	container.size = Vector2(640,360)
	container.stretch = true
	container.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	memory_layer.add_child(container)
	var viewport := SubViewport.new()
	viewport.size = Vector2i(640,360)
	viewport.world_2d = World2D.new()
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	container.add_child(viewport)
	var resource: PackedScene = [preload("res://scenes/memories/attack.tscn"),preload("res://scenes/memories/sacrifice.tscn"),preload("res://scenes/memories/legacy.tscn")][anchor]
	var scene = resource.instantiate()
	scene.embedded = true
	scene.autoplay = false
	scene.host = self
	memory_scene = scene
	viewport.add_child(scene)
	scene.finished.connect(func(done: bool):
		if memory_scene!=scene or memory_serial!=ticket or beat!=Beat.ECHO or point_index!=anchor: return
		_close_memory(done))
	set_music_section("fight" if anchor==0 else "boss" if anchor==1 else "chapter_5_sanctuary")
	scene.play.call_deferred()

func _close_memory(done: bool) -> void:
	if not is_instance_valid(memory_layer): return
	var anchor := memory_anchor
	memory_anchor = -1
	memory_serial += 1
	if is_instance_valid(memory_scene):
		memory_scene.closed = true
		memory_scene.cutscene.abort()
	memory_scene = null
	memory_layer.hide()
	memory_layer.queue_free()
	memory_layer = null
	set_music_section(memory_return_music)
	if done and beat==Beat.ECHO and point_index==anchor:
		if anchor==0: memory_attack_complete = true
		elif anchor==1: memory_sacrifice_complete = true
		elif anchor==2:
			memory_legacy_complete = true
			autosave()
			_scene_echo_end()
			return
		_complete_point()
		toast(("Der Angriff" if anchor==0 else "Lys Opfer")+" · Erinnerung gesichert")

func _exit_tree() -> void:
	_close_memory(false)
	super._exit_tree()

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
	config.set_value("campaign", "echo_started", beat==Beat.ECHO and (echo_ready or memory_legacy_complete))
	config.set_value("campaign", "sanctuary_stage", sanctuary_stage if beat==Beat.ECHO else 0)
	config.set_value("campaign", "flight_intro_pending", beat==Beat.FLIGHT and flight_intro_pending)
	config.set_value("campaign", "memory_attack_complete", memory_attack_complete)
	config.set_value("campaign", "memory_sacrifice_complete", memory_sacrifice_complete)
	config.set_value("campaign", "memory_legacy_complete", memory_legacy_complete)
	config.set_value("campaign", "arcade_section", encounter.section_index if encounter != null else 0)
	config.set_value("campaign", "escape_guards_cleared", escape_guards_cleared)
	config.set_value("campaign", "tower_stage",tower_stage if beat==Beat.ESCAPE else -1)
	config.set_value("campaign", "boss_spot",boss_spot)
	config.set_value("campaign", "aerodyne_spot",aerodyne_spot)
	config.set_value("campaign", "lake_scene_pending",lake_scene_pending)
	config.set_value("campaign", "discovery_pending",discovery_pending)
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
	var saved_tower: Variant = config.get_value("campaign", "tower_stage",-1)
	var saved_spot: Variant = config.get_value("campaign", "boss_spot",Vector2(858,340))
	if saved_spot is Vector2 and saved_spot.is_finite(): boss_spot = saved_spot.clamp(Vector2(100,320),Vector2(930,450))
	var saved_landing: Variant = config.get_value("campaign", "aerodyne_spot",AerodyneFlight.PAD_WORLD)
	aerodyne_spot = saved_landing.clamp(Vector2(160,300),Vector2(240,352)) if saved_landing is Vector2 and saved_landing.is_finite() else AerodyneFlight.PAD_WORLD
	var saved_echo: Variant = config.get_value("campaign", "echo_started", false)
	var saved_flight_intro: Variant = config.get_value("campaign", "flight_intro_pending", false)
	# Older chapter-7 saves receive the new arrival/finale once, preserving ritual progress.
	var legacy_lake_scene: bool = saved==Beat.END or (saved==Beat.LAKE and saved_point is int and saved_point==0)
	var saved_lake: Variant = config.get_value("campaign", "lake_scene_pending", legacy_lake_scene)
	var saved_discovery: Variant = config.get_value("campaign","discovery_pending",false)
	var saved_sanctuary_stage: Variant = config.get_value("campaign", "sanctuary_stage", 0)
	var seen_attack: Variant = config.get_value("campaign", "memory_attack_complete", false)
	var seen_sacrifice: Variant = config.get_value("campaign", "memory_sacrifice_complete", false)
	var seen_legacy: Variant = config.get_value("campaign", "memory_legacy_complete", false)
	escape_guards_cleared = (cleared if cleared is bool else true) or saved != Beat.ESCAPE
	# Saves from v0.16.0 could stop at the old roof guard fight (point 2);
	# those guards now follow Kenzō, so resume directly at the penthouse.
	if saved == Beat.ROOF and saved_point is int and saved_point >= 2:
		saved = Beat.BOSS
		saved_point = 0
	_enter(saved, saved_section if saved_section is int else 0, saved_point if saved_point is int else 0, saved_echo is bool and saved_echo, seen_attack is bool and seen_attack, seen_sacrifice is bool and seen_sacrifice, seen_legacy is bool and seen_legacy, saved_sanctuary_stage if saved_sanctuary_stage is int else 0, saved_flight_intro is bool and saved_flight_intro, saved_tower if saved_tower is int and saved_tower>=0 and saved_tower<=3 else -1, saved_lake is bool and saved_lake,saved_discovery is bool and saved_discovery)
	return true

func _draw() -> void :
	var art: Texture2D = Story.LEVEL_ART[beat]
	if beat == Beat.ECHO and echo_ready:
		art = Painted.ART.memory
	if beat == Beat.ECHO and not echo_ready:
		draw_rect(Rect2(0, 0, 1024, 640), Color("080c11"))
		if sanctuary_stage == 2: art = SanctuaryTableau.ROOM
		draw_texture_rect(art, Painted.CHAMBER_RECT, false)
	else:
		if beat==Beat.HANGAR:
			HangarArt.room(self)
			HangarArt.floor(self,true,0)
		else: draw_texture_rect(art, Rect2(0, 0, 1024, 640), false)
	if beat == Beat.GARAGE:
		if is_instance_valid(hangar_discovery) and hangar_discovery.view=="garage": HangarArt.floor(self,false,hangar_discovery.deck_frame)
		_draw_garage()
		if is_instance_valid(hangar_discovery) and hangar_discovery.stage=="switch":
			draw_texture_rect_region(HangarArt.SWITCH,Rect2(HangarArt.SWITCH_TARGET-Vector2(3,4),Vector2(6,8)),Rect2(332,137,40,55),Color(0.6,1.0,1.0))
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
		if ritual_flash > 0.0 and point_index == 3:
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
		body.health = 0
	kenzo_body = body

func _lay_down(body: PixelActor) -> void:
	body.health = 0
	body.visual.modulate = Color(0.45, 0.5, 0.6, 0.8)
	body.visual.rotation = PI * 0.5
	body.visual.position.y = -10
	body.queue_redraw()

func _escape_guards_done() -> void:
	if beat==Beat.ESCAPE and is_instance_valid(tower): tower.completed_waves()

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
			if discovery_pending: _scene_descent()
			elif fresh: _scene_garage()
		Beat.HANGAR:
			if fresh or discovery_pending: _scene_hangar()
		Beat.ECHO:
			if echo_ready and memory_legacy_complete: _scene_echo_end()
			elif not echo_ready and sanctuary_stage == 0: _scene_sanctuary()
		Beat.FLIGHT:
			if flight_intro_pending: _scene_flight()
		Beat.ROOF:
			if fresh: _scene_roof()
		Beat.BOSS:
			if fresh: _scene_penthouse()
			else: toast("Kenzō · Hackfenster nur beim Flackern am Schulterservo")
		Beat.ESCAPE:
			if fresh: _scene_kenzo_falls()
			elif tower_stage!=2: tower.resume()
			else: toast("Daten gesichert · Aufzug sperren · Fernstart · zum Dach")
		Beat.LAKE:
			if fresh or lake_scene_pending: _scene_lake()
		Beat.END:
			if fresh or lake_scene_pending: _scene_finale()
			else: lake_sequence.rest()
	if not fresh and not in_cinematic() and beat not in [Beat.AMBUSH, Beat.BOSS, Beat.ESCAPE]:
		toast(chapter_objective())

func camera_home() -> Vector2:
	if is_instance_valid(hangar_discovery) and hangar_discovery.view=="hangar": return raven.position+Vector2(0,-52)
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
	var ticket: int = cs.generation
	cs.pose(player, "idle")
	cs.pose(raven, "idle")
	cs.face(player, raven.position)
	cs.face(raven, player.position)
	_two_shot(1.3)
	await cs.fade(Color.BLACK, 0.0)
	if not cs.alive(ticket): return
	await cs.fade(Color(0, 0, 0, 0), 0.9)
	if not cs.alive(ticket): return
	await cs.title("KAPITEL 3", "Der Pakt", 2.2)
	if not cs.alive(ticket): return
	await cs.lines([
		["RAVEN", "Du hörst dich an wie aus einem billigen Theaterstück. Es ist lieb von dir, aber diese Typen sind Monster. Ich brauche keinen Schutz."],
		["RAVENS VERSTECK", "Doch seine unerschütterliche Entschlossenheit bricht etwas in ihr auf. Die Dämme um ihre Vergangenheit bekommen Risse – und sie erzählt ihm alles."],
		["RAVEN", "Mein Vater war Programmierer bei Arasaka. Kenzō Moriyama ließ meine Eltern ermorden und hielt mich jahrelang gefangen – ein Spielzeug, das er nach Belieben quälte."],
		["RAVEN", "Ich bin geflohen, habe meine Identität gelöscht. Chrome Jackal war kein zufälliges Kopfgeld. Er war einer von Kenzōs Bluthunden. Ich habe ihn gejagt, bevor er mich jagen konnte."],
	])
	if not cs.alive(ticket): return
	cs.pose(player, "attack")
	cs.do(func(): sound("prop_metal"))
	await cs.wait(0.35)
	if not cs.alive(ticket): return
	cs.pose(player, "idle")
	await cs.lines([
		["SHADEPI", "Das tut mir leid, was du erleben musstest. Ich kann es nicht ungeschehen machen. Aber ich biete dir meine Dienste an."],
		["RAVEN", "Ich würde Kenzō gerne tot sehen. Ich kann nicht mein Leben lang fliehen. Ich helfe dir. Aber wir sind keine Freunde."],
		["SHADEPI", "Perfekt. Damit komme ich klar. Wie finden wir Kenzō?"],
	])
	if not cs.alive(ticket): return
	var terminal: Vector2 = Story.POINTS[Beat.PACT][0]
	cs.camera(terminal + Vector2(0, -30), 1.0, 1.3)
	await cs.walk(raven, terminal + Vector2(26, 12), 70)
	if not cs.alive(ticket): return
	cs.face(raven, terminal)
	cs.pose(raven, "attack")
	cs.do(func():
		effects.burst(terminal, Color("6fdcf0"), 18)
		sound("hack")
	)
	await cs.wait(0.4)
	if not cs.alive(ticket): return
	cs.pose(raven, "idle")
	await cs.say("RAVEN", "Ich weiß, wo er wohnt. Immerhin war ich jahrelang sein Spielzeug. Hier – die Baupläne des Arasaka-Towers.")
	if not cs.alive(ticket): return
	cs.end(func(): toast("Towerplan am Terminal prüfen"))

func _scene_plan() -> void:
	var cs = begin_cutscene()
	var ticket: int = cs.generation
	cs.pose(player, "idle")
	cs.pose(raven, "idle")
	cs.face(player, raven.position)
	await cs.camera(player.position.lerp(raven.position, 0.5) + Vector2(0, -42), 0.6, 1.3)
	if not cs.alive(ticket): return
	await cs.lines([
		["RAVEN", "Er hat einen privaten Landeplatz. Entweder wir dringen von oben ein, oder wir marschieren durch den Hauptaufzug direkt in sein Penthouse."],
		["SHADEPI", "Dieser Sensor scannt jeden Gleiter vor der Landung. Wenn du die Kennung von Kenzōs Flieger auf einen anderen überträgst … ich weiß, wo ich einen herbekomme."],
		["RAVEN", "Das kann ich. Aber ich komme mit. Morgen Abend schickt er seine Angestellten weg. Seine Wachen sind eine Etage tiefer, und er nutzt keine Kameras."],
		["RAVEN", "Aber Kenzō selbst ist bis an die Zähne mit Militärtechnologie ausgestattet. Wir werden uns mit ihm einschließen."],
		["SHADEPI", "Ich habe immer gern einen Plan C. Dann lass uns den Aerodyne holen. Komm mit."],
	])
	if not cs.alive(ticket): return
	await cs.fade(Color.BLACK, 0.6)
	if not cs.alive(ticket): return
	cs.do(func(): _advance())

## Kapitel 3: Hinterhalt vor dem Versteck.
func _scene_ambush() -> void:
	var door: = Vector2(178, 262)
	player.position = door + Vector2(18, 18)
	raven.position = door + Vector2(-8, 6)
	player.facing = Vector2.DOWN
	raven.facing = Vector2.UP
	var cs = begin_cutscene()
	var ticket: int = cs.generation
	cs.pose(player, "idle")
	cs.pose(raven, "idle")
	await cs.camera(door + Vector2(60, 40), 0.0, 1.2)
	if not cs.alive(ticket): return
	await cs.fade(Color.BLACK, 0.0)
	if not cs.alive(ticket): return
	await cs.fade(Color(0, 0, 0, 0), 0.7)
	if not cs.alive(ticket): return
	await cs.say("GASSE VOR DEM VERSTECK", "Sie treten in die feuchte Nachtluft. Raven schließt die Tür ab –")
	if not cs.alive(ticket): return
	for i in 3:
		cs.do(func():
			var hit: = door + Vector2(randf_range(10, 70), randf_range(-30, 0))
			effects.burst(hit, Color("ffcf7a"), 10)
			sound("drive_shot")
			shake = 4.0
		)
		await cs.wait(0.14)
		if not cs.alive(ticket): return
	cs.walk(raven, Vector2(150, 420), 260)
	await cs.walk(player, door + Vector2(46, 110), 220)
	if not cs.alive(ticket): return
	cs.face(player, Vector2(450, 400))
	cs.do(func():
		sound("slash")
		effects.burst(player.position + Vector2(8, -22), Color("ff4f70"), 14)
	)
	await cs.camera(Vector2(330, 360), 0.8, 1.0)
	if not cs.alive(ticket): return
	await cs.lines([
		["SHADEPI", "Rechts in der Gasse – kannst du ihn hacken? Er muss künstliche Augen haben! Ich übernehme den linken."],
		["RAVEN", "Gib mir eine freie Verbindung, dann flute ich seine Optik mit Rauschen."],
	])
	if not cs.alive(ticket): return
	cs.end(func(): toast("Hinterhalt · Nutze die Deckung"))

func _scene_chase() -> void:
	var cs = begin_cutscene()
	var ticket: int = cs.generation
	await cs.lines([
		["SHADEPI", "*pfeift* – Ein mattschwarzes Motorrad rollt wie von Geisterhand aus der Seitenstraße. Kommst du mit?"],
		["RAVEN", "Ein bisschen eng."],
		["SHADEPI", "Airbags im Rücken, perfekt! Der Wagen kommt hinter uns aus der Gasse – festhalten!"],
		["RAVEN", "Du fährst, ich decke uns nach hinten. Bring mich auf seine Spur, dann hacke ich seine Lenkung."],
	])
	if not cs.alive(ticket): return
	cs.end()

## Kapitel 4: Die Höhle des Drachen.
## Kapitel 4: Nach der Verfolgung – das Tor rollt hoch, das Motorrad fährt
## auf die Plattform und bleibt dort stehen.
func _scene_garage() -> void:
	player.hide()
	raven.hide()
	bike_mode = ""
	bike_pos = Vector2(314, 214)
	bike_rot = PI
	var cs = begin_cutscene()
	var ticket: int = cs.generation
	await cs.camera(Vector2(330, 250), 0.0, 1.25)
	if not cs.alive(ticket): return
	await cs.fade(Color.BLACK, 0.0)
	if not cs.alive(ticket): return
	await cs.fade(Color(0, 0, 0, 0), 0.8)
	if not cs.alive(ticket): return
	await cs.title("KAPITEL 4", "Die Höhle des Drachen", 2.2)
	if not cs.alive(ticket): return
	await cs.say("INDUSTRIEHAFEN", "Die wilde Fahrt endet vor einer unscheinbaren, heruntergekommenen Garage in einem vergessenen Teil des Hafens.")
	if not cs.alive(ticket): return
	cs.do(func():
		sound("prop_metal")
		shake = 3.0
	)
	await cs.animate(func(k: float):
		garage_door = smoothstep(0.0, 1.0, k)
		if k > 0.55:
			bike_mode = "ride"
	, 1.6)
	if not cs.alive(ticket): return
	cs.do(func(): sound("drive_engine_restart"))
	var start := Vector2(314, 214)
	var bend := Vector2(360, 452)
	var finish := BIKE_PARK + Vector2(0, 34)
	var camera_from: Vector2 = camera.position
	await cs.animate(func(k: float):
		var t := smoothstep(0.0, 1.0, k)
		var a := start.lerp(bend, t)
		var b := bend.lerp(finish, t)
		var p := a.lerp(b, t)
		var direction := (b - a).normalized()
		bike_pos = p
		bike_rot = direction.angle() + PI * 0.5
		camera.position = camera_from.lerp(Vector2(clampf(p.x, 330.0, 700.0), 330.0), smoothstep(0.0, 1.0, k))
		if fposmod(k * 20.0, 1.0) < 0.15:
			effects.water_step(p + Vector2(0, 20))
	, 2.8)
	if not cs.alive(ticket): return
	var turn_from: = bike_rot
	cs.camera(Vector2(760, 360), 0.8, 1.2)
	await cs.animate(func(k: float):
		bike_pos = finish.lerp(BIKE_PARK, k)
		bike_rot = lerp_angle(turn_from, 0.0, smoothstep(0.0, 1.0, k))
	, 0.6)
	if not cs.alive(ticket): return
	cs.do(func():
		bike_mode = "parked"
		player.position = BIKE_PARK + Vector2(-34, 6)
		raven.position = BIKE_PARK + Vector2(-34, 28)
		player.facing = Vector2.LEFT
		raven.facing = Vector2.LEFT
		player.show()
		raven.show()
		effects.burst(BIKE_PARK + Vector2(0, 20), Color("9fb3c6"), 10)
	)
	cs.pose(player, "idle")
	cs.pose(raven, "idle")
	await cs.wait(0.4)
	if not cs.alive(ticket): return
	cs.walk(raven, Vector2(760, 440), 70)
	await cs.walk(player, Vector2(790, 412), 70)
	if not cs.alive(ticket): return
	cs.face(raven, Vector2(560, 260))
	cs.face(player, raven.position)
	cs.pose(player, "idle")
	cs.pose(raven, "idle")
	cs.do(func(): sound("prop_metal"))
	cs.animate(func(k: float): garage_door = 1.0 - smoothstep(0.0, 1.0, k), 1.4)
	await cs.lines([
		["RAVEN", "Und das ist dein Zuhause? Eine rostige Garage?"],
		["SHADEPI", "Genau das ist es. Sieh dir die Werkbank an."],
	])
	if not cs.alive(ticket): return
	cs.do(func(): garage_door = 0.0)
	cs.end(func(): toast("Geheimes Werkbanksymbol finden"))

func _draw_garage() -> void:
	if garage_door > 0.0:
		var h := GARAGE_DOOR.size.y * garage_door
		var opening := Rect2(GARAGE_DOOR.position.x, GARAGE_DOOR.end.y - h, GARAGE_DOOR.size.x, h)
		draw_rect(opening, Color("05080f"))
		# Night street outside: wet asphalt glow and rain behind the door.
		draw_rect(Rect2(opening.position.x, GARAGE_DOOR.end.y - minf(h, 30.0), opening.size.x, minf(h, 30.0)), Color(0.85, 0.2, 0.5, 0.18))
		for i in 12:
			var rx := opening.position.x + 6 + i * 12.5
			var ry := opening.position.y + fposmod(i * 23 + clock * 260.0, maxf(1.0, h))
			draw_line(Vector2(rx, ry), Vector2(rx - 2, ry + 7), Color(0.65, 0.75, 0.95, 0.35))
		draw_rect(Rect2(opening.position.x - 2, opening.position.y - 5, opening.size.x + 4, 6), Color("4c535e"))
		draw_rect(Rect2(opening.position.x - 2, opening.position.y - 1, opening.size.x + 4, 2), Color("e2b13c"))
	if bike_mode == "ride":
		draw_set_transform(bike_pos, bike_rot)
		draw_texture_rect_region(VEHICLES, Rect2(Vector2(-39, -39), Vector2(78, 78)), Rect2(0, 627, 627, 627))
		draw_set_transform(Vector2.ZERO)
	elif bike_mode == "parked":
		var size: = Vector2(72.0 * PARKED_BIKE.get_width() / PARKED_BIKE.get_height(), 72.0)
		draw_set_transform(bike_pos, bike_rot)
		draw_texture_rect(PARKED_BIKE, Rect2(-size * 0.5 + Vector2(3, 4), size), false, Color(0, 0, 0, 0.35))
		draw_texture_rect(PARKED_BIKE, Rect2(-size * 0.5, size), false)
		draw_set_transform(Vector2.ZERO)

func _scene_descent() -> void:
	hangar_discovery = HangarDiscovery.new()
	hangar_discovery.world = self
	add_child(hangar_discovery)
	hangar_discovery.play(true)

func _scene_hangar() -> void:
	hangar_discovery = HangarDiscovery.new()
	hangar_discovery.world = self
	add_child(hangar_discovery)
	if is_instance_valid(hangar_world): hangar_world.hide()
	hangar_discovery.play(false)

## Kapitel 5: Heiligtum.
func _scene_sanctuary() -> void:
	SanctuaryStory.arrival(self)

func _scene_containment() -> void:
	SanctuaryStory.memory_entry(self)

func _scene_echo_end() -> void:
	SanctuaryStory.aftermath(self)

## Kapitel 6: Die Rache.
func _scene_flight() -> void:
	departure = preload("res://scripts/hangar_departure.gd").new()
	departure.world = self
	drive_layer.add_child(departure)
	departure.play()

func _scene_roof() -> void:
	# Both climb out of the hatch beside the freshly landed Aerodyne.
	player.position = aerodyne_spot + Vector2(78, 52)
	raven.position = aerodyne_spot + Vector2(56, 70)
	player.show()
	var cs = begin_cutscene()
	var ticket: int = cs.generation
	cs.pose(player, "idle")
	cs.pose(raven, "idle")
	cs.face(raven, Vector2(770, 260))
	cs.face(player, raven.position)
	# Same framing as the landing view of the flight, then pan toward the door.
	await cs.camera(AerodyneFlight.ROOF_CAMERA, 0.0, AerodyneFlight.ROOF_ZOOM)
	if not cs.alive(ticket): return
	cs.do(func():
		shake = 6.0
		sound("drive_knock")
	)
	await cs.say("ARASAKA TOWER / LANDEPLATZ", "Heiße Luft peitscht über die Plattform, das Metall knackt. Der Aerodyne steht.")
	if not cs.alive(ticket): return
	await cs.lines([
		["SHADEPI", "Hals- und Beinbruch. Ich muss innerhalb von zwanzig Sekunden drin sein, dann fällt meine Tarnung."],
		["RAVEN", "Dann lass mich vorgehen. Ich lenke ihn ab. Keine Angst – er wird sein Lieblingsspielzeug nicht töten wollen."],
	])
	if not cs.alive(ticket): return
	cs.do(func():
		player.set_cloaked(true)
		effects.burst(player.position + Vector2(0, -20), Color("7fe3ee"), 12)
	)
	await cs.wait(0.6)
	if not cs.alive(ticket): return
	cs.do(func(): player.hide())
	cs.end(func(): toast("Kennung am Dachterminal prüfen"))

## Kapitel 6: Raven betritt das Penthouse, Shadepi folgt im Tarnfeld.
func _scene_penthouse() -> void:
	TowerStory.opening(self)

func _scene_kenzo_falls() -> void:
	TowerStory.defeated(self)

func _scene_tower_resolution() -> void:
	if beat==Beat.ESCAPE and tower_stage==1 and not cutscene.running: TowerStory.resolution(self)

func _scene_tower_departure() -> void:
	if is_instance_valid(tower_departure): return
	tower_departure = TowerEscape.new()
	tower_departure.world = self
	drive_layer.add_child(tower_departure)
	tower_departure.run()

## Kapitel 7 · v0.36.0 · CodexAI: real arrival, disembarkation and private kiss.
func _scene_lake() -> void:
	lake_sequence.play_arrival()

func _scene_finale() -> void:
	lake_sequence.play_finale()
