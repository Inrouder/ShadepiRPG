extends Node2D
## Kapitel 6 · Anflug auf Kenzōs Tower im ramponierten Aerodyne (nach der Romanfassung).
## Phasen: Stadtschluchten (Ausweichen, Rolle, Schub/Bremse) → Triebwerksausfall mit
## Ravens Jumper-Reparatur → Turmabwehr (Laser-Drohnen) → Sequenzkalibrierung am
## Tower-Scanner → Driftkurve → Landung auf dem Landeplatz (Bremsdüsen, Ausrichten).

const VEHICLES = preload("res://assets/world/hq/vehicles.png")
const DroneArt = preload("res://scripts/cargo_drone_art.gd")
const Airframe = preload("res://scripts/aerodyne_art.gd")
const PROPS = preload("res://assets/world/hq/flight-props.png")
const Painted = preload("res://scripts/painted_world.gd")
const Calibration = preload("res://scripts/sequence_calibration.gd")
const UiSkin = preload("res://scripts/ui_skin.gd")

signal completed
signal crashed

const REPAIR_SECONDS := 45.0
const X_RANGE := Vector2(176.0, 464.0)
const Y_RANGE := Vector2(196.0, 300.0)
const FAILURE_AT := 6.0
const DEFENCE_AT := 23.0
const SCAN_AT := 30.0
const SCROLL := 185.0
const ROLL_TIME := 0.5
const ROLL_COOLDOWN := 1.05
const HALF_WIDTH := 28.0
const ROLL_HALF_WIDTH := 9.0
## Beam path of the tower scanner on screen during the calibration.
const BEAM_RANGE := Vector2(46.0, 252.0)
## ROOF camera of the following scene (centre, zoom): the landing view matches it.
const ROOF_CAMERA := Vector2(330, 300)
const ROOF_ZOOM := 1.1
## Where the Aerodyne stands on the tower landing pad (world coordinates of the roof).
const PAD_WORLD := Vector2(222, 326)
## Landing ring of ARTOS' assist (the painted H circle is larger).
const PAD_RADIUS := Vector2(64, 34)

## Compatibility with the shared vehicle HUD and checkpoint code.
var flight := true
var world: Node2D
var active := true
var phase := "canyon"   # canyon | defence | scan | alarm | approach | landing | done
var elapsed := 0.0      # course progress in seconds at normal speed
var clock := 0.0
var health := 100
var pos := Vector2(320, 262)
var vel := Vector2.ZERO
var speed := 1.0
var scroll := 0.0
var hurt := 0.0
var shake := 0.0

var engine_failed := false
var engine_repaired := false
var repair_left := REPAIR_SECONDS
var restart_flash := 0.0
var transponder_sent := false

var roll := 0.0
var roll_dir := 1.0
var roll_cooldown := 0.0
var edge_contact := 0.0
var streak := 0
var near_misses := 0
var callout := ""
var callout_time := 0.0

## {"k": "cargo"|"bridge", "p": Vector2, "vx": float, "gap": float, "w": float, "near": bool}
var hazards: Array[Dictionary] = []
## Kenzō's tower guards: {"p": Vector2, "home": Vector2, "cool": float, "leave": bool}
var sentries: Array[Dictionary] = []
## {"x": float, "warn": float, "fire": float, "src": Vector2, "hit": bool}
var lasers: Array[Dictionary] = []
var next_spawn := 1.2
var pattern := 0

var calibration: RefCounted
var scan_attempts := 0
var alarm_left := 0.0
var approach_left := 0.0
var drift_window := 0.0
var drifted := false
var tick_clock := 0.0
## Short grace after the scanner locks on, so held steering is not read as code input.
var scan_grace := 0.0

## Landing: altitude 1 → 0, descent speed in altitude units per second.
var altitude := 1.0
var descent := 0.0
var shadow := Vector2.ZERO
var brake_held := false
var touchdown := ""
var victory_left := -1.0
var go_arounds := 0

var debris: Array[Dictionary] = []
var flashes: Array[Dictionary] = []
var rng := RandomNumberGenerator.new()

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	rng.seed = 6106

func _sound(key: String) -> void:
	if world != null and world.has_method("sound"):
		world.sound(key)

func _axis(negative: String, positive: String) -> float:
	if not InputMap.has_action(negative) or not InputMap.has_action(positive):
		return 0.0
	return Input.get_axis(negative, positive)

func _pressed(action: String) -> bool:
	return InputMap.has_action(action) and Input.is_action_just_pressed(action)

func _held(action: String) -> bool:
	return InputMap.has_action(action) and Input.is_action_pressed(action)

func say(text: String, seconds: float = 1.4) -> void:
	callout = text
	callout_time = seconds

# --- Triebwerksausfall (Ravens Wartungsdeck) -------------------------------------

func start_engine_failure() -> void:
	if engine_failed or engine_repaired:
		return
	engine_failed = true
	repair_left = REPAIR_SECONDS
	shake = 4.0
	vel.x += 95.0
	_sound("drive_engine_fail")
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
		_sound("drive_engine_restart")
		_burst(pos + Vector2(19, 29), Color("75edff"), 8)
		world.toast("RAVEN: Brücken geprüft. – ARTOS: Schub wiederhergestellt.")
	)

# --- Hauptschleife -----------------------------------------------------------------

