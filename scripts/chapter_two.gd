extends "res://scripts/main.gd"

enum Section{YARD, HIDEOUT, DIVE, RECOVERY, END, COOLING}

const ChapterHud = preload("res://scripts/chapter_two_hud.gd")
const IceBath = preload("res://scripts/ice_bath_sequence.gd")
const SLOT: = "user://shadepi-chapter-two.cfg"
const YARD_START: = Vector2(145, 420)
const DOOR: = Vector2(876, 295)
const WORKBENCH: = Vector2(498, 311)
const SPRAY: = Vector2(530, 405)
const NET_AVATAR = preload("res://shaders/net_avatar.gdshader")
const NORMAL_AVATAR = preload("res://shaders/cloak.gdshader")
var net_avatar_clock := 0.0

const Threat = preload("res://scripts/dive_threat.gd")
const Guardian = preload("res://scripts/ice_guardian.gd")
const ICE_SCALE := 1.5
const ICE_BOSS := Vector2(1150, 530)
const ICE_START := Vector2(750, 520)
const BATH: = Vector2(670, 361)
const SCANS: Array[Vector2] = [Vector2(289, 311), Vector2(504, 442), Vector2(744, 316)]
const RELAYS: Array[Vector2] = [Vector2(350, 430), Vector2(552, 300), Vector2(812, 414)]

var section: = Section.YARD
var scan_index: = 0
var relay_index: = 0
var ice_cycle: = 0.0
var dive_hold: = 0.0
var spray_ready: = false
var bath_pending := 0 # 1 entry, 2 return, 3 spray rescue; 0 completed/idle
var ice_bath: Node2D
var threats: Array[Node2D] = []
var next_wave: = false
var previous_ice_open: = false

func create_hud() -> CanvasLayer:
	return ChapterHud.new()

func _ready() -> void :
	super._ready()
	# v0.54.1 · ClaudeHelper: Koop-Sitzung aus dem vorigen Kapitel übernehmen (vor und nach dem Laden,
	# weil ein Kontrollpunkt den Modus sonst auf Einzelspieler zurücksetzt).
	restore_coop_session()
	restore_coop_session.call_deferred()
	if preload("res://scripts/test_checkpoints.gd").consume(self): return
	if preload("res://scripts/checkpoint_resume.gd").consume(self): return
	if Admin.consume_chapter(get_tree(), "res://scenes/chapter_two.tscn") == 2:
		new_game(false)
	elif ChapterFlow.consume_entry(get_tree(), "res://scenes/chapter_two.tscn") or not load_game():
		new_game()

func world_props() -> Array[Dictionary]:
	return []

func world_walls() -> Array[Rect2]:
	return [] # Side boundaries belong to the active painted room / expanded ICE arena.

func _build_world() -> void :
	super._build_world()
	set_gate(true)
	enemy.hide()
	ground_atmosphere.hide()
	raven.hide()
	player.position = YARD_START

func combat_ready() -> bool:
	return section == Section.DIVE

func camera_home() -> Vector2:
	if raven_leads():
		return ice_camera_home()
	return super.camera_home()

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
	_sync_net_avatar(delta)
	if raven_leads() and not in_cinematic():
		camera.position = ice_camera_home()
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
	_scene_arrival()

