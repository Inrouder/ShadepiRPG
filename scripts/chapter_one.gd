extends "res://scripts/main.gd"

enum Phase { APARTMENT, HUNT, DUEL, ROOFTOP, RESCUE, REVIVE, TEAM, COMPLETE }

const ChapterHud = preload("res://scripts/chapter_hud.gd")
const CHAPTER_SAVE := "user://shadepi-chapter-one.cfg"
const APARTMENT_EXIT := Vector2(128, 370)
const ARENA_ENTRY := Vector2(568, 356)
const DOWNED_SPOT := Vector2(636, 365)
const RESCUE_START := Vector2(295, 451)
const BARRIERS: Array[Rect2] = [Rect2(181, 272, 29, 128), Rect2(381, 375, 28, 121)]
const TRAIL: Array[Vector2] = [Vector2(219, 451), Vector2(391, 343), Vector2(475, 365)]

var phase := Phase.APARTMENT
var checkpoint := Phase.APARTMENT
var chapter_coop := false
var trail_index := 0
var duel_time := 0.0
var assist_time := 0.0
var patrol: Array[PixelActor] = []

func create_hud() -> CanvasLayer:
	return ChapterHud.new()

func _build_world() -> void:
	super._build_world()
	for barrier in BARRIERS:
		_collider(barrier)
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
	return actor == raven if raven_leads() else super.actor_is_playable(actor)

func actor_input_prefix(actor: PixelActor) -> String:
	return "" if raven_leads() else super.actor_input_prefix(actor)

func hack_origin() -> Vector2:
	return raven.position

func hack_input_hint() -> String:
	if phase == Phase.DUEL and gamepads.shadepi_device >= 0:
		return "Q / Y / RB"
	return super.hack_input_hint()

func combat_target(origin: Vector2, include_cloaked: bool = false) -> PixelActor:
	if phase == Phase.DUEL:
		return raven
	if phase == Phase.TEAM:
		if not coop and (player.cloak_time > 0.0 or origin.distance_squared_to(raven.position) < origin.distance_squared_to(player.position)):
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
	if raven_leads():
		camera.position = raven.position + Vector2(0, -57) + raven.facing * 8
	if is_busy():
		return
	match phase:
		Phase.HUNT:
			if trail_index < TRAIL.size() and raven.position.distance_to(TRAIL[trail_index]) < 37.0:
				trail_index += 1
				if trail_index == TRAIL.size():
					set_gate(true)
					toast("Raven: Jackal ist hinter der Schleuse.")
			elif trail_index == TRAIL.size() and raven.position.x > ARENA_ENTRY.x:
				_begin_duel()
		Phase.DUEL:
			duel_time += delta
			if duel_time >= 10.0:
				_lose_duel()
			elif duel_time >= 8.0:
				enemy.windup = maxf(enemy.windup, 0.43)
		Phase.TEAM:
			if not coop:
				assist_time = maxf(0.0, assist_time - delta)
				if assist_time == 0.0 and raven.position.distance_to(enemy.position) <= 140.0 and _line_clear(raven.position, enemy.position):
					assist_time = 1.7
					raven.facing = (enemy.position - raven.position).normalized()
					raven.animate("attack", delta)
					raven_shot()
	if raven_leads() and raven.velocity.length() > 45.0 and next_step_ripple <= 0.0:
		effects.water_step(raven.position)
		next_step_ripple = 0.13

func _update_raven_follower(delta: float) -> void:
	if phase == Phase.TEAM:
		super._update_raven_follower(delta)

func new_game(save_checkpoint: bool = true) -> void:
	_enter_checkpoint(Phase.APARTMENT)
	if save_checkpoint:
		autosave()

