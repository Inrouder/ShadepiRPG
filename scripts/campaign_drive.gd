extends Node2D

const Painted = preload("res://scripts/painted_world.gd")

signal completed
signal crashed
const BIKE_Y: = 224.0
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

func _process(delta: float) -> void :
	if not active or world.is_busy():
		return
	elapsed += delta
	hack = maxf(0, hack - delta)
	hack_cooldown = maxf(0, hack_cooldown - delta)
	grenade_cooldown = maxf(0, grenade_cooldown - delta)
	shot_cooldown = maxf(0, shot_cooldown - delta)
	hurt = maxf(0, hurt - delta)
	lane = clampi(lane + int(Input.is_action_just_pressed("move_right")) - int(Input.is_action_just_pressed("move_left")), 0, 2)
	x = move_toward(x, LANES[lane], 510.0 * delta)
	if flight and elapsed >= 9.0 and elapsed < 15.0 and Input.is_action_just_pressed("hack") and not transponder_sent:
		transponder_sent = true
		world.sound("hack")
	if not flight:
		if Input.is_action_just_pressed("hack") and hack_cooldown == 0:
			if absf(x - LANES[boss_lane]) < 35.0:
				hack = 3.3
				hack_cooldown = 7.0
				world.sound("hack")
			else:
				world.toast("Für den Hack auf die Spur des Wagens wechseln.")
		if Input.is_action_pressed("attack") and shot_cooldown == 0:
			bullets.append(Vector2(x, BIKE_Y + 14.0))
			shot_cooldown = 0.23
			world.sound("slash")
		if Input.is_action_just_pressed("dash") and grenade_cooldown == 0:
			grenade = Vector2(x, BIKE_Y + 18.0)
			grenade_cooldown = 3.4
	if not flight:
		if hack > 0:
			ram_warning = 0.0
		elif ram_warning > 0.0:
			ram_warning -= delta
			if ram_warning <= 0.0:
				if absf(x - LANES[boss_lane]) < 30:
					_hit(32)
				ram_recovery = 0.8
		ram_recovery = maxf(0.0, ram_recovery - delta)
	if elapsed >= next_hazard:
		next_hazard += 1.14 if flight else 1.4
		hazards.append(Vector2(LANES[(lane + 1 + pattern % 2) % 3], 68))
		if not flight and hack == 0 and ram_warning <= 0.0:
			boss_lane = [1, 0, 2, 1, 2, 0][pattern % 6]
			if pattern % 4 == 3:
				ram_warning = 0.85
				world.sound("hit")
			else:
				rear_shots.append(Vector2(LANES[boss_lane], REAR_Y - 25))
		pattern += 1
	for i in range(bullets.size() - 1, -1, -1):
		bullets[i].y += 490 * delta
		if bullets[i].y >= REAR_Y - 19:
			if absf(bullets[i].x - LANES[boss_lane]) < 30:
				armour -= 10 if hack > 0 else 5
			bullets.remove_at(i)
	if grenade != Vector2.ZERO:
		grenade.y += 288 * delta
		if grenade.y >= REAR_Y - 15:
			if absf(grenade.x - LANES[boss_lane]) < 44:
				armour -= 33
				world.sound("hit")
			grenade = Vector2.ZERO
	for i in range(rear_shots.size() - 1, -1, -1):
		rear_shots[i].y -= 350 * delta
		if rear_shots[i].y <= BIKE_Y:
			if absf(rear_shots[i].x - x) < 24:
				_hit(18)
			rear_shots.remove_at(i)
	var player_y: = 292.0 if flight else BIKE_Y
	for i in range(hazards.size() - 1, -1, -1):
		var before: = hazards[i].y
		hazards[i].y += (210.0 if flight else 226.0) * delta
		if before < player_y and hazards[i].y >= player_y and absf(hazards[i].x - x) < 30:
			_hit(24)
		if hazards[i].y > 370:
			hazards.remove_at(i)
	queue_redraw()
	if health <= 0:
		active = false
		crashed.emit()
	elif flight and elapsed >= 15.0:
		active = false
		if transponder_sent:
			completed.emit()
		else:
			crashed.emit()
	elif not flight and armour <= 0:
		active = false
		completed.emit()

func _hit(amount: int) -> void :
	if hurt > 0.0:
		return
	health -= amount
	hurt = 0.6
	world.sound("hit")

