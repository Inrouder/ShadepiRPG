extends Node2D

const VEHICLES = preload("res://assets/world/hq/vehicles.png")
const Airframe = preload("res://scripts/aerodyne_art.gd")
const BikeArt = preload("res://scripts/motorcycle_art.gd")
const PixelFX = preload("res://scripts/pixel_combat_fx.gd")
const CarArt = preload("res://scripts/pursuit_car_art.gd")
const DroneArt = preload("res://scripts/cargo_drone_art.gd")
const Painted = preload("res://scripts/painted_world.gd")
# v0.56.0 · ClaudeHelper: Pixel-FX der Verfolgung (tools/fx/build_drive_fx.py).
const FX_EXPLOSION = preload("res://assets/fx/drive/explosion.png")
const FX_SMOKE = preload("res://assets/fx/drive/smoke.png")
const FX_FLAME = preload("res://assets/fx/drive/flame.png")
const FX_CHUNKS = preload("res://assets/fx/drive/chunks.png")
const CAR_WRECK = preload("res://assets/vehicles/pursuit/wreck.png")
const CAR_BLAST_AT := 0.9      # Sekunden vom letzten Treffer bis zur großen Explosion
const VICTORY_SECONDS := 4.6

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
var car_recoil := 0.0
var rear_shot_vx: Array[float] = []

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
var failure_left := -1.0
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
var fx_layer: Node2D
## v0.56.0 · ClaudeHelper: Der besiegte Wagen brennt, explodiert und bleibt als Wrack zurück.
var car_dead := -1.0
var car_rot := 0.0
var car_spin := 0.0
var car_drift := 0.0
var car_fall := 0.0
var car_next_blast := 0.0
var white_flash := 0.0
var smashed := 0
## v0.58.0 · ClaudeHelper (Nutzerauftrag „Level strecken“): Die Verfolgung läuft in der Kampagne
## über drei Etappen – Stadt, Tunnel, Hochstraße – mit je einem eigenen Verfolgerwagen.
signal stage_changed(index: int)
const STAGE_NAMES := ["STADT", "TUNNEL", "HOCHSTRASSE"]
const STAGE_ARMOUR := [100, 80, 100]
const STAGE_SHIFT_SECONDS := 3.2
var stages := 1
var stage := 0
var stage_shift := -1.0
var stage_swapped := false
var wind := 0.0
var wind_dir := 1.0
var next_wind := 6.0
var stage_start := 0.0
var over_layer: Node2D
var overpass_y := 400.0
var next_overpass := 7.0

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	rng.seed = 2534
	# Pixel-FX liegen auf einer eigenen Ebene mit harter Abtastung über Straße und Fahrzeugen.
	over_layer = Node2D.new()
	over_layer.name = "Overpass"
	over_layer.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	over_layer.draw.connect(_draw_overpass)
	add_child(over_layer)
	fx_layer = Node2D.new()
	fx_layer.name = "DriveFX"
	fx_layer.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	fx_layer.draw.connect(_draw_fx)
	add_child(fx_layer)

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

func impact(point: Vector2, explosive: bool = false, color: Color = Color("ffba68"), size: float = 1.0) -> void:
	var limit := 50 if world.visual_quality == 0 else 150
	for i in mini(28 if explosive else 7, maxi(0, limit - debris.size())):
		var v := Vector2.from_angle(rng.randf() * TAU) * rng.randf_range(35, 150)
		debris.append({"p": point, "v": v, "t": rng.randf_range(0.3, 0.9), "a": rng.randf() * TAU, "spin": rng.randf_range(-9, 9), "c": color, "k": -1})
	if explosive:
		if explosions.size() < 8:
			explosions.append({"p": point, "t": 0.65, "d": 0.65, "s": size, "flip": rng.randf() < 0.5})
		for i in 7:
			_smoke(point + Vector2(rng.randf_range(-12, 12), rng.randf_range(-8, 8)))
		shake = maxf(shake, 4.0 * size)
		_sound("explosion")