func _enter_checkpoint(next_phase: Phase) -> void:
	ui.clear_dialogue()
	for foe in patrol:
		foe.hide()
		foe.set_physics_process(false)
		foe.queue_free()
	patrol.clear()
	checkpoint = next_phase
	phase = next_phase
	stage = 4 if phase == Phase.COMPLETE else (2 if phase == Phase.TEAM else 1)
	set_coop(chapter_coop and phase in [Phase.TEAM, Phase.COMPLETE])
	set_gate(phase in [Phase.TEAM, Phase.COMPLETE])
	hack_cooldown = 0.0
	assist_time = 0.0
	trail_index = 0
	player.position = RESCUE_START if phase == Phase.RESCUE else DOWNED_SPOT + Vector2(-35, 8)
	player.health = 100
	player.energy = 100.0
	player.reset_transients()
	player.facing = Vector2.RIGHT
	player.visible = not raven_leads()
	reset_raven(APARTMENT_EXIT if raven_leads() else DOWNED_SPOT)
	raven.facing = Vector2.RIGHT
	raven.visual.rotation = 0.0
	raven.visual.position.y = -26.0
	enemy.position = WorldData.JACKAL
	enemy.min_health = 0
	enemy.reset_fight(0 if phase == Phase.COMPLETE else enemy.max_health)
	enemy.active = phase == Phase.TEAM
	enemy.visible = enemy.active
	close_menu()
	match phase:
		Phase.APARTMENT:
			ui.dialogue([
				["NIGHT CITY / MORGENGRAUEN", "In Night City brennt das Neon bis in den Morgen. Raven bekommt einen neuen Auftrag.", "stadt"],
				["RAVEN / APARTMENT", "Chrome Jackal. Bingo Street. Die Spur führt zum Wartungshof hinter der Schleuse. Ich bin unterwegs.", "apartment"],
			], _leave_apartment)
		Phase.RESCUE:
			raven.health = 0
			raven.visual.rotation = PI * 0.5
			raven.visual.position.y = -9
			_spawn_patrol(Vector2(347, 357), Color("9bd5ff"))
			_spawn_patrol(Vector2(466, 384), Color("edbad5"))

func _leave_apartment() -> void:
	phase = Phase.HUNT
	checkpoint = Phase.HUNT
	autosave()

func _begin_duel() -> void:
	phase = Phase.DUEL
	stage = 2
	duel_time = 0.0
	enemy.show()
	enemy.min_health = 50
	enemy.active = true
	ui.dialogue([
		["CHROME JACKAL / WARTUNGSHOF", "Du hast die ganze Stadt nach mir abgesucht. Ich musste nur hier warten.", "jackal"],
	])

func _lose_duel() -> void:
	raven.health = 0
	raven.reset_transients()
	raven.position = DOWNED_SPOT
	raven.visual.rotation = PI * 0.5
	raven.visual.position.y = -9
	phase = Phase.ROOFTOP
	stage = 1
	enemy.active = false
	enemy.windup = 0.0
	enemy.lunge = 0.0
	enemy.hide()
	shake = 7.0
	effects.burst(DOWNED_SPOT, Color("ff596e"), 32)
	sound("hit")
	ui.dialogue([
		["RAVEN / SIGNALVERLUST", "Er ist durch meinen Hack gekommen. Meine Beine reagieren nicht.", "niederlage"],
		["SHADEPI / ÜBER DEN DÄCHERN", "Zwei Wärmesignaturen. Eine wird schwächer. Ich nehme die Wartungsgasse.", "dach"],
	], func():
		_enter_checkpoint(Phase.RESCUE)
		autosave()
	)

func _spawn_patrol(point: Vector2, tint: Color) -> void:
	var foe := EnemyScript.new()
	foe.max_health = 36
	foe.hit_damage = 13
	foe.move_speed = 53.0
	foe.setup(preload("res://assets/sprites/jackal.png"), self)
	foe.position = point
	foe.scale = Vector2(0.72, 0.72)
	foe.visual.self_modulate = tint
	actors.add_child(foe)
	foe.reset_fight(foe.max_health)
	foe.active = true
	patrol.append(foe)

func player_strike(amount: int) -> void:
	if phase == Phase.RESCUE:
		for foe in patrol:
			if CombatRules.can_strike(player.position, player.facing, foe.position) and _line_clear(player.position, foe.position):
				foe.take_damage(amount)
	elif phase == Phase.TEAM:
		super.player_strike(amount)

