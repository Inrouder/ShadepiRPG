extends Node2D

const VEHICLES = preload("res://assets/world/hq/vehicles.png")
const Painted = preload("res://scripts/painted_world.gd")

signal completed
signal crashed
const BIKE_Y: = 224.0
const FLIGHT_Y := 270.0
const REAR_Y: = 306.0
const LANES: = [230.0, 320.0, 410.0]

var world: Node2D
var flight: = false
var transponder_sent: = false
var elapsed: = 0.0
var lane: = 1
var x: = 320.0
var boss_lane: = 1
var armour: = 100
var health: = 100
var hack: = 0.0
var hack_cooldown: = 0.0
var grenade_cooldown: = 0.0
var shot_cooldown: = 0.0
var hurt: = 0.0
var next_hazard: = 1.0
var pattern: = 0
var grenade: = Vector2.ZERO
var bullets: Array[Vector2] = []
var hazards: Array[Vector2] = []
var active: = true
var rear_shots: Array[Vector2] = []
var ram_warning: = 0.0
var ram_recovery: = 0.0

# Flight progress freezes during the emergency; the repair has its own deadline.
const REPAIR_SECONDS := 45.0
var engine_failed := false
var engine_repaired := false
var repair_left := REPAIR_SECONDS
var restart_flash := 0.0
var velocity_x := 0.0
var boss_x := 320.0
var boss_velocity := 0.0
var shake := 0.0
var fx_clock := 0.0
var emission_clock := 0.0
var victory_left := -1.0
var debris: Array[Dictionary] = []
var explosions: Array[Dictionary] = []
var clouds: Array[Dictionary] = []
var flashes: Array[Dictionary] = []
var rng := RandomNumberGenerator.new()

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	rng.seed = 2534

func _sound(key: String) -> void:
	# Share the world's bounded mixer and its mute/headless rules.
	world.sound("drive_" + key)

func start_engine_failure() -> void:
	if engine_failed or engine_repaired:
		return
	engine_failed = true
	repair_left = REPAIR_SECONDS
	shake = 4.0
	velocity_x += 95.0
	_sound("engine_fail")
	world.toast("ARTOS: Triebwerk ausgefallen! Raven öffnet das Wartungsdeck. J / X öffnet es erneut.")
	request_repair()

func request_repair() -> void:
	if not active or not engine_failed or repair_left <= 0.0:
		return
	world.open_terminal("repair", func():
		if not active or not engine_failed:
			return
		engine_failed = false
		engine_repaired = true
		restart_flash = 1.2
		_sound("engine_restart")
		impact(Vector2(x + 19, FLIGHT_Y + 29), false, Color("75edff"))
		world.toast("RAVEN: Brücken geprüft. – ARTOS: Schub wiederhergestellt.")
	)

func _steer(delta: float) -> void:
	# Fixed-sized integration makes steering stable even during frame stalls.
	var remaining := delta
	while remaining > 0.00001:
		var step := minf(remaining, 1.0 / 120.0)
		var drift := 900.0 if engine_failed else 0.0
		velocity_x += ((LANES[lane] - x) * 65.0 - velocity_x * 15.0 + drift) * step
		x = clampf(x + velocity_x * step, 190.0, 450.0)
		boss_velocity += ((LANES[boss_lane] - boss_x) * 32.0 - boss_velocity * 11.0) * step
		boss_x = clampf(boss_x + boss_velocity * step, 190.0, 450.0)
		remaining -= step

func impact(point: Vector2, explosive: bool = false, color: Color = Color("ffba68")) -> void:
	var limit := 50 if world.visual_quality == 0 else 150
	for i in mini(28 if explosive else 7, maxi(0, limit - debris.size())):
		var v := Vector2.from_angle(rng.randf() * TAU) * rng.randf_range(35, 150)
		debris.append({"p": point, "v": v, "t": rng.randf_range(0.3, 0.9), "a": rng.randf() * TAU, "spin": rng.randf_range(-9, 9), "c": color})
	if explosive:
		if explosions.size() < 8:
			explosions.append({"p": point, "t": 0.65})
		for i in 7:
			_smoke(point + Vector2(rng.randf_range(-12, 12), rng.randf_range(-8, 8)))
		shake = maxf(shake, 4.0)
		_sound("explosion")

func _smoke(point: Vector2) -> void:
	if clouds.size() < (14 if world.visual_quality == 0 else 45):
		clouds.append({"p": point, "t": 1.4, "r": rng.randf_range(4, 10)})