func _smoke(point: Vector2) -> void:
	if clouds.size() < (14 if world.visual_quality == 0 else 45):
		clouds.append({"p": point, "t": 1.4, "r": rng.randf_range(4, 10)})

## Bruchstücke aus dem Pixelblatt: 0–5 Beton (1 und 4 mit Warnstreifen), 6–9 Blech, 10–11 Bakenlampe.
func chunks(point: Vector2, kinds: Array, count: int, force: float = 1.0, push: Vector2 = Vector2.ZERO) -> void:
	var limit := 50 if world.visual_quality == 0 else 150
	for i in mini(count, maxi(0, limit - debris.size())):
		var v := Vector2.from_angle(rng.randf() * TAU) * rng.randf_range(40, 170) * force + push
		debris.append({"p": point + Vector2(rng.randf_range(-14, 14), rng.randf_range(-5, 5)), "v": v, "t": rng.randf_range(0.55, 1.2), "a": rng.randf() * TAU, "spin": rng.randf_range(-11, 11), "c": Color.WHITE, "k": kinds[rng.randi() % kinds.size()]})

## Der Verfolger pflügt durch ein Hindernis: Bake zerbirst, Wrack fliegt auseinander.
func car_smash(point: Vector2, kind: String) -> void:
	smashed += 1
	var push := Vector2(signf(point.x - boss_x) * 45.0, 70.0)
	if kind == "barrier":
		chunks(point, [0, 1, 2, 3, 4, 5], 12, 0.9, push)
		chunks(point, [10, 11], 2, 1.2, push)
		impact(point, false, Color("ffe9a8"))
		for i in 4:
			_smoke(point + Vector2(rng.randf_range(-22, 22), rng.randf_range(-6, 6)))
		shake = maxf(shake, 2.6)
		world.sound("prop_metal")
	else:
		chunks(point, [6, 7, 8, 9], 12, 1.1, push)
		impact(point, true, Color("ffba68"), 1.15)
	car_recoil = maxf(car_recoil, 0.12)

func _update_fx(delta: float) -> void:
	fx_clock += delta
	car_recoil = maxf(0,car_recoil-delta)
	shake = move_toward(shake, 0.0, delta * 9.0)
	restart_flash = maxf(0.0, restart_flash - delta)
	white_flash = maxf(0.0, white_flash - delta)
	if not flight: _advance_overpass(delta)
	if is_instance_valid(fx_layer):
		fx_layer.queue_redraw()
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
		elif not flight and armour < 45 and car_y < 400.0:
			_smoke(Vector2(boss_x, car_y + (0.0 if car_dead >= 0.0 else 15.0)))

func _draw_vehicle(index: int, center: Vector2, size: Vector2, tilt: float = 0.0) -> void:
	var region := Rect2((index % 2) * 627, (index / 2) * 627, 627, 627)
	draw_set_transform(center, tilt)
	if index==0:
		Airframe.draw(self,Rect2(-size*0.5,size),fx_clock,1.0)
	elif index==1:
		draw_set_transform(Vector2.ZERO)
		CarArt.draw(self,center,car_frame())
	elif index==3:
		DroneArt.draw(self,center,size,fx_clock,tilt)
	else:
		draw_texture_rect_region(VEHICLES, Rect2(-size * 0.5, size), region)
	draw_set_transform(Vector2.ZERO)

