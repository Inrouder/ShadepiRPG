extends Node2D

const VEHICLES = preload("res://assets/world/hq/vehicles.png")
const Airframe = preload("res://scripts/aerodyne_art.gd")
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

# --- Motorcycle chase (v0.20.0): free steering, throttle, drones and road objects.
const ROAD := Vector2(198.0, 442.0)
const BIKE_RANGE := Vector2(118.0, 300.0)
const ROAD_SPEED := 226.0
var bike_y := BIKE_Y
var bike_vy := 0.0
var steer_axis := 0.0
var throttle := 0.0
var speed := 1.0
var scroll := 0.0
var boost := 0.0
var slick := 0.0
var car_y := REAR_Y
## Road objects: {"k": wreck | slick | boost | mine, "p": Vector2, "done": bool, "r": float}
var objects: Array[Dictionary] = []
## Drones: {"p": Vector2, "state": in | hover | out | hacked, "t": float, "drops": int, "spin": float}
var drones: Array[Dictionary] = []
var next_drone := 4.0
var edge_spark := 0.0
var callout := ""
var callout_time := 0.0

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
		if flight:
			var drift := 900.0 if engine_failed else 0.0
			velocity_x += ((LANES[lane] - x) * 65.0 - velocity_x * 15.0 + drift) * step
			x = clampf(x + velocity_x * step, 190.0, 450.0)
		else:
			# Free steering with inertia; oil makes the rear wheel wander.
			var wander := sin(fx_clock * 7.0) * 320.0 if slick > 0.0 else 0.0
			velocity_x += ((steer_axis * 250.0 - velocity_x) * (3.0 if slick > 0.0 else 9.0) + wander) * step
			x = clampf(x + velocity_x * step, ROAD.x, ROAD.y)
			bike_vy += ((-throttle * 150.0 - bike_vy) * 7.0) * step
			bike_y = clampf(bike_y + bike_vy * step, BIKE_RANGE.x, BIKE_RANGE.y)
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
			_smoke(Vector2(boss_x, car_y + 15))

func _draw_vehicle(index: int, center: Vector2, size: Vector2, tilt: float = 0.0) -> void:
	var region := Rect2((index % 2) * 627, (index / 2) * 627, 627, 627)
	draw_set_transform(center, tilt)
	if index==0:
		Airframe.draw(self,Rect2(-size*0.5,size),fx_clock,1.0)
	else:
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
	if not flight:
		_process_bike(delta)
		return
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
	if not flight and boost > 0.0:
		return
	if hurt > 0.0:
		return
	health -= amount
	velocity_x += -100.0 if x > 320.0 else 100.0
	shake = 3.0
	impact(Vector2(x, FLIGHT_Y if flight else bike_y))
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
		_draw_bike_scene(cyan, pink)
		return
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
	var shift: = fposmod(scroll, 360.0)
	draw_texture_rect(Painted.ART.highway, Rect2(0, shift - 360.0, 640, 360), false)
	draw_texture_rect(Painted.ART.highway, Rect2(0, shift, 640, 360), false)
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

# --- Motorrad-Verfolgung --------------------------------------------------------

func _axis(negative: String, positive: String) -> float:
	if not InputMap.has_action(negative) or not InputMap.has_action(positive):
		return 0.0
	return Input.get_axis(negative, positive)

func _callout(text: String) -> void:
	callout = text
	callout_time = 1.3