func _process(delta: float) -> void:
	if not active or world.is_busy():
		return
	clock += delta
	_update_fx(delta)
	if victory_left >= 0.0:
		victory_left -= delta
		queue_redraw()
		if victory_left <= 0.0:
			active = false
			completed.emit()
		return
	if phase == "landing":
		_process_landing(delta)
		queue_redraw()
		return
	hurt = maxf(0.0, hurt - delta)
	roll = maxf(0.0, roll - delta)
	roll_cooldown = maxf(0.0, roll_cooldown - delta)
	callout_time = maxf(0.0, callout_time - delta)
	if engine_failed:
		repair_left = maxf(0.0, repair_left - delta)
		if _pressed("attack"):
			request_repair()
			if world.is_busy():
				return
		if repair_left <= 0.0:
			_crash()
			return
	elif not engine_repaired and elapsed >= FAILURE_AT:
		start_engine_failure()
		return
	var steering := phase != "scan"
	if phase == "scan":
		_process_scan(delta)
	else:
		_controls(delta)
	_move(delta, steering)
	if not engine_failed:
		elapsed += delta * speed
	scroll += SCROLL * speed * delta
	_phase_logic(delta)
	_spawn()
	_advance_hazards(delta)
	_advance_sentries(delta)
	if health <= 0:
		_crash()
	queue_redraw()

func _crash() -> void:
	if not active:
		return
	active = false
	crashed.emit()

func _controls(delta: float) -> void:
	# Ausweichrolle: kurzer Seitensprung, schmales Profil, kurz unverwundbar.
	if _pressed("dash") and roll_cooldown <= 0.0 and not engine_failed:
		var axis := _axis("move_left", "move_right")
		roll_dir = signf(axis) if absf(axis) > 0.2 else (1.0 if pos.x < 320.0 else -1.0)
		roll = ROLL_TIME
		roll_cooldown = ROLL_COOLDOWN
		vel.x += roll_dir * 330.0
		_sound("drive_roll")
		if phase == "approach" and drift_window > 0.0:
			drifted = true
			drift_window = 0.0
			say("KONTROLLIERTER DRIFT!", 1.6)
	var throttle := -_axis("move_up", "move_down")
	speed = move_toward(speed, 1.0 + throttle * (0.35 if throttle > 0.0 else 0.25), delta * 2.2)

func _move(delta: float, steering: bool) -> void:
	var remaining := delta
	while remaining > 0.00001:
		var step := minf(remaining, 1.0 / 120.0)
		var axis := _axis("move_left", "move_right") if steering else 0.0
		var target_x := axis * 300.0
		var target_y := Y_RANGE.y - (speed - 0.75) / 0.6 * (Y_RANGE.y - Y_RANGE.x)
		if phase == "scan" and calibration != null:
			# ARTOS hält Kurs: the hull rides into the scanner window.
			var w: Vector2 = calibration.window()
			target_y = lerpf(BEAM_RANGE.x, BEAM_RANGE.y, (w.x + w.y) * 0.5)
			target_x = (320.0 - pos.x) * 3.0
		elif phase == "approach":
			target_y = 230.0
		if engine_failed:
			target_x += 260.0
		vel.x += (target_x - vel.x) * (6.0 if roll <= 0.0 else 1.2) * step
		vel.y = (target_y - pos.y) * 3.0
		pos += vel * step
		remaining -= step
	if pos.x < X_RANGE.x or pos.x > X_RANGE.y:
		pos.x = clampf(pos.x, X_RANGE.x, X_RANGE.y)
		vel.x *= -0.4
		edge_contact -= delta
		if edge_contact <= 0.0:
			edge_contact = 0.45
			_hit(5, "FASSADE!")
			_burst(Vector2(pos.x + (-22 if pos.x < 320 else 22), pos.y), Color("ffc06a"), 6)
	pos.y = clampf(pos.y, BEAM_RANGE.x + 20.0, Y_RANGE.y + 10.0)

func _phase_logic(delta: float) -> void:
	match phase:
		"canyon":
			if elapsed >= DEFENCE_AT:
				phase = "defence"
				_call_sentries(2)
				world.toast("RAVEN: Turmabwehr! Laser-Drohnen – die roten Linien zeigen, wo sie feuern.")
		"defence":
			if elapsed >= SCAN_AT:
				_start_scan()
		"alarm":
			alarm_left -= delta
			if alarm_left <= 0.0:
				_start_scan()
		"approach":
			approach_left -= delta
			if approach_left <= 2.2 and approach_left + delta > 2.2:
				drift_window = 1.1
				say("DRIFTKURVE · LEERTASTE / B", 1.1)
			drift_window = maxf(0.0, drift_window - delta)
			if approach_left <= 0.0:
				_start_landing()

func _call_sentries(count: int) -> void:
	for i in count:
		if sentries.size() >= 3:
			break
		var home := Vector2(232.0 + 88.0 * sentries.size(), 46.0 + 8.0 * (sentries.size() % 2))
		sentries.append({"p": home + Vector2(0, -80), "home": home, "cool": 0.8 + 0.6 * i, "leave": false})

# --- Hindernisse in den Stadtschluchten -------------------------------------------