## keep_positions: story steps inside the hideout keep both characters where
## the scene left them instead of snapping back to the room entrance.
func _enter(next: Section, saved_relay: int = 0, keep_positions: bool = false, saved_spray: bool = false, saved_bath: int = 0) -> void :
	cutscene.abort()
	if is_instance_valid(ice_bath):
		ice_bath.restore_actors()
		ice_bath.get_parent().remove_child(ice_bath)
		ice_bath.queue_free()
	ice_bath = null
	bath_pending = saved_bath if (next==Section.COOLING and saved_bath==1) or (next==Section.RECOVERY and saved_bath in [2,3]) else 0
	ui.clear_toast()
	section = next
	match section:
		Section.YARD:
			set_music_section("chapter_2_industry")
		Section.DIVE:
			set_music_section("chapter_2_ice_boss" if saved_relay == 2 else "chapter_2_dive")
		Section.RECOVERY, Section.COOLING, Section.END:
			set_music_section("chapter_2_recovery")
		_:
			set_music_section("chapter_2_hideout")
	set_dressing("industry" if next == Section.YARD else "dive" if next == Section.DIVE else "hideout")
	stage = 0
	scan_index = 0
	relay_index = clampi(saved_relay, 0, RELAYS.size() - 1) if next == Section.DIVE else 0
	_configure_ice_space()
	for threat in threats:
		threat.hide()
		threat.set_process(false)
		threat.queue_free()
	threats.clear()
	dive_hold = 0.0
	spray_ready = saved_spray if next==Section.RECOVERY else false
	if bath_pending==3: spray_ready = true
	next_wave = false
	previous_ice_open = false
	ice_cycle = 0.0
	ui.clear_dialogue()
	if not keep_positions:
		player.position = YARD_START if section == Section.YARD else IceBath.PLAYER_WAIT if section in [Section.COOLING,Section.RECOVERY] else IceBath.SUPPORT if section==Section.END else Vector2(440,430)
	player.health = 100
	player.energy = 100.0
	hack_cooldown = 0.0
	player.reset_transients()
	if raven_leads():
		reset_raven(ICE_START if relay_index == 2 else Vector2(145, 436) if relay_index == 0 else RELAYS[relay_index - 1])
	elif not keep_positions or section == Section.RECOVERY:
		reset_raven(IceBath.APPROACH if section==Section.COOLING else IceBath.EXIT if section==Section.END else BATH)
	else:
		reset_raven(raven.position)
	raven.modulate = Color.WHITE
	raven.body_material.shader = NET_AVATAR if raven_leads() else NORMAL_AVATAR
	raven.cast_shadow.visible = not raven_leads()
	raven.light_occluder.visible = not raven_leads()
	net_avatar_clock = 0.0
	_sync_net_avatar(0.0)
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
	if section in [Section.COOLING,Section.RECOVERY]:
		ice_bath = IceBath.new()
		ice_bath.world = self
		actors.add_child(ice_bath)
		if section==Section.RECOVERY: ice_bath.rest_recovery()

func _target() -> Vector2:
	match section:
		Section.YARD:
			return SCANS[scan_index] if scan_index < SCANS.size() else DOOR
		Section.HIDEOUT:
			return WORKBENCH
		Section.DIVE:
			return RELAYS[relay_index] * (ICE_SCALE if relay_index == 2 else 1.0)
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
			return "ICE-Wächter · Salven ausweichen, offenen Kern treffen" if ice_guardian() != null else "Datenspur verfolgen · %d / 3" % relay_index
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
			return "ICE-Wächter · Abkühlphase abwarten, nah ran: J / X" if relay_index == 2 else "ICE-Abwehr ausschalten · J / X"
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
				_scene_knock()
		Section.HIDEOUT:
			_scene_fragment()
		Section.DIVE:
			_trace_relay()
		Section.COOLING:
			_scene_dive()
		Section.RECOVERY:
			if spray_ready:
				_finish_chapter()
			else:
				spray_ready = true
				toast("Kryospray aufgenommen. Zurück zu Raven · E / A")
				autosave()

func _spawn_ice() -> void :
	var positions: Array[Vector2] = []
	if relay_index == 1:
		positions.assign([Vector2(500, 320)] if not next_wave else [Vector2(478, 330), Vector2(550, 367)])
	elif relay_index == 2:
		positions.assign([ICE_BOSS])
	for i in positions.size():
		var threat: Node2D = Guardian.new() if relay_index == 2 else Threat.new()
		threat.world = self
		threat.guardian = relay_index == 2 and i == 0
		threat.position = positions[i]
		actors.add_child(threat)
		threats.append(threat)