func _draw_fx() -> void:
	var c: Node2D = fx_layer
	c.draw_set_transform(Vector2(sin(fx_clock * 57) * shake, cos(fx_clock * 43) * shake * 0.6))
	for cloud in clouds:
		var age: float = 1.0 - cloud.t / 1.4
		var side: float = cloud.r * 6.0
		c.draw_texture_rect_region(FX_SMOKE, Rect2(cloud.p - Vector2(side, side) * 0.5, Vector2(side, side)), Rect2(mini(5, int(age * 6.0)) * 144, 0, 144, 144), Color(1, 1, 1, minf(1.0, (1.0 - age) * 1.6) * 0.85))
	# Brennender Verfolger: Flammen sitzen auf Haube, Dach und Heck.
	if car_dead >= 0.0 and not flight and car_y < 420.0:
		var car := car_position()
		var fires := 2 if car_dead < CAR_BLAST_AT else 4
		for i in fires:
			var offset: Vector2 = [Vector2(-9, -14), Vector2(11, 6), Vector2(-4, 16), Vector2(8, -22)][i].rotated(car_rot)
			var frame := int(fx_clock * 12.0 + i * 2) % 6
			var size := Vector2(32, 48) * (0.75 + 0.25 * (i % 2))
			c.draw_texture_rect_region(FX_FLAME, Rect2(car + offset - Vector2(size.x * 0.5, size.y - 4.0), size), Rect2(frame * 96, 0, 96, 144))
	for blast in explosions:
		var age: float = 1.0 - blast.t / float(blast.get("d", 0.65))
		var side: float = 96.0 * float(blast.get("s", 1.0))
		var area := Rect2(blast.p - Vector2(side, side) * 0.5, Vector2(side * (-1.0 if blast.get("flip", false) else 1.0), side))
		c.draw_texture_rect_region(FX_EXPLOSION, area, Rect2(mini(9, int(age * 10.0)) * 288, 0, 288, 288))
	for bit in debris:
		c.draw_set_transform(bit.p + Vector2(sin(fx_clock * 57) * shake, cos(fx_clock * 43) * shake * 0.6), bit.a)
		if int(bit.get("k", -1)) >= 0:
			c.draw_texture_rect_region(FX_CHUNKS, Rect2(-5.33, -5.33, 10.67, 10.67), Rect2(int(bit.k) * 32, 0, 32, 32), Color(1, 1, 1, minf(1.0, bit.t * 4.0)))
		else:
			c.draw_rect(Rect2(-2, -1, 4, 2), Color(bit.c, minf(1.0, bit.t * 3.0)))
	c.draw_set_transform(Vector2.ZERO)
	for flash in flashes:
		var point: Vector2 = flash.p
		if flash.get("source","")=="pursuer":
			point = CarArt.muzzle(car_position(),car_frame())
			PixelFX.packet(c,point,Vector2.UP,0.09-flash.t,false,true,clampf(flash.t/0.09,0,1))
			continue
		elif flash.get("source","")=="cargo": point = DroneArt.release_point(flash.drone.p,Vector2(50,50),flash.drone.spin)
		c.draw_rect(Rect2(point - Vector2(3, 3) - Vector2.ONE * flash.t * 24.0, Vector2(6, 6) + Vector2.ONE * flash.t * 48.0), Color(1.0, 0.83, 0.52, flash.t * 9.0))
	if stage_shift >= 0.0:
		# Einfahrt in die nächste Etappe: das Bild taucht kurz ins Dunkel.
		var dark := 1.0 - absf(stage_shift / STAGE_SHIFT_SECONDS * 2.0 - 1.0)
		c.draw_rect(Rect2(-20, -20, 680, 400), Color(0.01, 0.01, 0.03, clampf((dark - 0.55) * 3.2, 0.0, 0.96)))
	if white_flash > 0.0:
		c.draw_rect(Rect2(-20, -20, 680, 400), Color(1.0, 0.95, 0.85, minf(0.75, white_flash * 3.0)))


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
			if flight or (armour<=0 and health>0):completed.emit()
			else:crashed.emit()
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
		if _crew("attack"):
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
	if flight and elapsed >= 9.0 and elapsed < 15.0 and _crew("hack") and not transponder_sent and engine_repaired:
		transponder_sent = true
		world.sound("hack")
	if not flight:
		if _crew("hack") and hack_cooldown == 0:
			if absf(x - boss_x) < 35.0:
				hack = 3.3
				hack_cooldown = 7.0
				world.sound("hack")
			else:
				world.toast("Für den Hack auf die Spur des Wagens wechseln.")
		if _crew("attack", true) and shot_cooldown == 0:
			bullets.append(Vector2(x, BIKE_Y + 14.0))
			shot_cooldown = 0.23
			_sound("shot")
			flashes.append({"p": Vector2(x, BIKE_Y + 14), "t": 0.09})
			velocity_x -= 8.0
		if _crew("dash") and grenade_cooldown == 0:
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
				_fire_pursuer()
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
	_advance_rear_shots(delta,BIKE_Y)
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
		victory_left = 3.0
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
	# v0.58.1 · ClaudeHelper: In der Stadt wechseln drei Straßenzüge, Tunnel und Hochstraße
	# kacheln mit sich selbst. Welche Kachel wo liegt, hängt nur an der gefahrenen Strecke.
	var tile := int(floor(scroll / 360.0))
	var shift: = fposmod(scroll, 360.0)
	draw_texture_rect(_road_art(tile + 1), Rect2(0, shift - 360.0, 640, 360), false)
	draw_texture_rect(_road_art(tile), Rect2(0, shift, 640, 360), false)
	if stage == 1:
		return                      # im Tunnel regnet es nicht
	var slant := -2.0 - wind * wind_dir * 9.0 if stage == 2 else -2.0
	for i in 44:
		var rain: = Vector2(i * 157 % 640, fposmod(i * 37 + elapsed * 335, 360))
		draw_line(rain, rain + Vector2(slant, 8), Color(0.67, 0.71, 0.9, 0.18))