func _spawn() -> void:
	if engine_failed or phase in ["scan", "approach"] or elapsed < next_spawn:
		return
	next_spawn = elapsed + (1.25 if phase == "canyon" else 1.6)
	pattern += 1
	if phase == "canyon" and pattern % 4 == 0 and elapsed > 8.0:
		var narrow: bool = elapsed > 14.0 and pattern % 8 == 0
		var w := 50.0 if narrow else 122.0
		var gap := rng.randf_range(X_RANGE.x + w * 0.5 + 8.0, X_RANGE.y - w * 0.5 - 8.0)
		hazards.append({"k": "bridge", "p": Vector2(0, -20), "gap": gap, "w": w, "near": false, "narrow": narrow})
		if narrow:
			say("ENGE LÜCKE · ROLLEN!", 1.2)
		return
	for i in (2 if elapsed > 12.0 and pattern % 3 == 0 else 1):
		var x := rng.randf_range(X_RANGE.x + 12.0, X_RANGE.y - 12.0)
		hazards.append({"k": "cargo", "p": Vector2(x, -24.0 - i * 46.0), "vx": rng.randf_range(-28.0, 28.0), "near": false})

func _half_width() -> float:
	return ROLL_HALF_WIDTH if roll > 0.0 else HALF_WIDTH

func _advance_hazards(delta: float) -> void:
	for i in range(hazards.size() - 1, -1, -1):
		var h: Dictionary = hazards[i]
		var before: float = h.p.y
		h.p.y += SCROLL * speed * delta * (1.15 if h.k == "cargo" else 1.0)
		if h.k == "cargo":
			h.p.x = clampf(h.p.x + h.vx * delta, X_RANGE.x, X_RANGE.y)
			if absf(h.p.y - pos.y) < 22.0:
				var dx := absf(h.p.x - pos.x)
				if dx < _half_width() + 12.0:
					if roll <= 0.0:
						_hit(12, "KOLLISION!")
						_burst(h.p, Color("ffba68"), 14)
						hazards.remove_at(i)
						continue
				elif dx < _half_width() + 38.0 and not h.near:
					h.near = true
					_near_miss()
		elif before < pos.y - 4.0 and h.p.y >= pos.y - 4.0:
			var off := absf(pos.x - h.gap)
			var free: float = h.w * 0.5 - _half_width()
			if off > free:
				_hit(18, "STREBE GETROFFEN!")
				_burst(Vector2(pos.x, h.p.y), Color("ffba68"), 16)
			elif off > free - 14.0 or (h.narrow and roll > 0.0):
				_near_miss()
		if h.p.y > 400.0:
			hazards.remove_at(i)

func _near_miss() -> void:
	near_misses += 1
	streak += 1
	health = mini(100, health + 2)
	_sound("drive_near_miss")
	say("KNAPP! · STUNT x%d" % streak, 0.9)

func _hit(amount: int, text: String) -> void:
	if world.admin_enabled("god_mode") or hurt > 0.0:
		return
	health -= amount
	hurt = 0.7
	shake = 3.5
	streak = 0
	vel.x += -110.0 if pos.x > 320.0 else 110.0
	_sound("hit")
	say(text, 0.8)

# --- Turmabwehr ---------------------------------------------------------------------

func _advance_sentries(delta: float) -> void:
	var hostile := phase in ["defence", "alarm"]
	for i in range(sentries.size() - 1, -1, -1):
		var s: Dictionary = sentries[i]
		var target: Vector2 = s.home + Vector2(sin(clock * 1.3 + i * 2.0) * 34.0, 0)
		if s.leave:
			target = s.home + Vector2(0, -140)
		s.p = s.p.lerp(target, minf(1.0, delta * 2.4))
		if s.leave and s.p.y < -60.0:
			sentries.remove_at(i)
			continue
		if hostile and not engine_failed:
			s.cool -= delta
			if s.cool <= 0.0:
				s.cool = 2.1 if phase == "defence" else 1.4
				# Aim at the Aerodyne, with a slight lead in its drift direction.
				var aim := clampf(pos.x + vel.x * 0.25, X_RANGE.x, X_RANGE.y)
				lasers.append({"x": aim, "warn": 0.85, "fire": 0.3, "src": s.p + Vector2(0, 12), "hit": false})
				_sound("drive_laser_warn")
	for i in range(lasers.size() - 1, -1, -1):
		var l: Dictionary = lasers[i]
		if l.warn > 0.0:
			l.warn -= delta
			if l.warn <= 0.0:
				_sound("drive_laser")
			continue
		l.fire -= delta
		if not l.hit and absf(pos.x - l.x) < _half_width() + 6.0:
			if roll > 0.0:
				if not l.get("dodged", false):
					l.dodged = true
					_near_miss()
			else:
				l.hit = true
				_hit(15, "LASERTREFFER!")
				_burst(pos + Vector2(0, -6), Color("ff3b4e"), 10)
		if l.fire <= 0.0:
			lasers.remove_at(i)

# --- Sequenzkalibrierung am Tower-Scanner ---------------------------------------

func _start_scan() -> void:
	phase = "scan"
	scan_attempts += 1
	lasers.clear()
	calibration = Calibration.new(4100 + scan_attempts * 17, 5)
	tick_clock = 0.0
	scan_grace = 0.45
	world.toast("RAVEN: Scanner! Richtung drücken, sobald der Strahl auf uns liegt.")

func calibration_input(dir_index: int) -> String:
	if phase != "scan" or calibration == null:
		return ""
	var result: String = calibration.press(dir_index)
	match result:
		"lock": _sound("calib_lock")
		"done": _scan_accepted()
		"wrong", "early": _sound("calib_error"); shake = 1.5
		"failed": _scan_rejected()
	return result

