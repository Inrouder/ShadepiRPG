extends Node2D

var world: Node2D
var guardian: = false
var elapsed: = 0.0
var direction: = Vector2.ZERO
var hit: = false
var age: = 0.0
var patrol_y: = 0.0

func _process(delta: float) -> void :
	if world.is_busy():
		return
	var previous: = elapsed
	elapsed += delta
	var target: Vector2 = world.raven.position
	if guardian:
		if age == 0.0:
			patrol_y = position.y
		age += delta
		if elapsed < 0.65:
			position.y = patrol_y + sin(age * 1.3) * 23.0
		if previous < 1.2 and elapsed >= 1.2 and absf(target.y - position.y) < 16.0 and absf(target.x - position.x) < 115.0:
			world.raven.take_damage(26, position)
		if elapsed >= 2.8:
			elapsed = 0.0
	else:
		if elapsed < 0.85:
			direction = position.direction_to(target)
			position = position.move_toward(target, delta * 45.0)
		elif elapsed < 1.18:
			position = (position + direction * delta * 195.0).clamp(Vector2(25, 265), Vector2(998, 477))
			if not hit and position.distance_to(target) < 18.0:
				hit = true
				world.raven.take_damage(22, position)
		elif elapsed >= 2.15:
			elapsed = 0.0
			hit = false
	queue_redraw()

func vulnerable() -> bool:
	return elapsed >= (1.35 if guardian else 1.18)

func _draw() -> void :
	var radius: = 17.0 if guardian else 10.0
	var glow: = Color("58eaff") if vulnerable() else Color("b992ff")
	draw_circle(Vector2.ZERO, radius + 5.0, Color(glow, 0.25))
	draw_circle(Vector2.ZERO, radius, Color("140b2d"))
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 22, glow, 2.0)
	for i in 6:
		var angle: = float(i) * TAU / 6.0 + elapsed * 7.0
		draw_line(Vector2.from_angle(angle) * radius, Vector2.from_angle(angle + 0.12) * (radius + 6.0), glow)
	if guardian:
		for x in [-115, 115]:
			draw_rect(Rect2(x - 3, -12, 6, 24), glow)
		if elapsed < 1.34:
			draw_line(Vector2(-115, 0), Vector2(115, 0), Color("ff507c"), 4.0 if elapsed >= 1.2 else 1.0)
	elif elapsed < 0.85:
		draw_line(Vector2.ZERO, direction * 28.0, Color(glow, 0.5))