func _process_bike(delta: float) -> void:
	callout_time = maxf(0.0, callout_time - delta)
	if victory_left >= 0.0:
		victory_left -= delta
		throttle = 1.0
		steer_axis = 0.0
		_steer(delta)
		speed = 1.35
		scroll += ROAD_SPEED * speed * delta
		_advance_bike_world(delta)
		queue_redraw()
		if victory_left <= 0.0:
			active = false
			completed.emit()
		return
	elapsed += delta
	if world.admin_enabled("no_cooldowns"):
		hack_cooldown = 0.0
		grenade_cooldown = 0.0
		shot_cooldown = 0.0
	hack = maxf(0, hack - delta)
	hack_cooldown = maxf(0, hack_cooldown - delta)
	grenade_cooldown = maxf(0, grenade_cooldown - delta)
	shot_cooldown = maxf(0, shot_cooldown - delta)
	hurt = maxf(0, hurt - delta)
	boost = maxf(0.0, boost - delta)
	slick = maxf(0.0, slick - delta)
	steer_axis = _axis("move_left", "move_right")
	throttle = _axis("move_down", "move_up")
	_steer(delta)
	# Riding further ahead is faster; the turbo strip adds a burst on top.
	speed = 1.0 + clampf((BIKE_Y - bike_y) / (BIKE_Y - BIKE_RANGE.x), -0.6, 1.0) * 0.32 + (0.45 if boost > 0.0 else 0.0)
	scroll += ROAD_SPEED * speed * delta
	_edge_sparks(delta)
	_bike_weapons()
	_car_ai(delta)
	if elapsed >= next_hazard:
		_spawn_road_object()
	if elapsed >= next_drone and drones.size() < (2 if armour < 50 else 1):
		drones.append({"p": Vector2(rng.randf_range(240.0, 400.0), -40.0), "state": "in", "t": 0.0, "drops": 0, "spin": 0.0})
		next_drone = elapsed + (4.6 if armour < 50 else 7.0)
		_callout("DROHNE ÜBER DER STRASSE")
	_advance_bike_world(delta)
	queue_redraw()
	if health <= 0:
		active = false
		crashed.emit()
	elif armour <= 0:
		victory_left = 1.1
		impact(Vector2(boss_x, car_y), true)
		impact(Vector2(boss_x - 18, car_y + 10), true)
		_callout("WEG FREI · ZUR GARAGE")
		world.toast("RAVEN: Verfolger ausgeschaltet! Weiter zur Garage!")

func _edge_sparks(delta: float) -> void:
	edge_spark = maxf(0.0, edge_spark - delta)
	var scraping := (x <= ROAD.x + 0.5 and steer_axis < -0.2) or (x >= ROAD.y - 0.5 and steer_axis > 0.2)
	if scraping and edge_spark == 0.0:
		edge_spark = 0.05
		impact(Vector2(x + (-15.0 if x < 320.0 else 15.0), bike_y + 8.0), false, Color("ffd27a"))

func _hack_drone() -> Dictionary:
	var best: Dictionary = {}
	var best_dx := 80.0
	for drone: Dictionary in drones:
		if drone.state in ["in", "hover"] and absf(drone.p.x - x) < best_dx:
			best_dx = absf(drone.p.x - x)
			best = drone
	return best

func _bike_weapons() -> void:
	if Input.is_action_just_pressed("hack") and hack_cooldown == 0:
		var drone := _hack_drone()
		if not drone.is_empty():
			drone.state = "hacked"
			drone.t = 0.0
			hack_cooldown = 4.0
			world.sound("hack")
			_callout("DROHNE GEKAPERT")
		elif absf(x - boss_x) < 35.0 and car_y - bike_y < 170.0:
			hack = 3.3
			hack_cooldown = 7.0
			world.sound("hack")
			_callout("LENKUNG GEHACKT")
		else:
			world.toast("Für den Hack hinter den Wagen oder unter eine Drohne fahren.")
	if Input.is_action_pressed("attack") and shot_cooldown == 0:
		bullets.append(Vector2(x, bike_y + 14.0))
		shot_cooldown = 0.2
		_sound("shot")
		flashes.append({"p": Vector2(x, bike_y + 14), "t": 0.09})
		velocity_x -= 8.0
	if Input.is_action_just_pressed("dash") and grenade_cooldown == 0:
		grenade = Vector2(x, bike_y + 18.0)
		grenade_cooldown = 3.4

func _car_ai(delta: float) -> void:
	# The pursuer keeps its distance behind the bike; riding far ahead buys
	# safety from rams but takes Raven out of hacking range.
	var follow := clampf(bike_y + 86.0, 250.0, 332.0)
	car_y = move_toward(car_y, follow, 110.0 * delta)
	if hack > 0:
		ram_warning = 0.0
	elif ram_warning > 0.0:
		ram_warning -= delta
		if ram_warning <= 0.0:
			if absf(x - boss_x) < 30 and car_y - bike_y < 140.0:
				_hit(32)
				_callout("RAMMSTOSS!")
			ram_recovery = 0.8
	ram_recovery = maxf(0.0, ram_recovery - delta)

