extends "res://scripts/main.gd"

enum Phase { APARTMENT, HUNT, DUEL, ROOFTOP, RESCUE, REVIVE, TEAM, COMPLETE, EPILOGUE }

const ChapterHud = preload("res://scripts/chapter_hud.gd")
const Arcade = preload("res://scripts/arcade_encounter.gd")
const Waves = preload("res://scripts/arcade_waves.gd")
const CHAPTER_SAVE := "user://shadepi-chapter-one.cfg"
const WEST_EDGE := -640
const STREET_HEIGHT_OFFSET := 12
const DUEL_DURATION := 30.0
const JACKAL_HEALTH := 360
const APARTMENT_EXIT := Vector2(-554, 356)
## Ravens Apartment wird im Figurenmaßstab gezeichnet (Tür ≈ 1,25 × Ravens Höhe)
## statt auf 640 × 640 gestaucht. apartment_point() rechnet Bildkoordinaten
## (1024 × 640) in Weltkoordinaten um.
const APARTMENT_SCALE := 0.46
const APARTMENT_RECT := Rect2(-555.5, 150, 471.04, 294.4)
const APARTMENT_CAMERA := Vector2(-320, 300)
const APARTMENT_ZOOM := 1.36

static func apartment_point(point: Vector2) -> Vector2:
	return APARTMENT_RECT.position + point * APARTMENT_SCALE
const EXIT_DOOR := Vector2(961, 255)
const PUNKS := [
	preload("res://assets/sprites/npcs/punk-1.png"), preload("res://assets/sprites/npcs/punk-2.png"),
	preload("res://assets/sprites/npcs/punk-3.png"), preload("res://assets/sprites/npcs/punk-4.png"),
]
const ARENA_ENTRY := Vector2(568, 356)
const DOWNED_SPOT := Vector2(636, 365)
const RESCUE_START := Vector2(295, 451)
const BARRIERS: Array[Rect2] = [
	Rect2(-441, 284, 36, 107), Rect2(-270, 388, 41, 104), Rect2(-113, 284, 38, 107),
	Rect2(181, 272, 29, 128), Rect2(381, 375, 28, 121),
]
const TRAIL: Array[Vector2] = [
	Vector2(-443, 448), Vector2(-246, 346), Vector2(-77, 448),
	Vector2(219, 451), Vector2(391, 343), Vector2(475, 365),
]

var phase := Phase.APARTMENT
var checkpoint := Phase.APARTMENT
var chapter_coop := false
var trail_index := 0
var duel_time := 0.0
var assist_time := 0.0
var feedback_time := 0.0
var raven_joined := false
var counter_warning := false
var patrol: Array[PixelActor] = []
var street_lights: Array[PointLight2D] = []
var apartment_lights: Array[PointLight2D] = []
var encounter: Node2D
var intro: Node2D

func _ready() -> void:
	super._ready()
	intro = preload("res://scripts/chapter_one_intro.gd").new()
	intro.world = self
	add_child(intro)
	if preload("res://scripts/test_checkpoints.gd").consume(self): return
	if preload("res://scripts/checkpoint_resume.gd").consume(self): return
	if Admin.consume_chapter(get_tree(), "res://scenes/chapter_one.tscn") == 1:
		new_game(false)

func create_hud() -> CanvasLayer:
	return ChapterHud.new()

func world_walls() -> Array[Rect2]:
	var walls: Array[Rect2] = WorldData.WALLS.duplicate()
	walls.erase(Rect2(-20, 0, 20, 640))
	walls.append_array([Rect2(WEST_EDGE - 20, 0, 20, 640), Rect2(WEST_EDGE, 0, 640, 272), Rect2(WEST_EDGE, 496, 640, 144)])
	return walls

func set_coop(enabled: bool) -> void:
	super.set_coop(enabled)
	camera.limit_left = WEST_EDGE