func _road_art(tile: int) -> Texture2D:
	match stage:
		1: return Painted.ART.tunnel
		2: return Painted.ART.skyway
	return [Painted.ART.highway, Painted.ART.highway_b, Painted.ART.highway, Painted.ART.highway_c][posmod(tile, 4)]

## Fußgängerbrücke über der Stadtstraße: zieht mit der Fahrbahn durchs Bild, Fahrzeuge fahren
## darunter hindurch.
const OVERPASS_SIZE := Vector2(640.0, 139.0)
func _advance_overpass(delta: float) -> void:
	if overpass_y < 400.0:
		overpass_y += ROAD_SPEED * speed * delta
	elif stage == 0 and stage_shift < 0.0 and victory_left < 0.0 and elapsed >= next_overpass:
		overpass_y = -OVERPASS_SIZE.y - 20.0
		next_overpass = elapsed + rng.randf_range(13.0, 19.0)
		next_hazard = maxf(next_hazard, elapsed + 0.7)      # nichts Neues im Sichtschatten
	if is_instance_valid(over_layer):
		over_layer.queue_redraw()

func _draw_overpass() -> void:
	if overpass_y >= 400.0:
		return
	var offset := Vector2(sin(fx_clock * 57) * shake, cos(fx_clock * 43) * shake * 0.6)
	over_layer.draw_rect(Rect2(Vector2(48, overpass_y + 16.0) + offset, Vector2(544, OVERPASS_SIZE.y - 14.0)), Color(0, 0, 0, 0.34))
	over_layer.draw_texture_rect(Painted.ART.overpass, Rect2(Vector2(0, overpass_y) + offset, OVERPASS_SIZE), false)

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

## v0.55.0 · ClaudeHelper: Im Koop fährt Spieler 2 als Raven mit – Hack, Schuss, Granate und
## das Wartungsdeck reagieren auch auf seine Tasten (U / O / rechte Umschalttaste bzw. zweites Pad).
func _crew(action: String, held: bool = false) -> bool:
	var names: Array[String] = [action]
	if world != null and world.get("coop") == true: names.append("raven_" + action)
	for name in names:
		if InputMap.has_action(name) and (Input.is_action_pressed(name) if held else Input.is_action_just_pressed(name)):
			return true
	return false

func _axis(negative: String, positive: String) -> float:
	if not InputMap.has_action(negative) or not InputMap.has_action(positive):
		return 0.0
	return Input.get_axis(negative, positive)