func _process_scan(delta: float) -> void:
	speed = move_toward(speed, 0.9, delta)
	scan_grace = maxf(0.0, scan_grace - delta)
	for i in Calibration.DIRS.size():
		if scan_grace > 0.0:
			break
		if _pressed("move_" + Calibration.DIRS[i]):
			calibration_input(i)
			if phase != "scan":
				return
	var event: String = calibration.tick(delta)
	tick_clock -= delta
	if calibration.in_window() and tick_clock <= 0.0:
		tick_clock = 0.12
		_sound("calib_tick")
	if event == "failed":
		_scan_rejected()

func _scan_accepted() -> void:
	transponder_sent = true
	phase = "approach"
	approach_left = 4.6
	streak = 0
	_sound("calib_accept")
	for s in sentries:
		s.leave = true
	say("KENNUNG AKZEPTIERT", 1.8)
	world.toast("TOWER: Gleiter Moriyama-01 erkannt. Landeplattform frei. – RAVEN: Wir sind drin.")

func _scan_rejected() -> void:
	phase = "alarm"
	alarm_left = 8.0
	_sound("calib_alarm")
	_call_sentries(3)
	for s in sentries:
		s.cool = 0.6
	say("KENNUNG ABGELEHNT · ALARM", 1.8)
	world.toast("RAVEN: Abgelehnt! Weich den Lasern aus – beim nächsten Scannerdurchlauf versuche ich es neu.")

# --- Landung auf dem Tower-Dach ----------------------------------------------------

static func roof_to_screen(point: Vector2) -> Vector2:
	return (point - ROOF_CAMERA) * ROOF_ZOOM + Vector2(320, 180)

static func screen_to_roof(point: Vector2) -> Vector2:
	return (point - Vector2(320, 180)) / ROOF_ZOOM + ROOF_CAMERA

## Where the Aerodyne touched down, in roof world coordinates (for the parked craft).
func touchdown_world() -> Vector2:
	if touchdown == "":
		return PAD_WORLD
	var spot := screen_to_roof(shadow)
	# Keep the hull clear of the pad console and the door path.
	return Vector2(clampf(spot.x, 160.0, 240.0), clampf(spot.y, 300.0, 352.0))

func pad_screen() -> Vector2:
	return roof_to_screen(PAD_WORLD)

func _start_landing() -> void:
	phase = "landing"
	hazards.clear()
	lasers.clear()
	altitude = 1.0
	descent = 0.05
	shadow = pad_screen() + Vector2(190, -40)
	vel = Vector2(-150 if drifted else -110, 18)
	_sound("drive_brake")
	world.toast("SHADEPI: Landeanflug. Schatten in den Ring – J / X hält die Bremsdüsen.")

func _process_landing(delta: float) -> void:
	callout_time = maxf(0.0, callout_time - delta)
	var steer := Vector2(_axis("move_left", "move_right"), _axis("move_up", "move_down"))
	var gust := Vector2(sin(clock * 1.7) * 22.0 + sin(clock * 4.3) * 9.0, cos(clock * 1.1) * 8.0)
	vel = vel.lerp(steer * 95.0 + gust, minf(1.0, delta * 2.0))
	shadow += vel * delta
	shadow.x = clampf(shadow.x, 30.0, 610.0)
	shadow.y = clampf(shadow.y, 150.0, 330.0)
	var was_braking := brake_held
	brake_held = _held("attack")
	if brake_held and not was_braking:
		_sound("drive_brake")
	descent += (0.16 - (0.95 if brake_held else 0.0)) * delta
	descent = clampf(descent, -0.12, 0.9)
	altitude -= descent * delta
	if altitude <= 0.0:
		_touch_down()

func pad_offset() -> float:
	## 0 = centre of the landing ring, 1 = its painted edge.
	var d := (shadow - pad_screen()) / (PAD_RADIUS * ROOF_ZOOM)
	return d.length()

func _touch_down() -> void:
	altitude = 0.0
	if pad_offset() > 1.0:
		go_arounds += 1
		altitude = 0.45
		descent = -0.25
		shake = 2.5
		_sound("drive_knock")
		say("DANEBEN · DURCHSTARTEN!", 1.4)
		return
	shake = 6.0
	_sound("drive_touchdown")
	var cost := 0
	if descent < 0.32:
		touchdown = "präzise"
	elif descent < 0.6:
		touchdown = "hart"
		cost = 6
	else:
		touchdown = "sehr hart"
		cost = 14
	if not world.admin_enabled("god_mode"):
		health = maxi(1, health - cost)
	_burst(shadow, Color("cfe7ff"), 20)
	say("AUFGESETZT · %s" % touchdown.to_upper(), 1.8)
	phase = "done"
	victory_left = 1.6

# --- Effekte ---------------------------------------------------------------------

func _burst(point: Vector2, color: Color, count: int) -> void:
	for i in mini(count, maxi(0, 120 - debris.size())):
		var v := Vector2.from_angle(rng.randf() * TAU) * rng.randf_range(30, 140)
		debris.append({"p": point, "v": v, "t": rng.randf_range(0.3, 0.8), "c": color})

func _update_fx(delta: float) -> void:
	shake = move_toward(shake, 0.0, delta * 9.0)
	restart_flash = maxf(0.0, restart_flash - delta)
	for i in range(debris.size() - 1, -1, -1):
		var bit: Dictionary = debris[i]
		bit.v *= exp(-delta * 1.5)
		bit.p += bit.v * delta
		bit.t -= delta
		if bit.t <= 0.0:
			debris.remove_at(i)
	for i in range(flashes.size() - 1, -1, -1):
		flashes[i].t -= delta
		if flashes[i].t <= 0.0:
			flashes.remove_at(i)