func _update_fx(delta: float) -> void:
	fx_clock += delta
	shake = move_toward(shake, 0.0, delta * 9.0)
	restart_flash = maxf(0.0, restart_flash - delta)
	for i in range(debris.size() - 1, -1, -1):
		var bit: Dictionary = debris[i]
		bit.v.y += 115.0 * delta
		bit.v *= exp(-delta * 0.8)
		bit.p += bit.v * delta
		bit.a += bit.spin * delta
		bit.t -= delta
		if bit.t <= 0.0:
			debris.remove_at(i)
	for collection in [clouds, explosions, flashes]:
		for i in range(collection.size() - 1, -1, -1):
			collection[i].t -= delta
			if collection == clouds:
				collection[i].p += Vector2(-9, 38) * delta
			if collection[i].t <= 0.0:
				collection.remove_at(i)
	emission_clock -= delta
	if emission_clock <= 0.0:
		emission_clock = 0.09
		if engine_failed:
			_smoke(Vector2(x + 19, FLIGHT_Y + 26))
		elif not flight and armour < 45:
			_smoke(Vector2(boss_x, REAR_Y + 15))

func _draw_vehicle(index: int, center: Vector2, size: Vector2, tilt: float = 0.0) -> void:
	var region := Rect2((index % 2) * 627, (index / 2) * 627, 627, 627)
	draw_set_transform(center, tilt)
	draw_texture_rect_region(VEHICLES, Rect2(-size * 0.5, size), region)
	draw_set_transform(Vector2.ZERO)

func _draw_fx() -> void:
	for cloud in clouds:
		var age: float = 1.0 - cloud.t / 1.4
		draw_circle(cloud.p, cloud.r * (1.0 + age * 2.5), Color(0.18, 0.22, 0.28, (1.0 - age) * 0.6))
	for blast in explosions:
		var age: float = 1.0 - blast.t / 0.65
		draw_circle(blast.p, 7.0 + age * 32.0, Color(1.0, 0.25 + age * 0.3, 0.06, (1.0 - age) * 0.8))
		draw_circle(blast.p, 4.0 + age * 16.0, Color(1.0, 0.92, 0.65, 1.0 - age))
		draw_arc(blast.p, 4.0 + age * 65.0, 0, TAU, 40, Color(1.0, 0.7, 0.3, 1.0 - age), 2.0, true)
	for bit in debris:
		draw_set_transform(bit.p, bit.a)
		draw_rect(Rect2(-2, -1, 4, 2), Color(bit.c, minf(1.0, bit.t * 3.0)))
	draw_set_transform(Vector2.ZERO)
	for flash in flashes:
		draw_circle(flash.p, 4.0 + flash.t * 32, Color(1.0, 0.83, 0.52, flash.t * 9.0))