func _callout(text: String) -> void:
	callout = text
	callout_time = 1.3

func _process_bike(delta: float) -> void:
	if failure_left>=0:
		failure_left-=delta
		scroll+=ROAD_SPEED*0.25*delta
		queue_redraw()
		if failure_left<=0:
			active=false
			crashed.emit()
		return

	callout_time = maxf(0.0, callout_time - delta)
	if victory_left >= 0.0:
		victory_left -= delta
		throttle = 1.0
		steer_axis = 0.0
		_steer(delta)
		speed = 1.35
		scroll += ROAD_SPEED * speed * delta
		_advance_car_wreck(delta)
		for i in range(hazards.size() - 1, -1, -1):
			hazards[i].y += ROAD_SPEED * speed * delta
			if hazards[i].y > 380: hazards.remove_at(i)
		queue_redraw()
		if victory_left <= 0.0:
			active = false
			if flight or (armour<=0 and health>0):completed.emit()
			else:crashed.emit()
		return
	if stage_shift >= 0.0:
		_advance_stage_shift(delta)
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
	# Im Tunnel fliegen keine Drohnen; über der Hochstraße kommen sie von Anfang an zu zweit.
	var swarm := stage == 2 or armour < 50
	if stage != 1 and elapsed >= next_drone and drones.size() < (2 if swarm else 1):
		drones.append({"p": Vector2(rng.randf_range(240.0, 400.0), -40.0), "state": "in", "t": 0.0, "drops": 0, "spin": 0.0})
		next_drone = elapsed + (4.6 if swarm else 7.0)
		_callout("DROHNE ÜBER DER STRASSE")
	_crosswind(delta)
	_advance_bike_world(delta)
	queue_redraw()
	if health <= 0:
		failure_left=1.4
		impact(Vector2(x,bike_y),true)
		world.toast("MOTORRAD AUSGEFALLEN · Kontrollpunkt wird neu geladen")
	elif armour <= 0:
		if stage < stages - 1: _stage_cleared()
		else: _destroy_car()

## Etappenwechsel: Der abgehängte Wagen fällt zurück, die Kulisse wechselt im Dunkel einer
## Einfahrt, dann schließt der nächste Verfolger von hinten auf.
func _stage_cleared() -> void:
	stage_shift = 0.0
	stage_swapped = false
	ram_warning = 0.0
	ram_recovery = 0.0
	hack = 0.0
	wind = 0.0
	for drone: Dictionary in drones:
		impact(drone.p, true, Color("ffba68"), 0.7)
	for item: Dictionary in objects:
		if item.k == "mine": impact(item.p, true, Color("ffba68"), 0.6)
	drones.clear()
	objects.clear()
	rear_shots.clear()
	rear_shot_vx.clear()
	impact(Vector2(boss_x, car_y - 10), true, Color("ffba68"), 1.2)
	chunks(Vector2(boss_x, car_y), [6, 7, 8, 9], 10, 1.1, Vector2(0, 70))
	_callout("VERFOLGER ABGEHÄNGT")
	world.toast(["RAVEN: Einer weniger – aber da kommt schon der nächste. In den Tunnel!", "RAVEN: Raus auf die Hochstraße! Achte auf den Wind – und auf die Drohnen."][stage])