func interaction_prompt() -> String:
	if phase == Phase.RESCUE and gate_open and player.position.distance_to(raven.position) < 47.0:
		return "E / A · Raven aufhelfen"
	return ""

func interact(_actor: PixelActor = null) -> void:
	if is_busy() or interaction_prompt().is_empty():
		return
	phase = Phase.REVIVE
	ui.dialogue([
		["SHADEPI", "Hier. Nimm meine Hand. Kannst du stehen?", "rettung"],
		["RAVEN", "Wenn du ihn beschäftigst, lege ich seine Implantate lahm.", "rettung"],
	], func():
		_enter_checkpoint(Phase.TEAM)
		autosave()
	)

func enemy_defeated(foe: PixelActor = null) -> void:
	if phase == Phase.RESCUE:
		for guard in patrol:
			if guard.health > 0:
				return
		set_gate(true)
		toast("Wartungsgasse frei. Raven liegt hinter der Schleuse.")
	elif phase == Phase.TEAM and foe == enemy:
		phase = Phase.COMPLETE
		checkpoint = Phase.COMPLETE
		stage = 4
		autosave()
		ui.dialogue([
			["RAVEN", "Das Kopfgeld gehört mir. Und … danke. Wer bist du?", "begegnung"],
			["SHADEPI", "Shadepi. Das Geld kannst du behalten. Ich brauche Informationen.", "begegnung"],
		])

func player_defeated() -> void:
	if phase == Phase.DUEL:
		_lose_duel()
	else:
		_enter_checkpoint(checkpoint)
		menu_open = true
		ui.show_menu("SYSTEM GESTÖRT")
		ui.resume_button.text = "Am Kontrollpunkt fortsetzen"

func saved_checkpoint(local_coop: bool) -> int:
	var config := ConfigFile.new()
	if config.load(CHAPTER_SAVE) != OK:
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
	return config.save(CHAPTER_SAVE) == OK

func load_game(requested_mode: Variant = null) -> bool:
	var mode := chapter_coop if requested_mode == null else bool(requested_mode)
	var saved := saved_checkpoint(mode)
	if saved < 0:
		toast("Kein Kontrollpunkt für diesen Modus")
		return false
	chapter_coop = mode
	_enter_checkpoint(saved as Phase)
	toast("Kontrollpunkt geladen")
	return true

func _draw() -> void:
	for barrier in BARRIERS:
		draw_rect(barrier.grow(2), Color("111827"))
		draw_rect(barrier, Color("283044"))
		draw_rect(Rect2(barrier.position, Vector2(barrier.size.x, 8)), Color("3b4258"))
		for y in range(int(barrier.position.y) + 14, int(barrier.end.y), 8):
			draw_line(Vector2(barrier.position.x + 3, y), Vector2(barrier.end.x - 3, y), Color("1a2436"))
		draw_rect(Rect2(barrier.end.x - 5, barrier.position.y + 8, 3, 34), Color("de4b8d") if barrier.position.x < 200 else Color("5bcad7"))
	if not gate_open:
		for y in range(259, 496, 8):
			draw_rect(Rect2(507, y, 4, 5), Color(0.28, 0.8, 0.95, 0.75))
	var point := Vector2.ZERO
	if phase == Phase.HUNT:
		point = TRAIL[trail_index] if trail_index < TRAIL.size() else ARENA_ENTRY
	elif phase == Phase.RESCUE and gate_open:
		point = DOWNED_SPOT
	if point != Vector2.ZERO:
		draw_arc(point, 13.0, 0.0, TAU, 24, Color(0.35, 0.88, 0.95, 0.7), 1.0)
		var tip := point + Vector2(0, -62.0 + sin(Time.get_ticks_msec() * 0.006) * 4.0)
		draw_polyline(PackedVector2Array([tip + Vector2(-6, -6), tip, tip + Vector2(6, -6)]), Color("a5eff6"), 2.0)