# --- Darstellung -----------------------------------------------------------------

func _draw() -> void:
	_reset_xf()
	if phase == "landing" or touchdown != "":
		_draw_landing()
	else:
		_draw_canyon()
	draw_set_transform(Vector2.ZERO)
	_draw_overlay()

func _draw_canyon() -> void:
	var art: Texture2D = Painted.ART.airspace
	var shift := fposmod(scroll * 0.45, 360.0)
	draw_texture_rect(art, Rect2(0, shift - 360.0, 640, 360), false)
	draw_texture_rect(art, Rect2(0, shift, 640, 360), false)
	# Rain streaks and canyon beacons give speed.
	for i in 36:
		var p := Vector2(float(i * 157 % 640), fposmod(i * 37.0 + scroll * 1.6, 360.0))
		draw_rect(Rect2(p.round(), Vector2(1, 6)), Color(0.67, 0.75, 0.95, 0.22))
	for i in 7:
		var y := fposmod(i * 64.0 + scroll * 0.9, 448.0) - 44.0
		for bx in [168.0, 472.0]:
			draw_rect(Rect2(Vector2(bx - 1, y - 1), Vector2(3, 3)), Color("62e3ee"))
			draw_rect(Rect2(Vector2(bx - 3, y - 3), Vector2(7, 7)), Color(0.38, 0.89, 0.93, 0.18))
	if phase in ["scan", "alarm", "approach"] or elapsed > SCAN_AT - 4.0:
		_draw_scanner()
	for h in hazards:
		if h.k == "bridge":
			_draw_bridge(h)
	for h in hazards:
		if h.k == "cargo":
			_draw_sprite(3, h.p.round(), Vector2(40, 34), sin(clock * 3.0 + h.p.y * 0.05) * 0.1, Color(0.82, 0.86, 0.95))
	for l in lasers:
		_draw_laser(l)
	for s in sentries:
		var frame := int(clock * 18.0) % 2
		draw_texture_rect_region(PROPS, Rect2(s.p.round() - Vector2(20, 16), Vector2(40, 32)), Rect2(frame * 40, 0, 40, 32))
	_draw_aerodyne_top()
	_draw_debris()

func _shake_offset() -> Vector2:
	return Vector2(roundf(sin(clock * 57.0) * shake), roundf(cos(clock * 43.0) * shake * 0.6))

func _reset_xf() -> void:
	draw_set_transform(_shake_offset())

func _draw_sprite(index: int, center: Vector2, size: Vector2, tilt: float, modulate: Color = Color.WHITE) -> void:
	if index==3:
		DroneArt.draw(self,center+_shake_offset(),size,clock,tilt,modulate)
	else:
		var region := Rect2((index%2)*627,(index/2)*627,627,627)
		draw_set_transform(center+_shake_offset(),tilt)
		draw_texture_rect_region(VEHICLES,Rect2(-size*0.5,size),region,modulate)
	_reset_xf()

func visual_bank() -> float:
	if roll>0: return roll_dir*sin((1-roll/ROLL_TIME)*PI)
	return clampf(vel.x/300.0+ (0.2 if engine_failed else 0.0),-1,1)

func _draw_aerodyne_top() -> void:
	var bank := visual_bank()
	var brake := clampf((1-speed)/0.25,0,1) if not engine_failed else 0.0
	var center := pos.round()+_shake_offset()
	# The new view supplies sidewall shading. A small compression reinforces the dodge.
	var squash := 1.0-0.25*sin((1-roll/ROLL_TIME)*PI) if roll>0 else 1.0
	var xf := Transform2D(0.0,Vector2(squash,1),0,center)
	draw_set_transform_matrix(xf)
	var size := Vector2(112,82)
	var paint := Color(1,0.55,0.6) if hurt>0 and int(clock*20)%2==0 else Color.WHITE
	Airframe.draw(self,Rect2(-size*0.5,size),clock,0.25 if engine_failed else 1.0,paint,bank,brake)
	var outlets := Airframe.nozzles(bank,brake)
	# Thrusters (one sputters while the engine is dead).
	for side in [-1, 1]:
		var nozzle: Vector2 = outlets[0 if side==-1 else 1]*size/240.0
		var failing: bool = engine_failed and side == 1
		if failing and sin(clock * 32.0) < 0.8:
			continue
		var length := (5.0 if failing else 12.0 + (speed - 1.0) * 30.0 + restart_flash * 10.0) + sin(clock * 37.0) * 3.0
		draw_rect(Rect2(nozzle + Vector2(-4, 0), Vector2(8, length)), Color(1.0, 0.4, 0.12, 0.35) if failing else Color(0.1, 0.8, 1, 0.35))
		draw_rect(Rect2(nozzle + Vector2(-1, 0), Vector2(3, length * 0.8)), Color("fff1bb") if failing else Color("b8f6ff"))
	_reset_xf()
	if engine_failed:
		var smoke_origin: Vector2 = xf*(outlets[1]*size/240.0)
		for i in 4:
			var puff := smoke_origin+Vector2(i*3,fposmod(clock*60.0+i*11.0,44.0))
			draw_rect(Rect2(puff.round(), Vector2(5, 5)), Color(0.2, 0.24, 0.3, 0.55))
	if phase == "scan" and calibration != null and calibration.in_window():
		_pixel_ring(pos, Vector2(44, 34), Color("62e3ee"))
	if roll > 0.0:
		var trail := pos + Vector2(-roll_dir * 30.0, 0)
		draw_rect(Rect2(trail.round() + Vector2(-1, -16), Vector2(2, 32)), Color(0.38, 0.89, 0.93, roll * 1.4))