func _sync_net_avatar(delta: float) -> void:
	if not raven_leads(): return
	if not is_busy(): net_avatar_clock += delta
	var sprite: Sprite2D = raven.visual
	var frames := Vector2(sprite.hframes, sprite.vframes)
	var cell := Vector2(sprite.frame_coords)
	var texel := Vector2.ONE / sprite.texture.get_size()
	raven.body_material.set_shader_parameter("clock", net_avatar_clock)
	raven.body_material.set_shader_parameter("actor_origin", raven.global_position)
	raven.body_material.set_shader_parameter("cell_min", cell / frames + texel * 0.5)
	raven.body_material.set_shader_parameter("cell_max", (cell + Vector2.ONE) / frames - texel * 0.5)
	raven.body_material.set_shader_parameter("source_step", Vector2.ONE / sprite.scale.abs())

func ice_guardian() -> Node2D:
	for threat in threats:
		if is_instance_valid(threat) and threat.guardian: return threat
	return null

func ice_map_size() -> Vector2:
	return Vector2(1024, 640) * (ICE_SCALE if section == Section.DIVE and relay_index == 2 else 1.0)

func ice_cover() -> Array[Rect2]:
	var result: Array[Rect2] = []
	var factor := ICE_SCALE if relay_index == 2 else 1.0
	for box: Rect2 in Painted.SOLIDS["dive"]: result.append(Rect2(box.position * factor, box.size * factor))
	return result

func ice_camera_home() -> Vector2:
	var boss = ice_guardian()
	return raven.position.lerp(boss.position, 0.35) + Vector2(0, -35) if boss != null else raven.position + Vector2(0, -45)

func atmosphere_rect() -> Rect2:
	return Rect2(Vector2.ZERO, ice_map_size())

func _configure_ice_space() -> void:
	var expanded := section == Section.DIVE and relay_index == 2
	var factor := ICE_SCALE if expanded else 1.0
	var size := Vector2(1024, 640) * factor
	# Rebuild room collisions AND occluding pixel pieces at identical transforms.
	set_painted_solids("dive" if section == Section.DIVE else "industry" if section == Section.YARD else "hideout")
	if expanded:
		for body in painted_solids:
			body.position *= factor
			for child in body.get_children():
				if child is CollisionShape2D:
					child.shape = child.shape.duplicate()
					child.shape.size *= factor
		for mask in painted_masks:
			mask.position *= factor
			mask.scale *= factor
		for prop in destructibles: prop.position *= factor
	painted_solids.append(_collider(Rect2(-20, 0, 20, size.y), false))
	painted_solids.append(_collider(Rect2(size.x, 0, 20, size.y), false))
	camera.limit_right = int(size.x)
	camera.limit_bottom = int(size.y)
	camera.zoom = Vector2.ONE * (0.85 if expanded else 1.0)
	if expanded:
		toast("Hinter Datenwänden in Deckung! Cyan = Kern offen. Nah heran: J / X. Ausweichen: Leertaste / B.")

func dive_blocked(point: Vector2, radius: float) -> bool:
	for box: Rect2 in ice_cover():
		if box.grow(radius).has_point(point):
			return true
	return false

## Raven's net shots lock onto the nearest ICE inside a forgiving cone, so the
## eight-way stick aim never feels like a miss on a visibly targeted enemy.
func _dive_aim(origin: Vector2) -> Node2D:
	var best: Node2D
	var best_score := INF
	for threat in threats:
		var offset: Vector2 = threat.position - origin
		var distance := offset.length()
		if distance > 170.0 or distance < 1.0:
			continue
		var along := offset.dot(raven.facing)
		if along <= 0.0 or absf(offset.cross(raven.facing)) > 26.0 + distance * 0.18:
			continue
		if not _line_clear(origin, threat.position):
			continue
		if distance < best_score:
			best_score = distance
			best = threat
	return best