func _build_world() -> void:
	super._build_world()
	camera.limit_left = WEST_EDGE
	effects.rain_start = WEST_EDGE
	enemy.max_health = JACKAL_HEALTH
	var west := Sprite2D.new()
	west.name = "BingoStreet"
	west.texture = Painted.ART.market
	var join := ShaderMaterial.new()
	join.shader = preload("res://shaders/street_join.gdshader")
	join.set_shader_parameter("alley_art", Painted.ART.alley)
	join.set_shader_parameter("west_height_offset", float(STREET_HEIGHT_OFFSET))
	west.material = join
	west.scale = Vector2(704, 640) / west.texture.get_size()
	west.centered = false
	west.position.x = WEST_EDGE
	west.z_index = -9
	add_child(west)
	for point in [Vector2(-537, 283), Vector2(-315, 390), Vector2(-170, 318), Vector2(-61, 438)]:
		_halo(point, Color(0.9, 0.24, 0.43, 0.44), 0.8)
		street_lights.append(_light(point, Color("f66892"), 1.55, 1.0))
	apartment_lights = [
		_light(apartment_point(Vector2(180, 230)), Color("6abac9"), 1.3, 0.63),
		_light(apartment_point(Vector2(800, 170)), Color("e0a36f"), 1.0, 0.42),
	]
	for light in apartment_lights:
		light.enabled = false
	for barrier in BARRIERS:
		_collider(barrier)
	add_painted_masks("market", Vector2(WEST_EDGE, STREET_HEIGHT_OFFSET), Vector2(640, 640))
	add_painted_masks("alley")
	_halo(Vector2(197, 383), Color(0.94, 0.2, 0.55, 0.42), 0.67)
	_halo(Vector2(395, 386), Color(0.17, 0.87, 0.95, 0.42), 0.72)
	_light(Vector2(219, 404), Color("ed539f"), 1.0, 0.8)
	_light(Vector2(399, 359), Color("67d9e8"), 1.0, 0.9)
	player.hide()
	raven.position = APARTMENT_EXIT
	enemy.hide()

func atmosphere_profile() -> String:
	return "apartment" if phase == Phase.APARTMENT else "street"

func atmosphere_rect() -> Rect2:
	return APARTMENT_RECT if phase == Phase.APARTMENT else Rect2(0,0,1024,640)

func combat_ready() -> bool:
	return phase in [Phase.HUNT, Phase.DUEL, Phase.RESCUE, Phase.TEAM]

func raven_leads() -> bool:
	return phase in [Phase.APARTMENT, Phase.HUNT, Phase.DUEL]

func actor_is_playable(actor: PixelActor) -> bool:
	if raven_leads():
		return actor == raven
	return phase in [Phase.RESCUE, Phase.TEAM] and super.actor_is_playable(actor)

func actor_input_prefix(actor: PixelActor) -> String:
	return "" if raven_leads() else super.actor_input_prefix(actor)

func hack_origin() -> Vector2:
	return raven.position

func hack_input_hint() -> String:
	if phase == Phase.DUEL and gamepads.shadepi_device >= 0:
		return "Q / Y / RB"
	return super.hack_input_hint()

func combat_target(origin: Vector2, include_cloaked: bool = false) -> PixelActor:
	if phase in [Phase.HUNT, Phase.DUEL]:
		return raven
	if phase == Phase.TEAM:
		if raven_joined and not coop and (player.cloak_time > 0.0 or origin.distance_squared_to(raven.position) < origin.distance_squared_to(player.position)):
			return raven
		return super.combat_target(origin, include_cloaked)
	if phase == Phase.RESCUE:
		return super.combat_target(origin, include_cloaked)
	return null

func _unhandled_input(event: InputEvent) -> void:
	if phase == Phase.DUEL and not is_busy() and not event.is_echo() and event.is_action_pressed("cloak"):
		raven_hack()
		get_viewport().set_input_as_handled()
		return
	super._unhandled_input(event)