func _pixel_ring(center: Vector2, radius: Vector2, color: Color) -> void:
	for i in 48:
		var a := TAU * i / 48.0 + clock * 0.6
		var p := (center + Vector2(cos(a) * radius.x, sin(a) * radius.y)).round()
		draw_rect(Rect2(p - Vector2(1, 1), Vector2(3, 2)), Color(0, 0, 0, color.a * 0.5))
		draw_rect(Rect2(p - Vector2(1, 1), Vector2(2, 2)), color)

func _draw_bridge(h: Dictionary) -> void:
	var y: float = roundf(h.p.y)
	var left_end: float = h.gap - h.w * 0.5
	var right_start: float = h.gap + h.w * 0.5
	for segment in [Vector2(120, left_end), Vector2(right_start, 520)]:
		var x: float = segment.x
		while x < segment.y:
			var w := minf(32.0, segment.y - x)
			draw_texture_rect_region(PROPS, Rect2(x, y - 13, w, 26), Rect2(80, 0, w, 26))
			x += 32.0
	draw_texture_rect_region(PROPS, Rect2(left_end - 10, y - 17, 10, 34), Rect2(112, 0, 10, 34))
	draw_texture_rect_region(PROPS, Rect2(right_start + 10, y - 17, -10, 34), Rect2(112, 0, 10, 34))
	if h.narrow and int(clock * 6.0) % 2 == 0:
		draw_rect(Rect2(left_end, y - 1, h.w, 2), Color(1.0, 0.75, 0.2, 0.5))

func _draw_laser(l: Dictionary) -> void:
	var x: float = roundf(l.x)
	if l.warn > 0.0:
		if int(l.warn * 14.0) % 2 == 0:
			var y: float = l.src.y
			while y < 360.0:
				draw_rect(Rect2(x - 1, y, 2, 4), Color(1.0, 0.23, 0.31, 0.75))
				y += 9.0
		draw_rect(Rect2(l.src.round() - Vector2(3, 0), Vector2(6, 6)), Color("ff3b4e"))
		return
	draw_rect(Rect2(x - 7, l.src.y, 14, 360), Color(1.0, 0.2, 0.3, 0.35))
	draw_rect(Rect2(x - 3, l.src.y, 6, 360), Color("ff3b4e"))
	draw_rect(Rect2(x - 1, l.src.y, 2, 360), Color("ffe0e4"))

func _draw_scanner() -> void:
	var emitter := Vector2(308, 6)
	draw_texture_rect_region(PROPS, Rect2(emitter, Vector2(24, 24)), Rect2(122, 0, 24, 24))
	if phase != "scan" or calibration == null:
		# Idle sweep: show where the tower scanner will reach.
		var idle_y := lerpf(BEAM_RANGE.x, BEAM_RANGE.y, 0.5 + 0.5 * sin(clock * 2.0))
		_draw_beam(idle_y, 0.35)
		return
	var y := lerpf(BEAM_RANGE.x, BEAM_RANGE.y, calibration.marker)
	var w: Vector2 = calibration.window()
	# Window band: where the beam lies on the Aerodyne's hull.
	var band_top := lerpf(BEAM_RANGE.x, BEAM_RANGE.y, w.x)
	var band_bottom := lerpf(BEAM_RANGE.x, BEAM_RANGE.y, w.y)
	draw_rect(Rect2(X_RANGE.x - 8, band_top, X_RANGE.y - X_RANGE.x + 16, band_bottom - band_top), Color(0.38, 0.89, 0.93, 0.08))
	for x in range(int(X_RANGE.x) - 8, int(X_RANGE.y) + 8, 6):
		draw_rect(Rect2(x, band_top, 3, 1), Color(0.38, 0.89, 0.93, 0.5))
		draw_rect(Rect2(x, band_bottom, 3, 1), Color(0.38, 0.89, 0.93, 0.5))
	_draw_beam(y, 1.0)

func _draw_beam(y: float, strength: float) -> void:
	var yy := roundf(y)
	var col := Color(0.38, 0.89, 0.93, 0.18 * strength)
	# Cone from the emitter down to the sweep line.
	for i in 12:
		var t := float(i) / 11.0
		var x := lerpf(X_RANGE.x - 10, X_RANGE.y + 10, t)
		draw_line(Vector2(320, 24), Vector2(x, yy), Color(col, 0.06 * strength))
	draw_rect(Rect2(X_RANGE.x - 12, yy - 3, X_RANGE.y - X_RANGE.x + 24, 7), col)
	draw_rect(Rect2(X_RANGE.x - 12, yy, X_RANGE.y - X_RANGE.x + 24, 1), Color(0.81, 0.99, 1.0, 0.85 * strength))
	for x in range(int(X_RANGE.x) - 12, int(X_RANGE.y) + 12, 4):
		if (x / 4 + int(clock * 20.0)) % 3 == 0:
			draw_rect(Rect2(x, yy - 2, 2, 1), Color(0.38, 0.89, 0.93, 0.7 * strength))

