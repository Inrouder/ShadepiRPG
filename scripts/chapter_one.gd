extends "res://scripts/main.gd"

enum Phase { APARTMENT, HUNT, DUEL, ROOFTOP, RESCUE, REVIVE, TEAM, COMPLETE, EPILOGUE }

const ChapterHud = preload("res://scripts/chapter_hud.gd")
const CHAPTER_SAVE := "user://shadepi-chapter-one.cfg"
const WEST_EDGE := -640
const DUEL_DURATION := 30.0
const JACKAL_HEALTH := 360
const APARTMENT_EXIT := Vector2(-554, 356)
const EXIT_DOOR := Vector2(961, 255)
const PUNKS := [
	preload("res://assets/sprites/npcs/punk-1.png"), preload("res://assets/sprites/npcs/punk-2.png"),
	preload("res://assets/sprites/npcs/punk-3.png"), preload("res://assets/sprites/npcs/punk-4.png"),
]
const HUNT_GUARDS := [Vector2(-491, 401), Vector2(-329, 432), Vector2(-156, 356), Vector2(81, 404)]
const RESCUE_GUARDS := [Vector2(347, 351), Vector2(466, 382), Vector2(483, 442)]
const ARENA_ENTRY := Vector2(568, 356)
const DOWNED_SPOT := Vector2(636, 365)
const RESCUE_START := Vector2(295, 451)
const BARRIERS: Array[Rect2] = [
	Rect2(-441, 272, 36, 107), Rect2(-270, 376, 41, 104), Rect2(-113, 272, 38, 107),
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
var ending: Tween
var patrol: Array[PixelActor] = []
var street_lights: Array[PointLight2D] = []
var apartment_lights: Array[PointLight2D] = []

func _ready() -> void:
	super._ready()
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
	west.texture = Painted.ART.market
	west.material = material
	west.scale = Vector2(640, 640) / west.texture.get_size()
	west.centered = false
	west.position.x = WEST_EDGE
	west.z_index = -10
	add_child(west)
	for point in [Vector2(-537, 283), Vector2(-315, 390), Vector2(-170, 318), Vector2(-61, 438)]:
		_halo(point, Color(0.9, 0.24, 0.43, 0.44), 0.8)
		street_lights.append(_light(point, Color("f66892"), 1.55, 1.0))
	apartment_lights = [
		_light(Vector2(-530, 265), Color("6abac9"), 1.95, 0.63),
		_light(Vector2(-401, 271), Color("91cbdc"), 1.5, 0.42),
	]
	for light in apartment_lights:
		light.enabled = false
	for barrier in BARRIERS:
		_collider(barrier)
	add_painted_masks("market", Vector2(WEST_EDGE, 0), Vector2(640, 640))
	add_painted_masks("alley")
	_halo(Vector2(197, 383), Color(0.94, 0.2, 0.55, 0.42), 0.67)
	_halo(Vector2(395, 386), Color(0.17, 0.87, 0.95, 0.42), 0.72)
	_light(Vector2(219, 404), Color("ed539f"), 1.0, 0.8)
	_light(Vector2(399, 359), Color("67d9e8"), 1.0, 0.9)
	player.hide()
	raven.position = APARTMENT_EXIT
	enemy.hide()

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
	if raven_leads() or phase == Phase.ROOFTOP:
		camera.position = raven.position + Vector2(0, -57) + raven.facing * 8
	if ending != null and ending.is_valid():
		if phase == Phase.EPILOGUE and not ui.dialogue_open and not menu_open:
			if raven.visible:
				raven.animate("walk", delta)
			else:
				player.animate("walk", delta)
		if menu_open:
			ending.pause()
		elif not ending.is_running():
			ending.play()
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

func _enter_checkpoint(next_phase: Phase) -> void:
	ui.clear_dialogue()
	if ending != null:
		ending.kill()
		ending = null
	for foe in patrol:
		foe.hide()
		foe.set_physics_process(false)
		foe.queue_free()
	patrol.clear()
	checkpoint = next_phase
	phase = next_phase
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
			ui.dialogue([
				["NIGHT CITY / MORGENGRAUEN", "Der Regen drückt den Rauch der Nacht zurück auf die Straße. In Ravens Apartment klingelt das Kopfgeldterminal.", "stadt"],
				["RAVEN / APARTMENT", "Chrome Jackal. Die Prämie ist gerade wieder gestiegen. Entweder will ihn jemand dringend tot sehen oder die anderen Jäger haben aufgegeben.", "apartment"],
				["KOPFGELDTERMINAL", "Letzter Ping an Bingo Street. Ein Wartungshof hinter der Schleuse. Die Kameras dort senden seit zwölf Minuten dasselbe Bild.", "apartment"],
				["RAVEN", "Dann nehme ich die Gassen unter den Kameras. Mal sehen, wer da für ihn die Augen offen hält.", "apartment"],
			], _leave_apartment)
		Phase.HUNT:
			_spawn_hunt()
		Phase.RESCUE, Phase.TEAM:
			_down_raven()
			if phase == Phase.RESCUE:
				for index in RESCUE_GUARDS.size():
					_spawn_patrol(RESCUE_GUARDS[index], (index + 2) % PUNKS.size())

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

func _leave_apartment() -> void:
	phase = Phase.HUNT
	set_dressing("street")
	_update_apartment_lighting()
	checkpoint = Phase.HUNT
	_spawn_hunt()
	autosave()

func _spawn_hunt() -> void:
	for index in HUNT_GUARDS.size():
		_spawn_patrol(HUNT_GUARDS[index], index)

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
	if not gate_open and trail_index == TRAIL.size() and _guards_left() == 0:
		set_gate(true)
		toast("Raven: Die Schleuse ist offen. Jackal ist gleich dahinter.")

func _begin_duel() -> void:
	phase = Phase.DUEL
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
	ui.dialogue([
		["CHROME JACKAL / WARTUNGSHOF", "Vier meiner Leute senden nicht mehr. Dein Signal dagegen ist laut genug, um den ganzen Hof zu wecken.", "jackal"],
		["RAVEN", "Ich bin wegen deines Kopfgelds hier. Mal sehen, wie lange deine Panzerung durchhält, wenn ich die Steuerung finde.", "jackal"],
		["CHROME JACKAL", "Dann steck dich ruhig ein. Die letzte Netrunnerin hat denselben Fehler gemacht.", "jackal"],
	])

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
	stage = 1
	enemy.active = false
	enemy.windup = 0.0
	enemy.lunge = 0.0
	enemy.velocity = Vector2.ZERO
	camera.position = raven.position + Vector2(0, -65)
	feedback_time = 0.85
	shake = 8.0
	sound("hack")

func _rooftop_dialogue() -> void:
	ui.dialogue([
		["RAVEN / SYSTEMFEHLER", "Ich hatte seine Schnittstelle. Dann hat er die Verbindung umgedreht … ich spüre meine Beine nicht mehr.", "niederlage"],
		["CHROME JACKAL", "Dein Deck hat mir die Tür aufgemacht. Jetzt brauche ich nur noch das Kopfgeld auf dich einzusammeln.", "niederlage"],
		["SHADEPI / ÜBER DEN DÄCHERN", "Zwei Wärmesignaturen im Hof. Eine am Boden. Die anderen auf der Straße schneiden ihr den Rückweg ab.", "dach"],
		["SHADEPI", "Wenn ich über die Hauptgasse gehe, sehen sie mich kommen. Die Wartungsgasse liegt im Schatten.", "dach"],
	], func():
		_enter_checkpoint(Phase.RESCUE)
		autosave()
	)

func _spawn_patrol(point: Vector2, variant: int) -> void:
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
				foe.take_damage(amount)
	elif phase == Phase.TEAM:
		super.player_strike(amount)

func interaction_prompt() -> String:
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
	phase = Phase.REVIVE
	ui.dialogue([
		["SHADEPI", "Kannst du mich hören? Bleib liegen. Der Rückstoß hat deine Beinimplantate verriegelt.", "rettung"],
		["RAVEN", "Er ist noch auf meiner Leitung. Solange seine Panzerung volle Leistung hat, komme ich nicht aus der Schleife.", "rettung"],
		["SHADEPI", "Dann kümmere ich mich um die Panzerung. Wenn dein Deck wieder hochfährt, brauche ich deine Hilfe.", "rettung"],
	], func():
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
	if phase == Phase.HUNT:
		_check_hunt_gate()
	elif phase == Phase.RESCUE and _guards_left() == 0:
		set_gate(true)
		toast("Wartungsgasse frei. Raven liegt hinter der Schleuse.")
	elif phase == Phase.TEAM and foe == enemy:
		_begin_epilogue()

func _begin_epilogue() -> void:
	phase = Phase.EPILOGUE
	stage = 3
	set_coop(false)
	ui.dialogue([
		["RAVEN", "Das Kopfgeld gehört mir. Und bevor du fragst: Ja, ich kann wieder stehen. Was bist du überhaupt? Ein Cyber-Ninja?", "begegnung"],
		["SHADEPI", "Shadepi. Du bist also die Netrunnerin, die ich suche. Ich brauche deine Dienste, um an Informationen zu kommen.", "begegnung"],
		["RAVEN", "Raven. Und meine Dienste kosten. Nur weil wir denselben Mann zu Boden geschickt haben, gebe ich dir noch keinen Zugriff auf mein Netz.", "begegnung"],
		["SHADEPI", "Hier. Jackals Telefon. Der Code war 1-2-3-4. Reicht das als Anzahlung?", "begegnung"],
		["RAVEN", "Das ist Blutgeld. Behalt es. Aber du hast mir da draußen den Rücken freigehalten. Nimm die Karte. Die Adresse steht drauf. Dort reden wir weiter.", "begegnung"],
	], _raven_exits)

func _raven_exits() -> void:
	raven.facing = (Vector2(EXIT_DOOR.x, 327) - raven.position).normalized()
	ending = create_tween()
	ending.tween_property(raven, "position", Vector2(EXIT_DOOR.x, 327), 1.45)
	ending.tween_callback(func(): raven.facing = Vector2.UP)
	ending.tween_property(raven, "position", EXIT_DOOR + Vector2(0, 4), 0.8)
	ending.tween_callback(func():
		raven.hide()
		ui.dialogue([["SHADEPI / LEISE", "Geld ist doch Geld. … Danke, Raven.", ""]], _jump_to_roof)
	)

func _jump_to_roof() -> void:
	player.facing = Vector2.UP
	ending = create_tween()
	var roof := Vector2(clampf(player.position.x + 40.0, 550.0, 1000.0), 223.0)
	ending.tween_property(player, "position", roof, 0.7).set_trans(Tween.TRANS_SINE)
	ending.parallel().tween_property(player.visual, "position:y", -78.0, 0.33)
	ending.tween_property(player.visual, "position:y", player.standing_visual_position.y, 0.24)
	ending.tween_callback(func():
		phase = Phase.COMPLETE
		checkpoint = Phase.COMPLETE
		stage = 4
		player.animate("idle", 0.0)
		autosave()
		ui.dialogue([["KAPITEL 1 / ENDE", "Die Stadt verschluckt seine Silhouette. Auf der Datenkarte blinkt eine Adresse.", "dach"]])
	)

func player_defeated() -> void:
	_enter_checkpoint(checkpoint)
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
	config.load(CHAPTER_SAVE)
	config.set_value("chapter_one", "coop" if chapter_coop else "solo", checkpoint)
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
	config.load(CHAPTER_SAVE)
	restore_dressing_state(config.get_value("props", "coop" if mode else "solo", {}))
	_enter_checkpoint(saved as Phase)
	toast("Kontrollpunkt geladen")
	return true

func _draw() -> void:
	if phase == Phase.APARTMENT:
		draw_texture_rect(Painted.ART.apartment, Rect2(WEST_EDGE, 0, 640, 640), false)
		return
	if phase == Phase.EPILOGUE and raven.visible and raven.position.distance_to(EXIT_DOOR) < 53.0:
		draw_rect(Rect2(947, 186, 39, 79), Color("090e19"))
	if not gate_open:
		for y in range(259, 496, 8):
			draw_rect(Rect2(507, y, 4, 5), Color(0.28, 0.8, 0.95, 0.75))
	var point := Vector2.ZERO
	if phase == Phase.HUNT:
		point = TRAIL[trail_index] if trail_index < TRAIL.size() else (ARENA_ENTRY if gate_open else Vector2.ZERO)
	elif phase == Phase.RESCUE and gate_open:
		point = DOWNED_SPOT
	if point != Vector2.ZERO:
		draw_arc(point, 13.0, 0.0, TAU, 24, Color(0.35, 0.88, 0.95, 0.7), 1.0)
		var tip := point + Vector2(0, -62.0 + sin(Time.get_ticks_msec() * 0.006) * 4.0)
		draw_polyline(PackedVector2Array([tip + Vector2(-6, -6), tip, tip + Vector2(6, -6)]), Color("a5eff6"), 2.0)