func _spawn_road_object() -> void:
	next_hazard = elapsed + maxf(0.7, 1.35 - elapsed * 0.012)
	var lanes := [236.0, 320.0, 404.0]
	var lane_x: float = lanes[(int(x > 278.0) + int(x > 362.0) + 1 + pattern % 2) % 3]
	match pattern % 8:
		0, 2:
			hazards.append(Vector2(lane_x, -20))
		1, 6:
			objects.append({"k": "wreck", "p": Vector2(lane_x, -40), "done": false, "r": rng.randf_range(-0.5, 0.5)})
		3:
			objects.append({"k": "slick", "p": Vector2(lane_x, -20), "done": false, "r": 0.0})
		4:
			hazards.append(Vector2(lanes[0], -20))
			hazards.append(Vector2(lanes[2], -20))
		5, 7:
			objects.append({"k": "boost", "p": Vector2(lanes[(pattern / 2) % 3], -30), "done": false, "r": 0.0})
	if hack == 0 and ram_warning <= 0.0:
		boss_lane = [1, 0, 2, 1, 2, 0][pattern % 6]
		if pattern % 4 == 3:
			ram_warning = 0.85
			world.sound("hit")
		else:
			rear_shots.append(Vector2(boss_x, car_y - 25))
			if armour < 50:
				rear_shots.append(Vector2(boss_x + 16, car_y - 25))
			flashes.append({"p": Vector2(boss_x, car_y - 25), "t": 0.09})
			_sound("shot")
	pattern += 1

func _advance_bike_world(delta: float) -> void:
	var road := ROAD_SPEED * speed * delta
	for i in range(bullets.size() - 1, -1, -1):
		bullets[i].y += 490 * delta
		if bullets[i].y >= car_y - 19:
			if absf(bullets[i].x - boss_x) < 30:
				armour -= 10 if hack > 0 else 5
				impact(Vector2(bullets[i].x, car_y - 19))
			bullets.remove_at(i)
	if grenade != Vector2.ZERO:
		grenade.y += 288 * delta
		if grenade.y >= car_y - 15:
			if absf(grenade.x - boss_x) < 44:
				armour -= 33
				world.sound("hit")
			impact(grenade, true)
			grenade = Vector2.ZERO
	for i in range(rear_shots.size() - 1, -1, -1):
		rear_shots[i].y -= 350 * delta
		if rear_shots[i].y <= bike_y:
			if absf(rear_shots[i].x - x) < 24:
				_hit(18)
			rear_shots.remove_at(i)
	for i in range(hazards.size() - 1, -1, -1):
		var before: = hazards[i].y
		hazards[i].y += road
		if before < bike_y and hazards[i].y >= bike_y and absf(hazards[i].x - x) < 30:
			_hit(24)
			impact(hazards[i], true)
			hazards.remove_at(i)
			continue
		if hazards[i].y > 380:
			hazards.remove_at(i)
	for i in range(objects.size() - 1, -1, -1):
		var item: Dictionary = objects[i]
		item.p.y += road
		var offset: Vector2 = item.p - Vector2(x, bike_y)
		match item.k:
			"wreck":
				if not item.done and absf(offset.x) < 34.0 and absf(offset.y) < 24.0:
					item.done = true
					_hit(28)
					impact(Vector2(x, bike_y), true)
				if emission_clock > 0.08 and world.visual_quality > 0:
					_smoke(item.p + Vector2(rng.randf_range(-8, 8), -4))
			"slick":
				if not item.done and absf(offset.x) < 36.0 and absf(offset.y) < 16.0:
					item.done = true
					slick = 1.1
					_callout("ÖLSPUR!")
			"boost":
				if not item.done and absf(offset.x) < 26.0 and absf(offset.y) < 24.0:
					item.done = true
					boost = 1.8
					health = mini(100, health + 6)
					world.sound("hack")
					_callout("TURBO")
			"mine":
				if absf(offset.x) < 16.0 and absf(offset.y) < 16.0:
					_hit(20)
					impact(item.p, true)
					objects.remove_at(i)
					continue
				if absf(item.p.x - boss_x) < 40.0 and absf(item.p.y - car_y) < 20.0:
					armour -= 8
					impact(item.p, true)
					_callout("MINE TRIFFT DEN WAGEN")
					objects.remove_at(i)
					continue
		if item.p.y > 400:
			objects.remove_at(i)
	for i in range(drones.size() - 1, -1, -1):
		var drone: Dictionary = drones[i]
		drone.t += delta
		match drone.state:
			"in":
				drone.p.y = move_toward(drone.p.y, 92.0, 140.0 * delta)
				if drone.p.y >= 91.0:
					drone.state = "hover"
					drone.t = 0.0
			"hover":
				var aim := clampf(x + sin(elapsed * 1.3 + i) * 40.0, ROAD.x, ROAD.y)
				drone.p.x = move_toward(drone.p.x, aim, 70.0 * delta)
				if drone.t >= 1.4:
					drone.t = 0.0
					drone.drops += 1
					objects.append({"k": "mine", "p": drone.p + Vector2(0, 22), "done": false, "r": 0.0})
					flashes.append({"p": drone.p + Vector2(0, 18), "t": 0.08})
					if drone.drops >= 3:
						drone.state = "out"
			"out":
				drone.p.y -= 160.0 * delta
				if drone.p.y < -60.0:
					drones.remove_at(i)
					continue
			"hacked":
				# Raven steers the captured drone into the pursuing car.
				drone.p.y += 300.0 * delta
				drone.spin += 9.0 * delta
				drone.p.x = move_toward(drone.p.x, boss_x, 150.0 * delta)
				if drone.p.y >= car_y - 10.0:
					if absf(drone.p.x - boss_x) < 52.0:
						armour -= 18
						_callout("DROHNE TRIFFT DEN WAGEN!")
					impact(drone.p, true)
					drones.remove_at(i)
					continue