func _process(delta: float) -> void:
	super._process(delta)
	if (raven_leads() or phase == Phase.ROOFTOP) and not in_cinematic():
		camera.position = raven.position + Vector2(0, -57) + raven.facing * 8
	if is_busy():
		return
	match phase:
		Phase.HUNT:
			if trail_index < TRAIL.size() and raven.position.distance_to(TRAIL[trail_index]) < 39.0:
				trail_index += 1
				_check_hunt_gate()
			elif gate_open and raven.position.x > ARENA_ENTRY.x:
				_begin_duel()
		Phase.DUEL:
			duel_time = minf(DUEL_DURATION, duel_time + delta)
			if duel_time >= DUEL_DURATION:
				_lose_duel()
			elif duel_time >= 26.0 and not counter_warning:
				counter_warning = true
				toast("Raven: Er hängt sich an mein Deck. Raus aus der Verbindung!")
		Phase.ROOFTOP:
			feedback_time -= delta
			if feedback_time <= 0.0:
				_rooftop_dialogue()
		Phase.TEAM:
			if not raven_joined and enemy.health <= (JACKAL_HEALTH >> 1):
				_raven_rejoins()
			elif raven_joined and not coop:
				assist_time = maxf(0.0, assist_time - delta)
				if assist_time == 0.0 and raven.position.distance_to(enemy.position) <= 140.0 and _line_clear(raven.position, enemy.position):
					assist_time = 1.7
					raven.facing = (enemy.position - raven.position).normalized()
					raven.animate("attack", delta)
					raven_shot()
	if effects.rain and raven_leads() and raven.velocity.length() > 45.0 and next_step_ripple <= 0.0:
		effects.water_step(raven.position)
		next_step_ripple = 0.13

func _update_raven_follower(delta: float) -> void:
	if phase == Phase.TEAM and raven_joined:
		super._update_raven_follower(delta)

func new_game(save_checkpoint: bool = true) -> void:
	restore_dressing_state({})
	_enter_checkpoint(Phase.APARTMENT)
	if save_checkpoint:
		autosave()

func _enter_checkpoint(next_phase: Phase, saved_section: int = 0) -> void:
	cutscene.abort()
	ui.clear_toast()
	cancel_terminal()
	_clear_encounter()
	ui.clear_dialogue()
	for foe in patrol:
		foe.hide()
		foe.set_physics_process(false)
		foe.queue_free()
	patrol.clear()
	checkpoint = next_phase
	phase = next_phase
	match phase:
		Phase.APARTMENT:
			set_music_section("chapter_1_apartment")
		Phase.HUNT:
			set_music_section("chapter_1_hunt")
		Phase.DUEL:
			set_music_section("chapter_1_duel")
		Phase.ROOFTOP:
			set_music_section("chapter_1_rooftop")
		Phase.RESCUE, Phase.REVIVE:
			set_music_section("chapter_1_rescue")
		Phase.TEAM:
			set_music_section("boss")
		_:
			set_music_section("chapter_1_finale")
	stage = 4 if phase == Phase.COMPLETE else (2 if phase == Phase.TEAM else 1)
	raven_joined = false
	set_coop(false)
	set_gate(phase in [Phase.TEAM, Phase.COMPLETE])
	hack_cooldown = 0.0
	assist_time = 0.0
	trail_index = 0
	player.position = DOWNED_SPOT + Vector2(-35, 8)
	if phase == Phase.RESCUE:
		player.position = RESCUE_START
	elif phase == Phase.COMPLETE:
		player.position = Vector2(919, 223)
	player.health = 100
	player.energy = 100.0
	player.reset_transients()
	player.reset_visual_pose()
	player.facing = Vector2.RIGHT
	player.visible = not raven_leads()
	reset_raven(APARTMENT_EXIT if raven_leads() else DOWNED_SPOT)
	raven.visible = phase != Phase.COMPLETE
	raven.health_floor = 0
	raven.facing = Vector2.RIGHT
	raven.reset_visual_pose()
	enemy.position = WorldData.JACKAL
	enemy.armoured = false
	enemy.min_health = (JACKAL_HEALTH >> 1) if phase == Phase.TEAM else 0
	enemy.move_speed = 54.0
	enemy.hit_damage = 22
	enemy.windup_duration = 0.65
	enemy.attack_recovery = 0.95
	enemy.lunge_speed = 235.0
	enemy.reset_fight(0 if phase == Phase.COMPLETE else enemy.max_health)
	enemy.active = phase == Phase.TEAM
	enemy.visible = enemy.active
	close_menu()
	_update_apartment_lighting()
	set_dressing("" if phase == Phase.APARTMENT else "street")
	match phase:
		Phase.APARTMENT:
			_scene_apartment()
		Phase.HUNT:
			_start_arcade(saved_section)
		Phase.RESCUE, Phase.TEAM:
			_down_raven()
			if phase == Phase.RESCUE:
				_start_arcade(saved_section)