func _draw() -> void :
	var cyan: = Color("67f0fc")
	var pink: = Color("ff657e")
	if flight:
		_draw_airspace(cyan)
	else:
		_draw_highway()
	if not flight:
		var p: = Vector2(LANES[boss_lane], REAR_Y - (1.0 - ram_warning / 0.85) * 42.0 if ram_warning > 0.0 else REAR_Y - ram_recovery * 50.0)
		for offset in [-18, 13]:
			var lamp: = p + Vector2(offset, -27)
			draw_colored_polygon(PackedVector2Array([lamp, lamp + Vector2(5, 0), lamp + Vector2(13, -49), lamp + Vector2(-9, -49)]), Color(0.6, 0.84, 1.0, 0.1))
		draw_rect(Rect2(p - Vector2(27, 28), Vector2(54, 57)), Color("080b14"))
		draw_rect(Rect2(p - Vector2(22, 28), Vector2(44, 56)), Color("273242"))
		draw_rect(Rect2(p - Vector2(17, 13), Vector2(34, 24)), Color("192c41"))
		draw_rect(Rect2(p - Vector2(16, 19), Vector2(32, 3)), Color("516576"))
		draw_line(p + Vector2(-14, -12), p + Vector2(12, -12), Color("5c7493"), 2)
		draw_line(p + Vector2(-19, 17), p + Vector2(19, 17), Color("bd6474"), 2)
		for offset in [-18, 12]:
			draw_rect(Rect2(p + Vector2(offset, 23), Vector2(7, 4)), pink)
		if ram_warning > 0.0:
			draw_line(Vector2(p.x, BIKE_Y - 22), p, pink, 3.0)
		if hack > 0:
			draw_arc(p, 36, 0, TAU, 32, cyan, 2)
	for point in hazards:
		if flight:
			draw_colored_polygon(PackedVector2Array([point + Vector2(0, -10), point + Vector2(14, 0), 
				point + Vector2(0, 10), point + Vector2(-14, 0)]), Color("a56556"))
			draw_line(point + Vector2(-7, 0), point + Vector2(7, 0), Color("ffe09b"), 2)
		else:
			draw_rect(Rect2(point - Vector2(12, 6), Vector2(24, 12)), pink.darkened(0.35))
			draw_line(point - Vector2(10, 2), point + Vector2(10, 2), pink, 3)
	for shot in rear_shots:
		draw_line(shot, shot + Vector2(0, 10), pink, 2.0)
	for bullet in bullets:
		draw_line(bullet, bullet + Vector2(0, 11), cyan, 2)
	if grenade != Vector2.ZERO:
		draw_circle(grenade, 5, Color("ffd46b"))
	var bike: = Vector2(x, 292.0 if flight else BIKE_Y)
	var paint: = pink if hurt > 0 else cyan
	if flight:
		draw_colored_polygon(PackedVector2Array([bike + Vector2(-16, -24), bike + Vector2(16, -24), 
			bike + Vector2(26, -7), bike + Vector2(26, 16), bike + Vector2(12, 20), 
			bike + Vector2(-12, 20), bike + Vector2(-26, 16), bike + Vector2(-26, -7)]), Color("657779"))
		draw_rect(Rect2(bike - Vector2(14, 17), Vector2(28, 12)), Color("273b4d"))
		draw_line(bike + Vector2(-21, 9), bike + Vector2(20, 8), Color("a49478"), 2)
		for offset in [-18, 18]:
			var nozzle: = bike + Vector2(offset, 16)
			draw_rect(Rect2(nozzle - Vector2(4, 2), Vector2(8, 6)), Color("283743"))
			draw_line(nozzle + Vector2(0, 4), nozzle + Vector2(0, 12 + sin(elapsed * 34.0) * 3.0), Color("ef9863"), 4)
	else:
		draw_rect(Rect2(bike - Vector2(6, 22), Vector2(12, 45)), Color("070912"))
		draw_colored_polygon(PackedVector2Array([bike + Vector2(0, -18), bike + Vector2(11, 5), bike + Vector2(6, 18), bike + Vector2(-6, 18), bike + Vector2(-11, 5)]), Color("822e45"))
		draw_polyline(PackedVector2Array([bike + Vector2(-1, -15), bike + Vector2(-8, -1), bike + Vector2(-4, 12)]), Color("dc785d"), 2)
		draw_polyline(PackedVector2Array([bike + Vector2(2, -15), bike + Vector2(7, -1), bike + Vector2(4, 12)]), Color("e49b70"), 2)
		draw_colored_polygon(PackedVector2Array([bike + Vector2(-8, -7), bike + Vector2(0, -14), 
			bike + Vector2(8, -7), bike + Vector2(0, -3)]), Color("121d2b"))
		draw_line(bike + Vector2(-4, -8), bike + Vector2(4, -8), Color("ed665e"))
		draw_circle(bike + Vector2(0, 7), 5, Color("202b42"))
		draw_line(bike + Vector2(-4, 10), bike + Vector2(4, 10), Color("74c1dd"), 2)
		draw_line(bike + Vector2(-4, 17), bike + Vector2(-5, 24), Color("cf544e"), 2)
		draw_line(bike + Vector2(4, 17), bike + Vector2(5, 24), Color("cf544e"), 2)
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