func _process(delta: float) -> void :
	if not active or world.is_busy():
		return
	_update_fx(delta)
	if victory_left >= 0.0:
		victory_left -= delta
		queue_redraw()
		if victory_left <= 0.0:
			active = false
			completed.emit()
		return
	if flight and not engine_failed:
		elapsed += delta
		if elapsed >= 3.2 and not engine_repaired:
			start_engine_failure()
			return
	elif not flight:
		elapsed += delta
	if engine_failed:
		repair_left = maxf(0.0, repair_left - delta)
		if Input.is_action_just_pressed("attack"):
			request_repair()
			if world.is_busy():
				return
		if repair_left <= 0.0 and engine_failed:
			active = false
			crashed.emit()
			return
	if world.admin_enabled("no_cooldowns"):
		hack_cooldown = 0.0
		grenade_cooldown = 0.0
		shot_cooldown = 0.0
	hack = maxf(0, hack - delta)
	hack_cooldown = maxf(0, hack_cooldown - delta)
	grenade_cooldown = maxf(0, grenade_cooldown - delta)
	shot_cooldown = maxf(0, shot_cooldown - delta)
	hurt = maxf(0, hurt - delta)
	lane = clampi(lane + int(Input.is_action_just_pressed("move_right")) - int(Input.is_action_just_pressed("move_left")), 0, 2)
	_steer(delta)
	if flight and elapsed >= 9.0 and elapsed < 15.0 and Input.is_action_just_pressed("hack") and not transponder_sent and engine_repaired:
		transponder_sent = true
		world.sound("hack")
	if not flight:
		if Input.is_action_just_pressed("hack") and hack_cooldown == 0:
			if absf(x - boss_x) < 35.0:
				hack = 3.3
				hack_cooldown = 7.0
				world.sound("hack")
			else:
				world.toast("Für den Hack auf die Spur des Wagens wechseln.")
		if Input.is_action_pressed("attack") and shot_cooldown == 0:
			bullets.append(Vector2(x, BIKE_Y + 14.0))
			shot_cooldown = 0.23
			_sound("shot")
			flashes.append({"p": Vector2(x, BIKE_Y + 14), "t": 0.09})
			velocity_x -= 8.0
		if Input.is_action_just_pressed("dash") and grenade_cooldown == 0:
			grenade = Vector2(x, BIKE_Y + 18.0)
			grenade_cooldown = 3.4
	if not flight:
		if hack > 0:
			ram_warning = 0.0
		elif ram_warning > 0.0:
			ram_warning -= delta
			if ram_warning <= 0.0:
				if absf(x - boss_x) < 30:
					_hit(32)
				ram_recovery = 0.8
		ram_recovery = maxf(0.0, ram_recovery - delta)
	if elapsed >= next_hazard and not engine_failed:
		next_hazard = elapsed + (1.14 if flight else maxf(0.75, 1.4 - elapsed * 0.012))
		hazards.append(Vector2(LANES[(lane + 1 + pattern % 2) % 3], 68))
		if not flight and hack == 0 and ram_warning <= 0.0:
			boss_lane = [1, 0, 2, 1, 2, 0][pattern % 6]
			if pattern % 4 == 3:
				ram_warning = 0.85
				world.sound("hit")
			else:
				rear_shots.append(Vector2(boss_x, REAR_Y - 25))
				flashes.append({"p": Vector2(boss_x, REAR_Y - 25), "t": 0.09})
				_sound("shot")
		pattern += 1
	for i in range(bullets.size() - 1, -1, -1):
		bullets[i].y += 490 * delta
		if bullets[i].y >= REAR_Y - 19:
			if absf(bullets[i].x - boss_x) < 30:
				armour -= 10 if hack > 0 else 5
				impact(Vector2(bullets[i].x, REAR_Y - 19))
			bullets.remove_at(i)
	if grenade != Vector2.ZERO:
		grenade.y += 288 * delta
		if grenade.y >= REAR_Y - 15:
			if absf(grenade.x - boss_x) < 44:
				armour -= 33
				world.sound("hit")
			impact(grenade, true)
			grenade = Vector2.ZERO
	for i in range(rear_shots.size() - 1, -1, -1):
		rear_shots[i].y -= 350 * delta
		if rear_shots[i].y <= BIKE_Y:
			if absf(rear_shots[i].x - x) < 24:
				_hit(18)
			rear_shots.remove_at(i)
	var player_y: = FLIGHT_Y if flight else BIKE_Y
	for i in range(hazards.size() - 1, -1, -1):
		var before: = hazards[i].y
		hazards[i].y += (210.0 if flight else 226.0) * delta
		if before < player_y and hazards[i].y >= player_y and absf(hazards[i].x - x) < 30:
			_hit(24)
			impact(hazards[i], true)
			hazards.remove_at(i)
			continue
		if hazards[i].y > 370:
			hazards.remove_at(i)
	queue_redraw()
	if health <= 0:
		active = false
		crashed.emit()
	elif flight and elapsed >= 15.0:
		active = false
		if transponder_sent and engine_repaired:
			completed.emit()
		else:
			crashed.emit()
	elif not flight and armour <= 0:
		victory_left = 1.1
		impact(Vector2(boss_x, REAR_Y), true)
		world.toast("RAVEN: Verfolger ausgeschaltet! Weiter zur Garage!")

func _hit(amount: int) -> void :
	if world.admin_enabled("god_mode"):
		return
	if hurt > 0.0:
		return
	health -= amount
	velocity_x += -100.0 if x > 320.0 else 100.0
	shake = 3.0
	impact(Vector2(x, FLIGHT_Y if flight else BIKE_Y))
	hurt = 0.6
	world.sound("hit")

