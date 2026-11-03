extends Node2D

signal completed
signal crashed
const BIKE_Y := 224.0
const REAR_Y := 306.0
const LANES := [230.0, 320.0, 410.0]

var world: Node2D
var flight := false
var transponder_sent := false
var elapsed := 0.0
var lane := 1
var x := 320.0
var boss_lane := 1
var armour := 100
var health := 100
var hack := 0.0
var hack_cooldown := 0.0
var grenade_cooldown := 0.0
var shot_cooldown := 0.0
var hurt := 0.0
var next_hazard := 1.0
var pattern := 0
var grenade := Vector2.ZERO
var bullets: Array[Vector2] = []
var hazards: Array[Vector2] = []
var active := true
var rear_shots: Array[Vector2] = []
var ram_warning := 0.0
var ram_recovery := 0.0

func _process(delta: float) -> void:
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
	if flight and elapsed >= 9.0 and Input.is_action_just_pressed("hack") and not transponder_sent:
		transponder_sent = true
		world.sound("hack")
	if not flight:
		if Input.is_action_just_pressed("hack") and hack_cooldown == 0:
			hack = 3.3
			hack_cooldown = 7.0
			world.sound("hack")
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
		next_hazard += 1.14 if flight else 1.40
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
	var player_y := 292.0 if flight else BIKE_Y
	for i in range(hazards.size() - 1, -1, -1):
		var before := hazards[i].y
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

func _hit(amount: int) -> void:
	if hurt > 0.0:
		return
	health -= amount
	hurt = 0.6
	world.sound("hit")

func _draw() -> void:
	var cyan := Color("67f0fc")
	var pink := Color("ff657e")
	draw_rect(Rect2(0, 0, 640, 360), Color("0a1324"))
	for i in 28:
		var side := i % 2
		var y := fposmod(i * 37 + elapsed * (125.0 + i % 5 * 9), 420.0) - 40.0
		var width := 29 + i * 13 % 63
		var left := (110 - width) if side == 0 else 530
		draw_rect(Rect2(left, y, width, 42), Color("172438"))
		draw_rect(Rect2(left + 4, y + 4, width - 8, 2), cyan.darkened(0.45 + 0.08 * (i % 4)))
	draw_rect(Rect2(179, 0, 282, 360), Color("212a3b") if not flight else Color("101d33"))
	for edge in [180, 457]:
		draw_rect(Rect2(edge, 0, 3, 360), pink.darkened(0.39))
	for y in range(-32, 360, 42):
		for divider in [275, 365]:
			draw_rect(Rect2(divider, y + fposmod(elapsed * 220, 42), 2, 21), Color("65728b"))
	for i in 44:
		var rain := Vector2(i * 157 % 640, fposmod(i * 37 + elapsed * 335, 360))
		draw_line(rain, rain + Vector2(-2, 8), Color(0.57, 0.77, 0.95, 0.14))
	if not flight:
		var p := Vector2(LANES[boss_lane], REAR_Y - (1.0 - ram_warning / 0.85) * 42.0 if ram_warning > 0.0 else REAR_Y - ram_recovery * 50.0)
		for offset in [-18, 13]:
			var lamp := p + Vector2(offset, -27)
			draw_colored_polygon(PackedVector2Array([lamp, lamp + Vector2(5, 0), lamp + Vector2(13, -49), lamp + Vector2(-9, -49)]), Color(0.60, 0.84, 1.0, 0.10))
		draw_rect(Rect2(p - Vector2(27, 28), Vector2(54, 57)), Color("080b14"))
		draw_rect(Rect2(p - Vector2(22, 28), Vector2(44, 56)), Color("653041"))
		draw_rect(Rect2(p - Vector2(17, 13), Vector2(34, 24)), Color("192c41"))
		draw_rect(Rect2(p - Vector2(16, 19), Vector2(32, 3)), Color("855467"))
		draw_line(p + Vector2(-14, -12), p + Vector2(12, -12), Color("5c7493"), 2)
		draw_line(p + Vector2(-19, 17), p + Vector2(19, 17), Color("bd6474"), 2)
		for offset in [-18, 12]:
			draw_rect(Rect2(p + Vector2(offset, 23), Vector2(7, 4)), pink)
		if ram_warning > 0.0:
			draw_line(Vector2(p.x, BIKE_Y - 22), p, pink, 3.0)
		if hack > 0:
			draw_arc(p, 36, 0, TAU, 32, cyan, 2)
	for point in hazards:
		draw_rect(Rect2(point - Vector2(12, 6), Vector2(24, 12)), pink.darkened(0.35))
		draw_line(point - Vector2(10, 2), point + Vector2(10, 2), pink, 3)
	for shot in rear_shots:
		draw_line(shot, shot + Vector2(0, 10), pink, 2.0)
	for bullet in bullets:
		draw_line(bullet, bullet + Vector2(0, 11), cyan, 2)
	if grenade != Vector2.ZERO:
		draw_circle(grenade, 5, Color("ffd46b"))
	var bike := Vector2(x, 292.0 if flight else BIKE_Y)
	var paint := pink if hurt > 0 else cyan
	if flight:
		draw_colored_polygon(PackedVector2Array([bike + Vector2(0, -20), bike + Vector2(26, 13), bike + Vector2(10, 8), bike + Vector2(0, 17), bike + Vector2(-26, 13)]), Color("4c657f"))
	else:
		draw_rect(Rect2(bike - Vector2(6, 22), Vector2(12, 45)), Color("070912"))
		draw_colored_polygon(PackedVector2Array([bike + Vector2(0, -18), bike + Vector2(11, 5), bike + Vector2(6, 18), bike + Vector2(-6, 18), bike + Vector2(-11, 5)]), Color("822e45"))
		draw_circle(bike - Vector2(0, 5), 6, Color("a7b8d0"))
		draw_circle(bike + Vector2(0, 8), 5, Color("384365"))
	draw_line(bike + Vector2(-4, 16), bike + Vector2(-6, 27), paint, 3)
	draw_line(bike + Vector2(4, 16), bike + Vector2(6, 27), paint, 3)