func raven_energy_attack() -> bool:
	return raven_leads()

func raven_shot() -> void :
	if not raven_leads():
		return
	var origin: Vector2 = raven.position
	var endpoint: Vector2 = origin + raven.facing * 152.0
	var wall: = trace_scenery(origin, endpoint)
	if not wall.is_empty():
		endpoint = wall.position
	var hit_threat: = _dive_aim(origin)
	if hit_threat != null:
		endpoint = hit_threat.position
		if hit_threat.guardian:
			hit_threat.receive_strike(raven, 1)
		elif hit_threat.vulnerable():
			_destroy_threat(hit_threat)
		else:
			hit_threat.crack(origin)
			effects.burst(hit_threat.position, Color("e2c6ff"), 10)
			damage_number(hit_threat.position + Vector2(-10, -40), "RISS")
			hitstop(0.04)
			shake = 2.5
			sound("hit", 0.15)
	elif not wall.is_empty() and wall.collider is WorldProp:
		wall.collider.take_damage(17)
	raven_attack_fx(endpoint, true)

func _destroy_threat(target: Node2D) -> void:
	effects.burst(target.position, Color("97f7ff"), 30)
	effects.slash(target.position + Vector2(0, 14), Vector2.RIGHT)
	damage_number(target.position + Vector2(-14, -44), "GELÖSCHT", true)
	hitstop(0.07)
	shake = 4.0
	sound("hit", 0.2)
	threats.erase(target)
	target.set_process(false)
	target.queue_free()
	if threats.is_empty() and relay_index == 1 and not next_wave:
		next_wave = true
		_spawn_ice()

func raven_hack() -> bool:
	if not raven_leads() or is_busy() or hack_cooldown > 0.0:
		return false
	var boss = ice_guardian()
	if boss != null and boss.vulnerable() and raven.position.distance_to(boss.position) < 180.0 and _line_clear(raven.position, boss.position):
		boss.extend_cooling()
		hack_cooldown = 7.0
		effects.hack_arc(raven.position, boss.position)
		sound("hack")
		return true
	return false

func special_targets() -> Array[Node2D]:
	var targets := super.special_targets()
	if section == Section.DIVE:
		targets.append_array(threats)
	return targets

func special_hit(target: Node2D, amount: int, source: PixelActor, kick: bool) -> void:
	if target not in threats:
		super.special_hit(target, amount, source, kick)
		return
	if target.guardian:
		target.receive_strike(source, 2 if amount >= 60 else 1)
		return
	if not target.vulnerable():
		target.crack(source.position)
		damage_number(target.position + Vector2(-10, -40), "RISS")
		return
	_destroy_threat(target)

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
	if relay_index == 2:
		_configure_ice_space()
		reset_raven(ICE_START)
		set_music_section("chapter_2_ice_boss")
	autosave()
	_spawn_ice()
	toast(["Seriennummer bestätigt. Zahlungsweg suchen.", "Wächter: Salven ausweichen · Leertaste / B. Beim cyanfarbenen Kern nah ran und J / X!"][relay_index - 1])

func _finish_download() -> void :
	effects.burst(raven.position, Color("b992ff"), 55)
	_enter(Section.RECOVERY, 0, true)
	autosave()
	_scene_return()

func _finish_chapter() -> void :
	_scene_oath()

# --- Zwischensequenzen Kapitel 2 (nach „Shadepi – Im Schatten des Raben“) ---