func _draw_bike_scene(cyan: Color, pink: Color) -> void:
	# Road objects lie on the asphalt, below all vehicles.
	for item: Dictionary in objects:
		match item.k:
			"wreck": _draw_wreck(item)
			"slick": _draw_slick(item.p)
			"boost": _draw_boost(item.p, item.done)
			"mine": _draw_mine(item.p)
	for point in hazards:
		_draw_barrier(point)
	if speed > 1.12 or boost > 0.0:
		for i in 10:
			var lx := 205.0 + (i * 53) % 230
			var ly := fposmod(i * 71 + scroll * 1.6, 380.0) - 20.0
			draw_line(Vector2(lx, ly), Vector2(lx, ly + 26.0 + boost * 10.0), Color(0.75, 0.95, 1.0, 0.16 + boost * 0.08), 1.0)
	draw_set_transform(Vector2.ZERO)
	var car := Vector2(boss_x, car_y - (1.0 - ram_warning / 0.85) * minf(42.0, maxf(0.0, car_y - bike_y - 40.0)) if ram_warning > 0.0 else car_y - ram_recovery * 40.0)
	_draw_vehicle(1, car, Vector2(98, 72), -boss_velocity * 0.0006)
	if ram_warning > 0.0:
		draw_line(Vector2(car.x, bike_y + 22), car, Color(pink, 0.65), 3.0)
		draw_arc(Vector2(car.x, bike_y), 29, 0, TAU, 24, pink, 2)
	if hack > 0:
		draw_arc(car, 38, fx_clock * 4, fx_clock * 4 + 5, 32, cyan, 2)
	for shot in rear_shots:
		draw_line(shot, shot + Vector2(0, 10), pink, 2.0)
	for bullet in bullets:
		draw_line(bullet, bullet + Vector2(0, 11), cyan, 2)
	if grenade != Vector2.ZERO:
		draw_circle(grenade, 5, Color("ffd46b"))
	var bike := Vector2(x, bike_y)
	var tilt := clampf(velocity_x * 0.0012, -0.3, 0.3)
	if boost > 0.0:
		for side in [-5, 5]:
			var flame := 14.0 + sin(fx_clock * 40.0 + side) * 4.0
			draw_line(bike + Vector2(side, 30), bike + Vector2(side, 30 + flame), Color(0.3, 0.9, 1.0, 0.55), 6.0, true)
			draw_line(bike + Vector2(side, 30), bike + Vector2(side, 30 + flame * 0.6), Color("e9fdff"), 2.0, true)
	_draw_vehicle(2, bike, Vector2(84, 84), tilt)
	if slick > 0.0:
		draw_arc(bike, 28.0, fx_clock * 6.0, fx_clock * 6.0 + 2.2, 16, Color("c17bff"), 2.0)
	for drone: Dictionary in drones:
		var height := 40.0 if drone.state != "hacked" else maxf(4.0, 40.0 - drone.t * 60.0)
		draw_set_transform(drone.p + Vector2(10, height), 0.0, Vector2(1.0, 0.45))
		draw_circle(Vector2.ZERO, 18.0, Color(0, 0, 0, 0.35))
		draw_set_transform(Vector2.ZERO)
		_draw_vehicle(3, drone.p, Vector2(50, 50), drone.spin)
		if drone.state == "hacked":
			draw_arc(drone.p, 24, fx_clock * 5, fx_clock * 5 + 4, 24, cyan, 2)
		elif drone.state == "hover" and drone.t > 1.0:
			draw_arc(drone.p + Vector2(0, 22), 7.0, 0, TAU, 12, Color(pink, 0.8), 2.0)
	_draw_fx()
	if hurt > 0.0:
		draw_arc(bike, 25.0, 0.0, TAU, 24, Color(pink, hurt), 2.0)
	if callout_time > 0.0:
		var font := ThemeDB.fallback_font
		var alpha := minf(1.0, callout_time * 2.0)
		draw_string_outline(font, Vector2(0, 96), callout, HORIZONTAL_ALIGNMENT_CENTER, 640, 18, 5, Color(0.05, 0.02, 0.08, alpha))
		draw_string(font, Vector2(0, 96), callout, HORIZONTAL_ALIGNMENT_CENTER, 640, 18, Color(1.0, 0.86, 0.45, alpha))