func _update_apartment_lighting() -> void:
	effects.rain = phase != Phase.APARTMENT
	for mask in painted_masks:
		mask.visible = effects.rain
	ambient.color = Color("b8c4eb") if effects.rain else Color("c0d4dc")
	for light in world_lights:
		light.enabled = effects.rain
	for light in apartment_lights:
		light.enabled = not effects.rain
	for light in street_lights:
		light.enabled = effects.rain

## Kapitel 1: Ravens Morgen – nach dem Roman „Im Schatten des Raben“.
func _scene_apartment() -> void:
	intro.play_apartment()

func _leave_apartment() -> void:
	phase = Phase.HUNT
	set_music_section("chapter_1_hunt")
	set_dressing("street")
	_update_apartment_lighting()
	checkpoint = Phase.HUNT
	_start_arcade()
	autosave()

func _clear_encounter() -> void:
	if is_instance_valid(encounter):
		remove_child(encounter)
		encounter.queue_free()
	encounter = null

func _start_arcade(saved_section: int = 0) -> void:
	_clear_encounter()
	var plan: Array = Waves.HUNT if phase == Phase.HUNT else Waves.RESCUE
	var index := clampi(saved_section, 0, plan.size() - 1)
	var actor: PixelActor = raven if raven_leads() else player
	actor.position = plan[index].start
	if phase == Phase.HUNT:
		trail_index = plan[index].trail
	encounter = Arcade.new()
	add_child(encounter)
	encounter.configure(self, plan, _spawn_patrol, index)
	encounter.section_changed.connect(func():
		if phase == Phase.HUNT:
			trail_index = maxi(trail_index, plan[encounter.section_index].trail)
		autosave()
	)
	encounter.completed.connect(func():
		if phase == Phase.HUNT:
			_check_hunt_gate()
		else:
			set_gate(true)
			toast("Wartungsgasse frei. Raven liegt hinter der Schleuse.")
	)

func _down_raven() -> void:
	raven.health = 0
	raven.reset_transients()
	raven.visual.rotation = PI * 0.5
	raven.visual.position.y = -9

func _guards_left() -> int:
	var living := 0
	for guard in patrol:
		if guard.health > 0:
			living += 1
	return living

func _check_hunt_gate() -> void:
	if _hunt_terminal_ready():
		toast("Raven: Wachen erledigt. Jetzt die Torschleuse am Terminal hacken.")

func _hunt_terminal_ready() -> bool:
	return phase == Phase.HUNT and not gate_open and trail_index == TRAIL.size() and _guards_left() == 0 and (encounter == null or encounter.finished)

func _begin_duel() -> void:
	_clear_encounter()
	phase = Phase.DUEL
	set_music_section("boss")
	stage = 2
	duel_time = 0.0
	counter_warning = false
	set_gate(false)
	raven.health = 100
	raven.health_floor = 1
	enemy.show()
	enemy.armoured = true
	enemy.move_speed = 77.0
	enemy.hit_damage = 32
	enemy.windup_duration = 0.47
	enemy.attack_recovery = 0.53
	enemy.lunge_speed = 295.0
	enemy.active = true
	_scene_jackal()