func _scene_arrival() -> void:
	var cs = begin_cutscene()
	var ticket: int = cs.generation
	player.facing = Vector2.RIGHT
	cs.pose(player, "idle")
	await cs.camera(player.position + Vector2(140, -70), 0.0, 1.0)
	if not cs.alive(ticket): return
	await cs.fade(Color.BLACK, 0.0)
	if not cs.alive(ticket): return
	await cs.fade(Color(0, 0, 0, 0), 1.0)
	if not cs.alive(ticket): return
	await cs.title("KAPITEL 2", "Offenbarungen im Verborgenen", 2.4)
	if not cs.alive(ticket): return
	await cs.say("INDUSTRIEGEBIET", "Verrostete Gerippe von Fabriken ragen wie die Knochen toter Leviathane in den giftgrünen Nachthimmel.")
	if not cs.alive(ticket): return
	await cs.camera(player.position + Vector2(40, -60), 0.6, 1.15)
	if not cs.alive(ticket): return
	player.visual.position.y = player.standing_visual_position.y - 180.0
	await cs.drop(player, 180.0, 0.4)
	if not cs.alive(ticket): return
	cs.do(func():
		effects.water_step(player.position)
		effects.burst(player.position, Color("a7b9a0"), 12)
	)
	await cs.wait(0.4)
	if not cs.alive(ticket): return
	await cs.camera(DOOR + Vector2(-60, -40), 1.4, 1.0)
	if not cs.alive(ticket): return
	await cs.say("SHADEPI", "Jeder Instinkt schreit nach Vorsicht. Erst die Umgebung scannen – Fluchtwege, Schützennester, Schwachstellen. Dann klopfe ich an.")
	if not cs.alive(ticket): return
	cs.end()

func _scene_knock() -> void:
	var cs = begin_cutscene()
	var ticket: int = cs.generation
	await cs.walk(player, DOOR + Vector2(0, 30), 80)
	if not cs.alive(ticket): return
	cs.face(player, DOOR)
	cs.pose(player, "idle")
	await cs.camera(DOOR + Vector2(0, -20), 0.6, 1.3)
	if not cs.alive(ticket): return
	for i in 3:
		cs.do(func():
			sound("prop_metal")
			shake = 2.0
		)
		await cs.wait(0.42)
		if not cs.alive(ticket): return
	await cs.wait(0.5)
	if not cs.alive(ticket): return
	await cs.say("STAHLTÜR", "Ein lautes, protestierendes Knarren.")
	if not cs.alive(ticket): return
	await cs.fade(Color.BLACK, 0.5)
	if not cs.alive(ticket): return
	cs.do(func():
		_enter(Section.HIDEOUT)
		autosave()
		_scene_hideout()
	)

func _scene_hideout() -> void:
	var cs = begin_cutscene()
	var ticket: int = cs.generation
	player.facing = Vector2.RIGHT
	raven.position = BATH + Vector2(-30, 30)
	raven.facing = Vector2.LEFT
	cs.pose(player, "idle")
	cs.pose(raven, "idle")
	await cs.camera(player.position.lerp(raven.position, 0.5) + Vector2(0, -40), 0.0, 1.25)
	if not cs.alive(ticket): return
	await cs.fade(Color.BLACK, 0.0)
	if not cs.alive(ticket): return
	await cs.fade(Color(0, 0, 0, 0), 0.8)
	if not cs.alive(ticket): return
	await cs.say("RAVENS VERSTECK", "Ein Nervenzentrum, ein Altar für den digitalen Gott. Kabel schlängeln sich über den Boden, in der Mitte steht eine Wanne mit trübem Eiswasser.")
	if not cs.alive(ticket): return
	for point in [Vector2(640,452),Vector2(490,452),player.position+Vector2(56,-18)]:
		await cs.walk(raven,point,70)
		if not cs.alive(ticket):return
	if not cs.alive(ticket): return
	cs.face(raven, player.position)
	cs.face(player, raven.position)
	cs.pose(raven, "idle")
	await cs.lines([
		["RAVEN", "Ah, da bist du ja. Ihr Ninjas seid nicht gerade pünktlich."],
		["SHADEPI", "Du hast keine Zeit gesagt."],
		["RAVEN", "Also … nach was suchst du? Welche Information?"],
	])
	if not cs.alive(ticket): return
	cs.end()