func _draw_barrier(point: Vector2) -> void:
	# Concrete jersey barrier with hazard stripes and blinking end lamps.
	var rect := Rect2(point - Vector2(29, 8), Vector2(58, 16))
	draw_rect(Rect2(rect.position + Vector2(3, 4), rect.size), Color(0, 0, 0, 0.35))
	draw_rect(rect, Color("6f747c"))
	draw_rect(Rect2(rect.position, Vector2(rect.size.x, 4)), Color("9aa0a8"))
	for i in 6:
		var sx := rect.position.x + 4 + i * 9
		draw_colored_polygon(PackedVector2Array([Vector2(sx, rect.end.y - 2), Vector2(sx + 5, rect.position.y + 5), Vector2(sx + 9, rect.position.y + 5), Vector2(sx + 4, rect.end.y - 2)]), Color("e8b730") if i % 2 == 0 else Color("1d1f24"))
	var blink := 0.5 + 0.5 * sin(fx_clock * 9.0 + point.x)
	for end_x in [rect.position.x + 3, rect.end.x - 3]:
		draw_circle(Vector2(end_x, rect.position.y + 2), 2.5, Color(1.0, 0.25, 0.3, 0.5 + blink * 0.5))
		draw_circle(Vector2(end_x, rect.position.y + 2), 7.0, Color(1.0, 0.2, 0.3, 0.12 * blink))

func _draw_wreck(item: Dictionary) -> void:
	var region := Rect2(627, 0, 627, 627)
	draw_set_transform(item.p, item.r)
	draw_texture_rect_region(VEHICLES, Rect2(Vector2(-37, -27), Vector2(74, 54)), region, Color(0.32, 0.27, 0.27))
	draw_set_transform(Vector2.ZERO)
	for i in 3:
		var flicker := 5.0 + sin(fx_clock * 13.0 + i * 2.1 + item.p.y) * 2.0
		var p: Vector2 = item.p + Vector2(-10 + i * 10, -4 + (i % 2) * 6)
		draw_circle(p, flicker + 3.0, Color(1.0, 0.35, 0.05, 0.45))
		draw_circle(p, flicker * 0.55, Color("ffd87a"))

func _draw_slick(point: Vector2) -> void:
	draw_set_transform(point, 0.0, Vector2(1.0, 0.42))
	draw_circle(Vector2.ZERO, 36.0, Color(0.05, 0.02, 0.09, 0.85))
	draw_arc(Vector2(-6, -4), 22.0, 3.6, 5.2, 16, Color(0.8, 0.35, 1.0, 0.55), 3.0)
	draw_arc(Vector2(8, 4), 16.0, 0.3, 1.8, 12, Color(0.3, 0.9, 1.0, 0.45), 2.0)
	draw_set_transform(Vector2.ZERO)

func _draw_boost(point: Vector2, used: bool) -> void:
	var color := Color(0.3, 0.95, 1.0, 0.25 if used else 0.55 + 0.35 * sin(fx_clock * 8.0))
	for i in 3:
		var tip := point + Vector2(0, -14 + i * 12)
		draw_polyline(PackedVector2Array([tip + Vector2(-14, 9), tip, tip + Vector2(14, 9)]), color, 4.0, true)
	draw_rect(Rect2(point - Vector2(20, 24), Vector2(40, 48)), Color(color, 0.12))

func _draw_mine(point: Vector2) -> void:
	var blink := fposmod(fx_clock * 3.0 + point.x * 0.1, 1.0) < 0.5
	draw_circle(point + Vector2(2, 3), 8.0, Color(0, 0, 0, 0.4))
	draw_circle(point, 8.0, Color("2a2d33"))
	draw_arc(point, 8.0, 0, TAU, 16, Color("5b616b"), 1.5)
	draw_circle(point, 3.0, Color("ff3b55") if blink else Color("6b1220"))
	if blink:
		draw_arc(point, 13.0, 0, TAU, 20, Color(1.0, 0.25, 0.35, 0.5), 1.5)
