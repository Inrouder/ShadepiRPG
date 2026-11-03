extends Node2D

var world: Node2D
var elapsed := 0.0
var particles: Array[Dictionary] = []
var slashes: Array[Dictionary] = []
var flashes: Array[Dictionary] = []
var rain := true
var quality := 2
var ripples: Array[Dictionary] = []
var links: Array[Dictionary] = []
var rng := RandomNumberGenerator.new()

func _ready() -> void:
	rng.seed = 84
	z_index = 50

func burst(point: Vector2, color: Color, count: int = 16) -> void:
	for i in mini(count, maxi(0, 128 - particles.size())):
		particles.append({"p": point + Vector2(0, -20), "v": Vector2.from_angle(rng.randf() * TAU) * rng.randf_range(25, 95), "t": rng.randf_range(0.2, 0.5), "c": color})

func slash(point: Vector2, direction: Vector2) -> void:
	slashes.append({"p": point + Vector2(0, -14), "a": direction.angle(), "t": 0.22})

func trail(point: Vector2, color: Color) -> void:
	if flashes.size() < 16:
		flashes.append({"p": point, "t": 0.2, "c": color})

func water_step(point: Vector2) -> void:
	if quality > 0 and ripples.size() < 20:
		ripples.append({"p": point, "t": 0.42})

func hack_arc(from: Vector2, to: Vector2) -> void:
	if links.size() < 4:
		links.append({"from": from + Vector2(0, -25), "to": to + Vector2(0, -27), "t": 0.55})

func _process(delta: float) -> void:
	elapsed += delta
	for i in range(particles.size() - 1, -1, -1):
		particles[i].p += particles[i].v * delta
		particles[i].v *= 0.94
		particles[i].t -= delta
		if particles[i].t <= 0:
			particles.remove_at(i)
	for collection in [slashes, flashes, ripples, links]:
		for i in range(collection.size() - 1, -1, -1):
			collection[i].t -= delta
			if collection[i].t <= 0:
				collection.remove_at(i)
	queue_redraw()

func _draw() -> void:
	if rain:
		var rain_count := [65, 140, 210][quality] as int
		for i in rain_count:
			var p := Vector2(fposmod(i * 53.0 + elapsed * 28, 1024), fposmod(i * 31.0 + elapsed * 130, 640))
			draw_line(p, p + Vector2(-2, 5), Color(0.45, 0.65, 0.8, 0.2))
		for i in (18 if quality > 0 else 6):
			var p := Vector2(30 + i * 57, 302 + (i * 37) % 175)
			draw_arc(p, 1 + fposmod(elapsed * 7 + i, 6), 0, PI, 8, Color(0.4, 0.65, 0.75, 0.13))
	for ripple in ripples:
		var size: float = 1.5 + 8.0 * (1.0 - ripple.t / 0.42)
		var points := PackedVector2Array()
		for i in 13:
			var angle := TAU * i / 12.0
			points.append(ripple.p + Vector2(cos(angle) * size, sin(angle) * size * 0.42))
		draw_polyline(points, Color(0.43, 0.78, 0.92, ripple.t * 0.7))
	for link in links:
		var points := PackedVector2Array([link.from])
		for i in range(1, 11):
			var point: Vector2 = link.from.lerp(link.to, i / 11.0)
			point.y += sin(i * 2.4 + elapsed * 33.0) * 7.0
			points.append(point)
		points.append(link.to)
		draw_polyline(points, Color(0.15, 0.8, 1.0, link.t * 0.75), 3.0)
		draw_polyline(points, Color(0.75, 1.0, 1.0, link.t * 1.4))
	for particle in particles:
		var color: Color = particle.c
		color.a = minf(1.0, particle.t * 4)
		draw_rect(Rect2(particle.p, Vector2(2, 2)), color)
	for effect in slashes:
		var alpha: float = effect.t / 0.22
		var start: float = effect.a - 1.0 + (1.0 - alpha) * 0.9
		draw_arc(effect.p, 34, start, start + 1.5, 15, Color(1.0, 0.18, 0.4, alpha), 3.0)
		draw_arc(effect.p, 32, start, start + 1.5, 15, Color(1.0, 0.8, 0.85, alpha), 1.0)
	for effect in flashes:
		var color: Color = effect.c
		color.a = effect.t * 2.0
		draw_rect(Rect2(effect.p - Vector2(8, 40), Vector2(16, 38)), color)
	# Slowly moving steam is bounded to two vents.
	for vent in [Vector2(322, 261), Vector2(769, 239)]:
		for i in (5 if quality == 2 else 3):
			var progress := fposmod(elapsed * 0.3 + i * 0.25, 1.0)
			var p: Vector2 = vent + Vector2(sin(progress * 7 + i) * 5, -progress * 40)
			draw_circle(p, 3 + progress * 7, Color(0.45, 0.6, 0.7, (1 - progress) * 0.1))