## Kapitel 1: Jackal tritt aus dem Schatten des Wartungshofs.
func _scene_jackal() -> void:
	var cs = begin_cutscene()
	cs.pose(raven, "idle")
	cs.pose(enemy, "idle")
	cs.face(raven, enemy.position)
	cs.face(enemy, raven.position)
	await cs.camera(raven.position.lerp(enemy.position, 0.5) + Vector2(0, -55), 1.1, 1.15)
	await cs.walk(enemy, enemy.position + (raven.position - enemy.position).normalized() * 36.0, 38)
	cs.face(enemy, raven.position)
	cs.pose(enemy, "idle")
	await cs.lines([
		["CHROME JACKAL", "Was will so ein Püppchen von mir? Hast du dich verlaufen, Kleine?"],
		["RAVEN", "Ich bin wegen deines Kopfgelds hier. Mal sehen, wie lange deine Panzerung hält, wenn ich die Steuerung finde."],
		["CHROME JACKAL", "Meine Leute senden nicht mehr. Dann steck dich ruhig ein – die letzte Netrunnerin hat denselben Fehler gemacht."],
	])
	cs.do(func():
		effects.hack_arc(raven.position + Vector2(4, -22), enemy.position + Vector2(0, -26))
		sound("hack")
	)
	await cs.wait(0.35)
	cs.end(func(): toast("Raven: Handshake läuft. Halt ihn auf Abstand!"))

## Kapitel 1: Shadepi springt vom Dach in die Wartungsgasse.
func _scene_shadepi_lands() -> void:
	intro.play_landing()

func camera_home() -> Vector2:
	if raven_leads() or phase == Phase.ROOFTOP:
		return raven.position + Vector2(0, -57) + raven.facing * 8
	return super.camera_home()

func raven_hack() -> bool:
	if phase == Phase.DUEL:
		toast("Raven: Seine Firewall hält. Ich brauche noch Zeit.")
		return false
	if phase != Phase.TEAM or not raven_joined or is_busy():
		return false
	return super.raven_hack()

func _lose_duel() -> void:
	raven.health_floor = 0
	effects.hack_arc(raven.position, enemy.position)
	effects.hack_arc(enemy.position, raven.position)
	effects.burst(raven.position, Color("86e8ff"), 36)
	effects.burst(enemy.position, Color("ff596e"), 24)
	_down_raven()
	phase = Phase.ROOFTOP
	set_music_section("chapter_1_rooftop")
	stage = 1
	enemy.active = false
	enemy.windup = 0.0
	enemy.lunge = 0.0
	enemy.velocity = Vector2.ZERO
	camera.position = raven.position + Vector2(0, -65)
	feedback_time = 0.85
	shake = 8.0
	sound("hack")

## Kapitel 1: Jackal steht über Raven – hoch oben bemerkt Shadepi den Kampf.
func _rooftop_dialogue() -> void:
	feedback_time = INF
	var cs = begin_cutscene()
	var ticket: int = cs.generation
	cs.pose(raven, "hurt")
	cs.pose(enemy, "idle")
	await cs.camera(raven.position + Vector2(20, -50), 0.6, 1.2)
	if not cs.alive(ticket): return
	await cs.say("RAVEN", "Er hat die Verbindung umgedreht … meine Beine. Ich kann sie nicht bewegen.")
	if not cs.alive(ticket): return
	await cs.walk(enemy, raven.position + Vector2(44, -6), 46)
	if not cs.alive(ticket): return
	cs.face(enemy, raven.position)
	cs.pose(enemy, "idle")
	await cs.say("CHROME JACKAL", "Dein Deck hat mir die Tür aufgemacht. Jetzt kassiere ich dein Kopfgeld.")
	if not cs.alive(ticket): return
	await intro.observe(cs, true)
	if not cs.alive(ticket): return
	await cs.fade(Color.BLACK, 0.4)
	if not cs.alive(ticket): return
	_enter_checkpoint(Phase.RESCUE)
	autosave()
	_scene_shadepi_lands()

func _spawn_patrol(point: Vector2, variant: int) -> PixelActor:
	var foe := EnemyScript.new()
	foe.max_health = 32 if phase == Phase.HUNT else 39
	foe.hit_damage = 11 + variant
	foe.move_speed = 45.0 + variant * 4.0
	foe.awareness = 148.0
	foe.shot_range = 148.0 if variant == 1 else 0.0
	foe.setup(PUNKS[variant], self)
	foe.position = point
	actors.add_child(foe)
	foe.reset_fight(foe.max_health)
	foe.active = true
	patrol.append(foe)
	return foe