func _scene_fragment() -> void:
	var cs = begin_cutscene()
	var ticket: int = cs.generation
	cs.camera(WORKBENCH + Vector2(10, -30), 1.0, 1.3)
	cs.walk(raven, WORKBENCH + Vector2(46, 22), 70)
	await cs.walk(player, WORKBENCH + Vector2(-20, 24), 70)
	if not cs.alive(ticket): return
	cs.face(player, WORKBENCH)
	cs.face(raven, WORKBENCH)
	cs.pose(player, "attack")
	cs.do(func(): effects.burst(WORKBENCH + Vector2(0, -6), Color("e9b26f"), 10))
	await cs.wait(0.4)
	if not cs.alive(ticket): return
	cs.pose(player, "idle")
	cs.pose(raven, "idle")
	await cs.lines([
		["MONITORLICHT", "Auf dem Metall spiegelt sich eine eingravierte Seriennummer: Militech Minotaurus XC2534S."],
		["SHADEPI", "Ich brauche Informationen über den Betreiber dieser Mechs. Seit fünf Jahren suche ich nach Spuren. Jeder, der etwas wusste, hat sich lieber selbst umgebracht, als mit mir zu reden."],
		["SHADEPI", "Ich bin der letzte Überlebende des Ordens des Weißen Drachen. Ich suche den Schuldigen für das Massaker an meinem Orden."],
		["RAVEN", "Da du mir geholfen hast, werde ich sehen, was ich für dich tun kann."],
	])
	if not cs.alive(ticket): return
	await cs.walk(raven, BATH + Vector2(-26, 20), 70)
	if not cs.alive(ticket): return
	cs.face(raven, player.position)
	cs.pose(raven, "idle")
	await cs.say("RAVEN", "Falls ich einen Kurzschluss erleide … verschwinde von hier.")
	if not cs.alive(ticket): return
	cs.end(func():
		_enter(Section.COOLING, 0, true)
		autosave()
	)

func _scene_dive() -> void:
	ice_bath.play_entry()

func _scene_return() -> void:
	ice_bath.play_return()

func _scene_oath() -> void:
	ice_bath.play_rescue()

func _oath_words(cs) -> void:
	await cs.lines([
		["SHADEPI", "Besser?"],
		["RAVEN", "Ja … Gib mir einen Moment."],
		["SHADEPI", "Dein Kreislauf und deine Herzfrequenz sind ungewöhnlich hoch. Was hast du gefunden?"],
		["RAVEN", "Ich bin auf jemanden gestoßen, den ich selbst verfolge. Oder besser gesagt: dem ich versuche zu entkommen."],
		["SHADEPI", "Hast du deine Spuren verwischt? Von wem sprichst du?"],
		["RAVEN", "Ich bin keine Anfängerin! Kenzō Moriyama. Ein hohes Tier bei Arasaka – Finanzen, Spionage, ein sadistischer Mistkerl."],
		["RAVEN", "Ich weiß nicht, ob er für dein Massaker verantwortlich ist. Aber die Spuren der Minotauren führen direkt zu einem seiner verdeckten Projekte. Ich stehe selbst auf seiner Liste. Bleib lieber weg von ihm."],
		["SHADEPI", "Ich lasse nicht zu, dass dir etwas geschieht. Was auch immer dir passiert ist – ich werde dich rächen, so wie ich meine Brüder und Schwestern rächen werde."],
		["SHADEPI", "Ich, Shadepi, der letzte Krieger des Ordens des Weißen Drachen, verspreche dir, sie dafür bezahlen zu lassen."],
	])