func _draw_debris() -> void:
	for bit in debris:
		draw_rect(Rect2(bit.p.round(), Vector2(2, 2)), Color(bit.c, minf(1.0, bit.t * 3.0)))

## Tower roof seen from the following scene's camera; the Aerodyne descends in 3/4 view.
func _draw_landing() -> void:
	var art: Texture2D = Painted.ART.rooftop
	var scale := Vector2(art.get_width() / 1024.0, art.get_height() / 640.0)
	var half := Vector2(320, 180) / ROOF_ZOOM
	var src := Rect2((ROOF_CAMERA - half) * scale, half * 2.0 * scale)
	draw_texture_rect_region(art, Rect2(0, 0, 640, 360), src)
	for i in 48:
		var p := Vector2(float(i * 131 % 640), fposmod(i * 53.0 + clock * 330.0, 360.0))
		draw_rect(Rect2(p.round(), Vector2(1, 7)), Color(0.7, 0.78, 0.95, 0.25))
	var pad := pad_screen()
	var on_target := pad_offset() <= 1.0
	# Target ring on the pad (ARTOS landing assist).
	var ring_col := Color(0.47, 1.0, 0.66, 0.9) if on_target else Color(1.0, 0.75, 0.25, 0.9)
	_pixel_ring(pad, PAD_RADIUS * ROOF_ZOOM, ring_col)
	# Corner brackets of the landing assist, blinking while out of the ring.
	if on_target or int(clock * 4.0) % 2 == 0:
		var r := PAD_RADIUS * ROOF_ZOOM + Vector2(10, 6)
		for sx in [-1.0, 1.0]:
			for sy in [-1.0, 1.0]:
				var corner := (pad + Vector2(sx * r.x, sy * r.y)).round()
				draw_rect(Rect2(corner - Vector2(4, 1) + Vector2(sx * -4.0 + 4.0, 0) - Vector2(4, 0), Vector2(8, 2)), ring_col)
				draw_rect(Rect2(corner + Vector2(-1, -4 if sy > 0 else 0) - Vector2(0, 0 if sy > 0 else 4) + Vector2(0, 4 if sy < 0 else 0), Vector2(2, 8)), ring_col)
	# Shadow grows sharper as the Aerodyne comes down.
	var shadow_size := Vector2(118, 58) * (1.0 + altitude * 0.6)
	draw_set_transform(shadow.round() + _shake_offset(), 0.0, Vector2(1.0, 0.5))
	draw_circle(Vector2.ZERO, shadow_size.x * 0.5, Color(0, 0, 0, 0.45 - altitude * 0.25))
	_reset_xf()
	if altitude < 0.35 and brake_held:
		for i in 6:
			var a := clock * 3.0 + i * TAU / 6.0
			var dust := shadow + Vector2(cos(a), sin(a) * 0.5) * (60.0 + fposmod(clock * 90.0 + i * 13.0, 40.0))
			draw_rect(Rect2(dust.round(), Vector2(4, 3)), Color(0.75, 0.8, 0.9, 0.35))
	var lift := altitude * 120.0
	var craft := shadow - Vector2(0, lift + 22.0)
	var grow := 1.0 + altitude * 0.45
	var tilt := (-0.55 if drifted else -0.35) * altitude
	draw_aerodyne_3q(self, craft + _shake_offset(), grow, tilt, brake_held, clock, true, -0.5*altitude)
	_reset_xf()
	_draw_debris()

## Shared with the parked Aerodyne on the roof: top-down art in 3/4 view.
static func draw_aerodyne_3q(canvas: CanvasItem, center: Vector2, grow: float, tilt: float, braking: bool, time: float, powered: bool = true, bank: float = 0.0) -> void:
	var xf := Transform2D(0.0, Vector2(1.0, 0.6), 0.0, center.round()) * Transform2D(tilt, Vector2.ZERO)
	canvas.draw_set_transform_matrix(xf)
	var size := Vector2(240, 240) * grow
	Airframe.draw(canvas,Rect2(-size*0.5,size),time,1.0 if powered else 0.0,Color.WHITE,bank)
	var outlets := Airframe.nozzles(bank)
	canvas.draw_set_transform(Vector2.ZERO)
	if not powered:
		return
	# v0.48.0 · ClaudeHelper: Düsenstrahl als Pixelcluster im Bildraster statt Vektorkreisen.
	var block := maxf(1.0, roundf(grow * 2.0))
	for side in [0, 1]:
		var nozzle := (xf * (outlets[side] * grow)).round()
		var flick := int(fposmod(time * 18.0 + side * 1.7, 3.0))
		_pixel_plume(canvas, nozzle, block, braking, flick)

## Kleiner Düsenstrahl aus Pixelzeilen: heißer Kern, Ionenmantel, flackernde Spitze.
const PLUME_ROWS := ["0110", "1221", "1331", "1221", "0110", "0100"]
static func _pixel_plume(canvas: CanvasItem, nozzle: Vector2, block: float, braking: bool, flick: int) -> void:
	var ramp: Array = [Color(1.0, 0.45, 0.15, 0.45), Color(1.0, 0.7, 0.3, 0.85), Color(1.0, 0.95, 0.8)] if braking else [Color(0.15, 0.5, 0.95, 0.45), Color(0.4, 0.85, 1.0, 0.85), Color(0.85, 0.98, 1.0)]
	var rows := PLUME_ROWS.size() - (flick % 2)
	for y in rows:
		var row: String = PLUME_ROWS[y]
		for x in row.length():
			var level := int(row[x])
			if level == 0:
				continue
			var at := nozzle + Vector2((x - 2) * block, y * block)
			canvas.draw_rect(Rect2(at, Vector2(block, block)), ramp[mini(level, 3) - 1])