func _advance_stage_shift(delta: float) -> void:
	stage_shift += delta
	throttle = 0.0
	steer_axis = _axis("move_left", "move_right")
	_steer(delta)
	speed = 1.3
	scroll += ROAD_SPEED * speed * delta
	hurt = maxf(0.0, hurt - delta)
	for i in range(hazards.size() - 1, -1, -1):
		hazards[i].y += ROAD_SPEED * speed * delta
		if hazards[i].y > 380: hazards.remove_at(i)
	if not stage_swapped:
		# Der getroffene Wagen qualmt und verliert den Anschluss.
		car_y += 150.0 * delta
		boss_x = clampf(boss_x + sin(stage_shift * 17.0) * 70.0 * delta, ROAD.x + 10.0, ROAD.y - 10.0)
		if int(stage_shift * 20.0) % 3 == 0: _smoke(Vector2(boss_x, minf(car_y, 372.0)))
		if stage_shift >= STAGE_SHIFT_SECONDS * 0.5:
			stage_swapped = true
			stage += 1
			armour = STAGE_ARMOUR[stage]
			health = minf(100.0, health + 25.0)
			hazards.clear()
			car_y = 452.0
			boss_lane = 1
			boss_x = LANES[1]
			boss_velocity = 0.0
			next_hazard = elapsed + 1.6
			stage_start = elapsed
			next_drone = elapsed + 3.0
			next_wind = elapsed + 4.0
			_callout("ETAPPE %d · %s" % [stage + 1, STAGE_NAMES[stage]])
			_sound("engine_restart")
			stage_changed.emit(stage)
	else:
		car_y = move_toward(car_y, clampf(bike_y + 86.0, 250.0, 332.0), 120.0 * delta)
	queue_redraw()
	if stage_shift >= STAGE_SHIFT_SECONDS:
		stage_shift = -1.0
		world.toast(["", "RAVEN: Der Neue hat dickere Reifen als Verstand. Mach ihn fertig!", "RAVEN: Letzter Wagen. Danach ist der Weg zur Garage frei!"][stage])

## Hochstraße: Böen drücken das Motorrad zur Seite.
func _crosswind(delta: float) -> void:
	if stage != 2:
		return
	if wind > 0.0:
		wind = maxf(0.0, wind - delta)
		x = clampf(x + wind_dir * 46.0 * minf(1.0, wind * 2.0) * delta, ROAD.x, ROAD.y)
	elif elapsed >= next_wind:
		wind = 1.5
		wind_dir = 1.0 if rng.randf() < 0.5 else -1.0
		next_wind = elapsed + rng.randf_range(5.5, 8.0)
		_callout("SEITENWIND %s" % ("→" if wind_dir > 0.0 else "←"))

## v0.56.0 · ClaudeHelper (Nutzerbericht): Der besiegte Wagen fuhr einfach weiter. Jetzt fängt er
## Feuer, schlingert, explodiert und bleibt als brennendes Wrack hinter dem Motorrad zurück.
func _destroy_car() -> void:
	victory_left = VICTORY_SECONDS
	car_y = car_position().y
	ram_warning = 0.0
	ram_recovery = 0.0
	hack = 0.0
	car_dead = 0.0
	car_rot = 0.0
	car_spin = 0.0
	car_fall = 0.0
	car_drift = (1.0 if boss_x < 320.0 else -1.0) * 34.0
	car_next_blast = 0.22
	for drone: Dictionary in drones:
		impact(drone.p, true, Color("ffba68"), 0.7)
	for item: Dictionary in objects:
		if item.k == "mine": impact(item.p, true, Color("ffba68"), 0.6)
	drones.clear()
	objects.clear()
	rear_shots.clear()
	rear_shot_vx.clear()
	impact(Vector2(boss_x, car_y - 12), true)
	chunks(Vector2(boss_x, car_y), [6, 7, 8, 9], 8, 1.0, Vector2(0, 60))
	_callout("VOLLTREFFER!")
	world.toast("RAVEN: Der Wagen brennt – gleich fliegt er auseinander!")