func raven_shot_target(origin: Vector2) -> PixelActor:
	if phase != Phase.HUNT:
		return super.raven_shot_target(origin)
	var nearest: PixelActor
	for guard in patrol:
		if guard.health > 0 and raven_can_hit(guard, origin):
			if nearest == null or origin.distance_squared_to(guard.position) < origin.distance_squared_to(nearest.position):
				nearest = guard
	return nearest

func player_strike(amount: int) -> void:
	if phase != Phase.TEAM:
		strike_scenery(player.position, player.facing, amount)
	if phase == Phase.RESCUE:
		for foe in patrol:
			if CombatRules.can_strike(player.position, player.facing, foe.position) and _line_clear(player.position, foe.position):
				foe.take_damage(amount, player.position)
	elif phase == Phase.TEAM:
		super.player_strike(amount)

func interaction_prompt() -> String:
	if _hunt_terminal_ready() and raven.position.distance_to(TRAIL.back()) < 43.0:
		return "E / A · Raven: Jackals Torschleuse hacken"
	if phase == Phase.COMPLETE:
		return "E / A · Weiter zu Kapitel 2"
	if phase == Phase.RESCUE and gate_open and player.position.distance_to(raven.position) < 47.0:
		return "E / A · Nach Raven sehen"
	return ""

func interact(_actor: PixelActor = null) -> void:
	if phase == Phase.COMPLETE and not is_busy():
		ChapterFlow.advance(get_tree(), "res://scenes/chapter_two.tscn")
		return
	if is_busy() or interaction_prompt().is_empty():
		return
	if phase == Phase.HUNT:
		open_terminal("jackal", func():
			if _hunt_terminal_ready():
				set_gate(true)
				toast("Raven: Schleuse offen. Jackal ist gleich dahinter.")
		)
		return
	phase = Phase.REVIVE
	_scene_revive()

## Kapitel 1: Shadepi erreicht Raven; Jackal tritt aus dem Hof.
func _scene_revive() -> void:
	var cs = begin_cutscene()
	cs.pose(raven, "hurt")
	await cs.camera(raven.position + Vector2(0, -50), 0.6, 1.25)
	await cs.walk(player, raven.position + Vector2(-26, 8), 70)
	cs.face(player, raven.position)
	cs.pose(player, "idle")
	await cs.lines([
		["SHADEPI", "Kannst du mich hören? Bleib liegen. Der Rückstoß hat deine Beinimplantate verriegelt."],
		["RAVEN", "Er ist noch auf meiner Leitung. Solange seine Panzerung volle Leistung hat, komme ich nicht aus der Schleife."],
	])
	cs.do(func():
		enemy.position = WorldData.JACKAL
		enemy.show()
	)
	await cs.camera(WorldData.JACKAL + Vector2(-40, -50), 0.9, 1.1)
	cs.pose(enemy, "idle")
	cs.face(enemy, player.position)
	await cs.say("CHROME JACKAL", "Noch so ein Held. Wie viele Teile von dir passen in meinen Kofferraum?")
	cs.face(player, enemy.position)
	await cs.say("SHADEPI", "Dann kümmere ich mich um seine Panzerung. Wenn dein Deck wieder hochfährt, brauche ich deine Hilfe.")
	cs.end(func():
		_enter_checkpoint(Phase.TEAM)
		autosave()
	)

func _raven_rejoins() -> void:
	raven_joined = true
	reset_raven(DOWNED_SPOT)
	raven.reset_visual_pose()
	enemy.min_health = 0
	enemy.hack()
	effects.hack_arc(raven.position, enemy.position)
	effects.burst(enemy.position, Color("59e7f6"), 24)
	sound("hack")
	set_coop(chapter_coop)
	toast("Raven: Ich bin wieder drin! Seine Panzerung ist offen.")