## Panels drawn in screen space: calibration deck, callouts.
func _draw_overlay() -> void:
	if callout_time > 0.0 and callout != "":
		var font := UiSkin.font("title")
		var width := font.get_string_size(callout, HORIZONTAL_ALIGNMENT_LEFT, -1, 16).x
		var p := Vector2(roundf(320.0 - width * 0.5), 128)
		draw_string(font, p + Vector2(1, 1), callout, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color(0, 0, 0, 0.8))
		draw_string(font, p, callout, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("ffcf5a") if hurt > 0.0 else Color("cffcff"))
	if phase == "scan" and calibration != null:
		_draw_calibration()
	if phase == "landing":
		_draw_landing_gauge()
	if engine_failed:
		draw_rect(Rect2(210, 118, 220, 18), Color(0.04, 0.07, 0.12, 0.92))
		draw_rect(Rect2(218, 124, 204, 6), Color("4d2431"))
		draw_rect(Rect2(218, 124, roundf(204.0 * repair_left / REPAIR_SECONDS), 6), Color("67f0fc"))

func _draw_calibration() -> void:
	var c = calibration
	var rect := Rect2(120, 258, 400, 74)
	draw_style_box(UiSkin.panel("tower", true), rect)
	var title := UiSkin.font("title")
	var ui := UiSkin.font("ui")
	draw_string(title, Vector2(134, 273), "SEQUENZKALIBRIERUNG · GLEITERKENNUNG", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color("ffe9ec"))
	for i in Calibration.MAX_ERRORS:
		draw_rect(Rect2(474 + i * 10, 266, 6, 6), Color("ff3150") if i < c.errors else Color("3d0710"))
	# Code steps: locked, current (blinking frame), pending.
	for i in c.steps.size():
		var step: Dictionary = c.steps[i]
		var box := Rect2(134 + i * 50, 278, 44, 26)
		var current: bool = i == c.index
		var state := "used" if step.locked else ("cursor" if current else "idle")
		draw_style_box(UiSkin.cell("tower", state), box)
		var label: String = step.code
		var col := Color("7dffaa") if step.locked else (Color.WHITE if current else Color("b98d95"))
		draw_string(title, box.position + Vector2(4, 11), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 8, col)
		var arrow: String = "✓" if step.locked else Calibration.ARROWS[int(step.dir)]
		draw_string(ui, box.position + Vector2(25, 21), arrow, HORIZONTAL_ALIGNMENT_LEFT, -1, 20, col)
	# Sweep track: the beam position and the hull window.
	var track := Rect2(134, 310, 372, 8)
	draw_rect(track, Color("1a0b10"))
	var w: Vector2 = c.window()
	var inside: bool = c.in_window()
	draw_rect(Rect2(track.position.x + track.size.x * w.x, track.position.y, track.size.x * (w.y - w.x), track.size.y), Color("7dffaa") if inside else Color("2f6b4a"))
	var mx := roundf(track.position.x + track.size.x * c.marker)
	draw_rect(Rect2(mx - 1, track.position.y - 3, 3, track.size.y + 6), Color("cffcff"))
	draw_rect(Rect2(track.position.x, track.end.y + 3, roundf(track.size.x * c.time_left / 16.0), 2), Color("ff3150"))
	var hint: String = "JETZT  %s" % Calibration.ARROWS[int(c.current().dir)] if inside else c.feedback
	var hint_col := Color("7dffaa") if inside else (Color("ff697c") if c.error_flash > 0.0 else Color("d9c3c7"))
	draw_string(ui, Vector2(388, 292), hint.left(22), HORIZONTAL_ALIGNMENT_LEFT, 128, 20, hint_col)

func _draw_landing_gauge() -> void:
	var rect := Rect2(560, 120, 56, 150)
	draw_style_box(UiSkin.panel("artos", true), rect)
	var title := UiSkin.font("title")
	draw_string(title, Vector2(568, 136), "HÖHE", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color("ffe7bd"))
	var bar := Rect2(574, 144, 10, 110)
	draw_rect(bar, Color("0c0905"))
	draw_rect(Rect2(bar.position.x, bar.end.y - roundf(bar.size.y * clampf(altitude, 0.0, 1.0)), bar.size.x, roundf(bar.size.y * clampf(altitude, 0.0, 1.0))), Color("ffb43a"))
	# Descent speed: green is a clean touchdown.
	var speed_bar := Rect2(592, 144, 10, 110)
	draw_rect(speed_bar, Color("0c0905"))
	draw_rect(Rect2(speed_bar.position.x, speed_bar.end.y - 110.0 * 0.32 / 0.9, speed_bar.size.x, 110.0 * 0.32 / 0.9), Color(0.2, 0.6, 0.35, 0.6))
	var v := roundf(110.0 * clampf(descent, 0.0, 0.9) / 0.9)
	draw_rect(Rect2(speed_bar.position.x - 2, speed_bar.end.y - v - 1, speed_bar.size.x + 4, 3), Color("7dffaa") if descent < 0.32 else (Color("ffcf5a") if descent < 0.6 else Color("ff3150")))