func _advance_car_wreck(delta: float) -> void:
	if car_dead < 0.0:
		return
	var before := car_dead
	car_dead += delta
	if car_dead < CAR_BLAST_AT:
		# Brennend und führerlos: schlingert, kleine Folgeexplosionen laufen über die Karosserie.
		boss_x = clampf(boss_x + (car_drift + sin(car_dead * 19.0) * 60.0) * delta, ROAD.x + 10.0, ROAD.y - 10.0)
		car_rot = sin(car_dead * 13.0) * 0.12
		if car_dead >= car_next_blast:
			car_next_blast += 0.24
			impact(Vector2(boss_x, car_y) + Vector2(rng.randf_range(-18, 18), rng.randf_range(-26, 22)), true, Color("ffba68"), 0.6)
		return
	if before < CAR_BLAST_AT:
		# Tank und Munition gehen hoch.
		var at := Vector2(boss_x, car_y)
		impact(at, true, Color("ffe9a8"), 2.1)
		impact(at + Vector2(-22, -18), true, Color("ffba68"), 1.2)
		impact(at + Vector2(20, 12), true, Color("ffba68"), 1.3)
		chunks(at, [6, 7, 8, 9], 26, 1.6)
		white_flash = 0.3
		shake = 10.0
		car_spin = (1.0 if car_drift > 0.0 else -1.0) * 5.5
		world.sound("prop_metal")
		_callout("WEG FREI · ZUR GARAGE")
		world.toast("RAVEN: Verfolger ausgeschaltet! Weiter zur Garage!")
	# Das Wrack dreht sich aus, verliert Fahrt und fällt hinter dem Motorrad aus dem Bild.
	car_spin *= exp(-delta * 2.4)
	car_rot += car_spin * delta
	car_fall = minf(ROAD_SPEED * speed, car_fall + 62.0 * delta)
	car_y += (12.0 + car_fall) * delta
	boss_x = clampf(boss_x + car_drift * 0.5 * exp(-(car_dead - CAR_BLAST_AT) * 2.0) * delta, ROAD.x, ROAD.y)

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
	if _crew("hack") and hack_cooldown == 0:
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
	if _crew("attack", true) and shot_cooldown == 0:
		bullets.append(Vector2(x, bike_y + 14.0))
		shot_cooldown = 0.2
		_sound("shot")
		flashes.append({"p": Vector2(x, bike_y + 14), "t": 0.09})
		velocity_x -= 8.0
	if _crew("dash") and grenade_cooldown == 0:
		grenade = Vector2(x, bike_y + 18.0)
		grenade_cooldown = 3.4

# v0.41.0 · CodexAI. Rendering and emitted shots use the same actual muzzle.
func car_position() -> Vector2:
	return Vector2(boss_x,car_y-(1-ram_warning/0.85)*minf(42,maxf(0,car_y-bike_y-40)) if ram_warning>0 else car_y-ram_recovery*40)

func car_frame() -> int:
	return CarArt.frame_for(boss_velocity,car_recoil,ram_warning,ram_recovery,fx_clock)

func _append_rear_shot(point: Vector2,spread: float = 0.0):
	# Existing QA callers may append ordinary shots directly; default them to straight.
	if rear_shot_vx.size()>rear_shots.size(): rear_shot_vx.resize(rear_shots.size())
	while rear_shot_vx.size()<rear_shots.size(): rear_shot_vx.append(0.0)
	rear_shots.append(point)
	rear_shot_vx.append(spread)

func _fire_pursuer():
	car_recoil = 0.28
	var point := CarArt.muzzle(car_position(),car_frame())
	_append_rear_shot(point)
	if armour<50:
		# Both rounds leave the barrel; retain the former 16px spread at the bike's depth.
		_append_rear_shot(point,16.0/maxf(0.1,(point.y-bike_y)/350.0))
	flashes.append({"p": point,"t": 0.09,"source": "pursuer"})
	_sound("shot")