func admin_defeat_enemies() -> int:
	if phase == Phase.DUEL:
		toast("Das erste Jackal-Duell ist ein Story-Timer. Bitte Kapitelabschnitt weiterspielen.")
		return 0
	if phase == Phase.TEAM and not raven_joined:
		_raven_rejoins()
	return super.admin_defeat_enemies()

func enemy_defeated(foe: PixelActor = null) -> void:
	if encounter != null and not encounter.finished:
		return
	if phase == Phase.HUNT:
		_check_hunt_gate()
	elif phase == Phase.RESCUE and _guards_left() == 0:
		set_gate(true)
		toast("Wartungsgasse frei. Raven liegt hinter der Schleuse.")
	elif phase == Phase.TEAM and foe == enemy:
		_begin_epilogue()

func _begin_epilogue() -> void:
	phase = Phase.EPILOGUE
	set_music_section("chapter_1_finale")
	stage = 3
	set_coop(false)
	_scene_epilogue()

## Kapitel 1: Die erste Begegnung – nach „Shadepi – Im Schatten des Raben“.
func _scene_epilogue() -> void:
	var cs = begin_cutscene()
	var body: Vector2 = enemy.position
	cs.pose(player, "idle")
	cs.pose(raven, "idle")
	await cs.camera(player.position.lerp(raven.position, 0.5) + Vector2(0, -50), 0.8, 1.2)
	cs.face(raven, player.position)
	cs.face(player, raven.position)
	await cs.lines([
		["RAVEN", "Hey, sein Kopfgeld gehört aber mir!"],
		["RAVEN", "… Trotzdem danke. Du bist ein Cyber-Ninja?"],
		["SHADEPI", "Hmm, also doch eine Netrunnerin. Geld interessiert mich nicht. Ich brauche Informationen. Wie gut bist du?"],
		["RAVEN", "Wie kommst du darauf, dass ich dir helfe? Du hast meine Frage noch nicht beantwortet."],
		["SHADEPI", "Ja, ich bin ein Cyber-Ninja. Man nennt mich Shadepi. Und wie darf ich dich nennen?"],
		["RAVEN", "Man sieht wenige von euch. Mein Name ist Raven. Vielleicht bin ich beim Running auf nützliche Informationen gestoßen. Aber das kostet …"],
	])
	await cs.walk(player, body + Vector2(-22, 10), 70)
	cs.face(player, body)
	cs.pose(player, "attack")
	cs.do(func(): effects.burst(body + Vector2(0, -6), Color("b98cff"), 10))
	await cs.wait(0.5)
	cs.pose(player, "idle")
	cs.face(player, raven.position)
	await cs.say("SHADEPI", "1-2-3-4. Das war einfach. Bezahlt dich das?")
	cs.do(func(): effects.hack_arc(player.position + Vector2(0, -20), raven.position + Vector2(0, -20)))
	await cs.lines([
		["RAVEN", "Was soll ich damit? Das Konto ist voll von seinem Blutgeld."],
		["RAVEN", "Aber da du mir geholfen hast, helfe ich dir. Ich bin mal nicht so. Triff mich dort – dann sehe ich nach den Infos, die du brauchst."],
	])
	cs.do(func(): effects.burst(player.position + Vector2(0, -24), Color("8be0e4"), 8))
	cs.release(raven)
	await cs.walk(raven, Vector2(EXIT_DOOR.x, 327), 80)
	await cs.walk(raven, EXIT_DOOR + Vector2(0, 4), 60)
	cs.do(func(): raven.hide())
	await cs.wait(0.4)
	await cs.say("SHADEPI / LEISE", "Ein Hauch von Rosen … Geld ist doch Geld. … Danke, Raven.")
	var roof := Vector2(clampf(player.position.x + 40.0, 550.0, 1000.0), 223.0)
	cs.face(player, roof)
	await cs.leap(player, roof, 78.0, 0.7)
	cs.do(func():
		phase = Phase.COMPLETE
		checkpoint = Phase.COMPLETE
		stage = 4
		autosave()
	)
	await cs.title("KAPITEL 1 · ENDE", "Auf der Datenkarte blinkt eine Adresse.", 2.6)
	cs.end()