func _draw() -> void :
	var cyan: = Color("67f0fc")
	var pink: = Color("ff657e")
	draw_set_transform(Vector2(sin(fx_clock * 57) * shake, cos(fx_clock * 43) * shake * 0.6))
	if flight:
		_draw_airspace(cyan)
	else:
		_draw_highway()
	draw_set_transform(Vector2.ZERO)
	# Shake the scenery subtly; HUD remains steady and readable.
	if not flight:
		var p := Vector2(boss_x, REAR_Y - (1.0 - ram_warning / 0.85) * 42.0 if ram_warning > 0.0 else REAR_Y - ram_recovery * 50.0)
		_draw_vehicle(1, p, Vector2(98, 72), -boss_velocity * 0.0006)
		if ram_warning > 0.0:
			draw_line(Vector2(p.x, BIKE_Y - 22), p, Color(pink, 0.65), 3.0)
			draw_arc(Vector2(p.x, BIKE_Y), 29, 0, TAU, 24, pink, 2)
		if hack > 0:
			draw_arc(p, 38, fx_clock * 4, fx_clock * 4 + 5, 32, cyan, 2)
	for point in hazards:
		if flight:
			_draw_vehicle(3, point, Vector2(38, 32), sin(fx_clock * 3 + point.y) * 0.12)
		else:
			var art := preload("res://scripts/prop_art.gd").texture(1)
			draw_texture_rect(art, Rect2(point - Vector2(14, 18), Vector2(28, 30)), false)
	for shot in rear_shots:
		draw_line(shot, shot + Vector2(0, 10), pink, 2.0)
	for bullet in bullets:
		draw_line(bullet, bullet + Vector2(0, 11), cyan, 2)
	if grenade != Vector2.ZERO:
		draw_circle(grenade, 5, Color("ffd46b"))
	var bike: = Vector2(x, FLIGHT_Y if flight else BIKE_Y)
	var paint: = pink if hurt > 0 else cyan
	var tilt := clampf(-velocity_x * 0.001, -0.24, 0.24)
	if engine_failed:
		tilt += 0.15 + sin(fx_clock * 23.0) * 0.035
	_draw_vehicle(0 if flight else 2, bike, Vector2(112, 82) if flight else Vector2(76, 65), tilt)
	if flight:
		for side in [-1, 1]:
			var nozzle := bike + Vector2(side * 19, 31).rotated(tilt)
			var failing: bool = engine_failed and side == 1
			if not failing or sin(fx_clock * 32.0) > 0.8:
				var length := (5.0 if failing else 15.0 + restart_flash * 10.0) + sin(fx_clock * 37) * 3
				draw_line(nozzle, nozzle + Vector2(0, length), Color(1.0, 0.4, 0.12, 0.35) if failing else Color(0.1, 0.8, 1, 0.4), 9, true)
				draw_line(nozzle, nozzle + Vector2(0, length * 0.8), Color("fff1bb") if failing else Color("b8f6ff"), 3, true)
	_draw_fx()
	if engine_failed:
		draw_rect(Rect2(210, 118, 220, 18), Color(0.04, 0.07, 0.12, 0.92))
		draw_rect(Rect2(218, 124, 204, 6), Color("4d2431"))
		draw_rect(Rect2(218, 124, 204.0 * repair_left / REPAIR_SECONDS, 6), cyan)
		draw_arc(bike, 47, -PI, 0, 32, Color(pink, 0.6 + sin(fx_clock * 9) * 0.3), 2)
	if hurt > 0.0:
		draw_arc(bike, 25.0, 0.0, TAU, 24, Color(paint, hurt), 2.0)

func _draw_scrolling_city(texture: Texture2D, speed: float) -> void :
	var shift: = fposmod(elapsed * speed, 360.0)
	draw_texture_rect(texture, Rect2(0, shift - 360.0, 640, 360), false)
	draw_texture_rect(texture, Rect2(0, shift, 640, 360), false)

func _draw_highway() -> void :
	_draw_scrolling_city(Painted.ART.highway, 190.0)
	for i in 44:
		var rain: = Vector2(i * 157 % 640, fposmod(i * 37 + elapsed * 335, 360))
		draw_line(rain, rain + Vector2(-2, 8), Color(0.67, 0.71, 0.9, 0.18))

func _draw_airspace(cyan: Color) -> void :
	_draw_scrolling_city(Painted.ART.airspace, 84.0)
	for i in 9:
		var y: = fposmod(i * 48 + elapsed * 135.0, 432.0) - 36.0
		for x_pos in [168, 472]:
			draw_arc(Vector2(x_pos, y), 7, 0, TAU, 16, Color(cyan, 0.35), 1)
			draw_circle(Vector2(x_pos, y), 2.0, cyan)
	if elapsed >= 7.0:
		var scanner_y: = minf(111.0, (elapsed - 7.0) * 39.0)
		draw_line(Vector2(167, scanner_y), Vector2(474, scanner_y), Color(cyan, 0.65), 2)