func _advance_rear_shots(delta: float,target_y: float):
	for i in range(rear_shots.size()-1,-1,-1):
		rear_shots[i] += Vector2(rear_shot_vx[i] if i<rear_shot_vx.size() else 0.0,-350)*delta
		if rear_shots[i].y<=target_y:
			if absf(rear_shots[i].x-x)<24: _hit(18)
			rear_shots.remove_at(i)
			if i<rear_shot_vx.size(): rear_shot_vx.remove_at(i)

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
	# Jede Etappe beginnt wieder locker und zieht dann an; im Tunnel stehen die Hindernisse dichter.
	next_hazard = elapsed + maxf(0.7, 1.35 - (elapsed - stage_start) * 0.012) * (0.85 if stage == 1 else 1.0)
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
			_fire_pursuer()
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
	_advance_rear_shots(delta,bike_y)
	for i in range(hazards.size() - 1, -1, -1):
		var before: = hazards[i].y
		hazards[i].y += road
		if before < bike_y and hazards[i].y >= bike_y and absf(hazards[i].x - x) < 30:
			_hit(24)
			impact(hazards[i], true)
			hazards.remove_at(i)
			continue
		# v0.56.0 · ClaudeHelper: Der Wagen bremst für nichts – Baken zerbersten an seinem Bug.
		if before < car_y - 34.0 and hazards[i].y >= car_y - 34.0 and absf(hazards[i].x - boss_x) < 50.0:
			car_smash(hazards[i], "barrier")
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
				if absf(item.p.x - boss_x) < 46.0 and absf(item.p.y - (car_y - 30.0)) < 14.0:
					car_smash(item.p, "wreck")
					armour -= 6
					_callout("WAGEN RAMMT WRACK")
					objects.remove_at(i)
					continue
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
					var release := DroneArt.release_point(drone.p,Vector2(50,50))
					objects.append({"k": "mine", "p": release, "done": false, "r": 0.0})
					flashes.append({"p": release,"t": 0.08,"source": "cargo","drone": drone})
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
	var car := car_position()
	if car_dead >= CAR_BLAST_AT:
		if car.y < 440.0:
			draw_set_transform(car, car_rot)
			draw_texture_rect_region(CAR_WRECK, Rect2(-CarArt.ANCHORS[0] * CarArt.SCALE, CarArt.SIZE), Rect2(Vector2.ZERO, CarArt.CELL))
			draw_set_transform(Vector2.ZERO)
	elif car_dead >= 0.0:
		draw_set_transform(car, car_rot)
		draw_texture_rect_region(CarArt.ATLAS, Rect2(-CarArt.ANCHORS[0] * CarArt.SCALE, CarArt.SIZE), CarArt.region(0), Color(1.0, 0.72, 0.6).lerp(Color(0.5, 0.42, 0.42), car_dead / CAR_BLAST_AT))
		draw_set_transform(Vector2.ZERO)
	else:
		CarArt.draw(self,car,car_frame())
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
	var lean := clampf(velocity_x/250.0,-1,1)
	var braking := throttle < -0.35
	var outlets := BikeArt.exhaust(lean,braking,fx_clock)
	if boost > 0.0:
		for i in 2:
			var outlet: Vector2 = bike+outlets[i]
			var flame := 14.0 + sin(fx_clock * 40.0 + i) * 4.0
			draw_line(outlet, outlet+Vector2(0,flame), Color(0.3, 0.9, 1.0, 0.55), 6.0, true)
			draw_line(outlet, outlet+Vector2(0,flame*0.6), Color("e9fdff"), 2.0, true)
	BikeArt.draw(self,bike,lean,braking,fx_clock)
	if slick > 0.0:
		draw_arc(bike, 28.0, fx_clock * 6.0, fx_clock * 6.0 + 2.2, 16, Color("c17bff"), 2.0)
	for drone: Dictionary in drones:
		var height := 40.0 if drone.state != "hacked" else maxf(4.0, 40.0 - drone.t * 60.0)
		draw_set_transform(drone.p + Vector2(10, height), 0.0, Vector2(1.0, 0.45))
		draw_circle(Vector2.ZERO, 18.0, Color(0, 0, 0, 0.35))
		draw_set_transform(Vector2.ZERO)
		DroneArt.draw(self,drone.p,Vector2(50,50),fx_clock,drone.spin)
		if drone.state == "hacked":
			draw_arc(drone.p, 24, fx_clock * 5, fx_clock * 5 + 4, 24, cyan, 2)
		elif drone.state == "hover" and drone.t > 1.0:
			draw_arc(drone.p + Vector2(0, 22), 7.0, 0, TAU, 12, Color(pink, 0.8), 2.0)
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