func player_defeated() -> void:
	var saved_section: int = encounter.section_index if encounter != null else 0
	_enter_checkpoint(checkpoint, saved_section)
	menu_open = true
	ui.show_menu("SYSTEM GESTÖRT")
	ui.resume_button.text = "Am Kontrollpunkt fortsetzen"

func saved_checkpoint(local_coop: bool) -> int:
	var config := ConfigFile.new()
	if config.load(Admin.checkpoint_path(CHAPTER_SAVE, get_tree())) != OK:
		return -1
	var saved: Variant = config.get_value("chapter_one", "coop" if local_coop else "solo", -1)
	if saved is int and saved in [Phase.APARTMENT, Phase.HUNT, Phase.RESCUE, Phase.TEAM, Phase.COMPLETE]:
		return saved
	return -1

func autosave() -> void:
	if not _write_checkpoint():
		toast("Kontrollpunkt konnte nicht gespeichert werden.")

func save_game() -> bool:
	var success := _write_checkpoint()
	toast("Kontrollpunkt gespeichert" if success else "Speichern fehlgeschlagen")
	return success

func _write_checkpoint() -> bool:
	var config := ConfigFile.new()
	config.load(Admin.checkpoint_path(CHAPTER_SAVE, get_tree()))
	config.set_value("resume","coop_time" if chapter_coop else "solo_time",Time.get_unix_time_from_system())
	config.set_value("chapter_one", "coop" if chapter_coop else "solo", checkpoint)
	config.set_value("arcade", "coop" if chapter_coop else "solo", encounter.section_index if encounter != null else 0)
	config.set_value("props", "coop" if chapter_coop else "solo", dressing_state())
	return config.save(Admin.checkpoint_path(CHAPTER_SAVE, get_tree())) == OK

func load_game(requested_mode: Variant = null) -> bool:
	var mode := chapter_coop if requested_mode == null else bool(requested_mode)
	var saved := saved_checkpoint(mode)
	if saved < 0:
		toast("Kein Kontrollpunkt für diesen Modus")
		return false
	chapter_coop = mode
	var config := ConfigFile.new()
	config.load(Admin.checkpoint_path(CHAPTER_SAVE, get_tree()))
	restore_dressing_state(config.get_value("props", "coop" if mode else "solo", {}))
	var saved_section: Variant = config.get_value("arcade", "coop" if mode else "solo", 0)
	_enter_checkpoint(saved as Phase, saved_section if saved_section is int else 0)
	toast("Kontrollpunkt geladen")
	return true

func _draw() -> void:
	if phase == Phase.APARTMENT:
		draw_rect(Rect2(WEST_EDGE - 200, -100, 1100, 840), Color("07090f"))
		draw_texture_rect(Painted.ART.apartment, APARTMENT_RECT, false)
		return
	if phase == Phase.EPILOGUE and raven.visible and raven.position.distance_to(EXIT_DOOR) < 53.0:
		draw_rect(Rect2(947, 186, 39, 79), Color("090e19"))
	if not gate_open:
		for y in range(259, 496, 8):
			draw_rect(Rect2(507, y, 4, 5), Color(0.28, 0.8, 0.95, 0.75))
	var point := Vector2.ZERO
	if phase == Phase.HUNT:
		point = TRAIL[trail_index] if trail_index < TRAIL.size() else (ARENA_ENTRY if gate_open else (TRAIL.back() if _hunt_terminal_ready() else Vector2.ZERO))
	elif phase == Phase.RESCUE and gate_open:
		point = DOWNED_SPOT
	if point != Vector2.ZERO and not in_cinematic():
		draw_arc(point, 13.0, 0.0, TAU, 24, Color(0.35, 0.88, 0.95, 0.7), 1.0)
		var tip := point + Vector2(0, -62.0 + sin(Time.get_ticks_msec() * 0.006) * 4.0)
		draw_polyline(PackedVector2Array([tip + Vector2(-6, -6), tip, tip + Vector2(6, -6)]), Color("a5eff6"), 2.0)