func _scene_chapter_end() -> void:
	var cs = begin_cutscene()
	var ticket: int = cs.generation
	await cs.title("KAPITEL 2 · ENDE", "Auf den Monitoren bleibt ein Name stehen: Kenzō Moriyama", 2.8)
	if not cs.alive(ticket): return
	cs.end(func(): toast("E / A · Weiter zu Kapitel 3"))

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
	config.set_value("resume","solo_time",Time.get_unix_time_from_system())
	config.set_value("chapter", "section", section)
	config.set_value("chapter", "relay", relay_index)
	config.set_value("chapter", "spray_ready",spray_ready)
	config.set_value("chapter", "bath_pending",bath_pending)
	config.set_value("props", "state", dressing_state())
	return config.save(Admin.checkpoint_path(SLOT, get_tree())) == OK

func load_game(_requested_mode: Variant = null) -> bool:
	var saved: = saved_checkpoint()
	if saved < 0:
		return false
	var config: = ConfigFile.new()
	config.load(Admin.checkpoint_path(SLOT, get_tree()))
	restore_dressing_state(config.get_value("props", "state", {}))
	var relay: Variant = config.get_value("chapter","relay",0)
	var spray: Variant = config.get_value("chapter","spray_ready",false)
	var pending: Variant = config.get_value("chapter","bath_pending",0)
	_enter(saved as Section,relay if relay is int else 0,false,spray is bool and spray,pending if pending is int else 0)
	if bath_pending==1: ice_bath.play_entry()
	elif bath_pending==2: ice_bath.play_return()
	elif bath_pending==3: ice_bath.play_rescue()
	return true

func _draw() -> void :
	var net: = raven_leads()
	var tint: = Color("225b70") if net else Color("353f4e")
	var accent: = (Color("69ecff") if _ice_open() else Color("ff537e")) if net else Color("b5c575") if section == Section.YARD else Color("6dc6b6")
	if section == Section.YARD:
		draw_texture_rect(Painted.ART.industry, Rect2(0, 0, 1024, 640), false)
	elif net:
		draw_texture_rect(Painted.ART.dive, Rect2(Vector2.ZERO, ice_map_size()), false)
		if not _ice_open() and relay_index != 2:
			var scan_y: = 271.0 + fposmod(ice_cycle * 114.0, 211.0)
			draw_rect(Rect2(0, scan_y, 1024, 2), Color(0.76, 0.16, 0.33, 0.45))
			draw_rect(Rect2(0, scan_y - 5, 1024, 5), Color(0.62, 0.1, 0.24, 0.18))
		var points := PackedVector2Array()
		for point in RELAYS: points.append(point * (ICE_SCALE if relay_index == 2 else 1.0))
		draw_polyline(points, accent.darkened(0.64), 1.0)

		if relay_index == 0 and raven.position.distance_to(RELAYS[0]) < 75.0:
			var gauge: = RELAYS[0] + Vector2(-48, -66)
			draw_rect(Rect2(gauge, Vector2(96, 8)), Color("221b37"))
			draw_rect(Rect2(gauge + Vector2(40, 0), Vector2(16, 8)), Color("45cad8"))
			draw_rect(Rect2(gauge + Vector2(ice_cycle * 40.0, -2), Vector2(2, 12)), Color.WHITE)
		for i in RELAYS.size():
			draw_circle(RELAYS[i] * (ICE_SCALE if relay_index == 2 else 1.0), 15, accent.darkened(0.65) if i < relay_index else tint, false, 2)
	else:
		draw_texture_rect(Painted.ART.hideout, Rect2(0, 0, 1024, 640), false)
		if section == Section.RECOVERY:
			draw_rect(Rect2(SPRAY + Vector2(-4, -11), Vector2(8, 11)), tint if spray_ready else Color("a5e3e8"))
	var marker: = Vector2.ZERO if in_cinematic() else _target()
	var marker_actor: PixelActor = raven if raven_leads() else player
	PixelMarker.show(self, [[marker, marker_actor.position.distance_to(marker) <= 43.0, net and not _ice_open(), 40.0]] if marker != Vector2.ZERO else [])
