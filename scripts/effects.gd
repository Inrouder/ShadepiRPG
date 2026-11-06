extends Node2D

var world: Node2D
var elapsed: = 0.0
var particles: Array[Dictionary] = []
var slashes: Array[Dictionary] = []
var flashes: Array[Dictionary] = []
var rain: = true
var rain_start: = 0.0
var steam_vents: Array[Vector2] = [Vector2(322, 261), Vector2(769, 239)]
var quality: = 2
var ripples: Array[Dictionary] = []
var links: Array[Dictionary] = []
var pulses: Array[Dictionary] = []
var rng: = RandomNumberGenerator.new()
var fragments: Array[Dictionary] = []
var smoke: Array[Dictionary] = []
var blasts: Array[Dictionary] = []
var charge_rings: Array[Dictionary] = []

func charge_ready(point: Vector2, ranged: bool) -> void:
	charge_rings.append({"p": point, "t": 0.4, "c": Color("67eaff") if ranged else Color("ff4b6b")})

func _ready() -> void :
	rng.seed = 84
	z_index = 50

func burst(point: Vector2, color: Color, count: int = 16) -> void :
	for i in mini(count, maxi(0, 128 - particles.size())):
		particles.append({"p": point + Vector2(0, -20), "v": Vector2.from_angle(rng.randf() * TAU) * rng.randf_range(25, 95), "t": rng.randf_range(0.2, 0.5), "c": color})

func slash(point: Vector2, direction: Vector2) -> void :
	slashes.append({"p": point + Vector2(0, -14), "a": direction.angle(), "t": 0.22})

func trail(point: Vector2, color: Color) -> void :
	if flashes.size() < 16:
		flashes.append({"p": point, "t": 0.2, "c": color})

func water_step(point: Vector2) -> void :
	if quality > 0 and ripples.size() < 20:
		ripples.append({"p": point, "t": 0.42})

func hack_arc(from: Vector2, to: Vector2) -> void :
	if links.size() < 4:
		links.append({"from": from + Vector2(0, -25), "to": to + Vector2(0, -27), "t": 0.55})

func pulse_trace(from: Vector2, to: Vector2) -> void :
	if pulses.size() < 8:
		pulses.append({"from": from + Vector2(0, -24), "to": to + Vector2(0, -24), "t": 0.16})

func prop_impact(point: Vector2, color: Color, destroyed: bool, kind: String) -> void :
	var count: = 18 if destroyed else 5
	for i in mini(count, maxi(0, 90 - fragments.size())):
		var direction: = Vector2.from_angle(rng.randf_range( - PI, 0.0))
		fragments.append({"p": point + Vector2(rng.randf_range(-9, 9), -16), "v": direction * rng.randf_range(32, 105), 
			"t": rng.randf_range(0.35, 0.8), "c": color, "size": Vector2(2 + i % 4, 2 + i % 3)})
	if kind in ["lamp", "electrical", "vending", "server", "data_cache"]:
		burst(point + Vector2(0, -28), Color("9fe5ed"), 8 if not destroyed else 20)
	if destroyed and kind in ["car", "electrical", "barrel"]:
		for i in mini(9, maxi(0, 30 - smoke.size())):
			smoke.append({"p": point + Vector2(rng.randf_range(-15, 15), -12), "t": 1.0 + i * 0.18, "life": 1.0 + i * 0.18, "size": 5.0 + i})

func prop_explosion(point: Vector2) -> void :
	if blasts.size() < 6:
		blasts.append({"p": point + Vector2(0, -12), "t": 0.42})
	burst(point, Color("ffc486"), 32)

func _process(delta: float) -> void :
	elapsed += delta
	if not world.is_busy():
		for i in range(charge_rings.size() - 1, -1, -1):
			charge_rings[i].t -= delta
			if charge_rings[i].t <= 0:
				charge_rings.remove_at(i)
		for i in range(fragments.size() - 1, -1, -1):
			fragments[i].t -= delta
			fragments[i].v.y += delta * 140.0
			fragments[i].p += fragments[i].v * delta
			if fragments[i].t <= 0.0:
				fragments.remove_at(i)
		for i in range(smoke.size() - 1, -1, -1):
			smoke[i].t -= delta
			smoke[i].p += Vector2(-4, -19) * delta
			if smoke[i].t <= 0.0:
				smoke.remove_at(i)
		for i in range(blasts.size() - 1, -1, -1):
			blasts[i].t -= delta
			if blasts[i].t <= 0.0:
				blasts.remove_at(i)
	for i in range(particles.size() - 1, -1, -1):
		particles[i].p += particles[i].v * delta
		particles[i].v *= 0.94
		particles[i].t -= delta
		if particles[i].t <= 0:
			particles.remove_at(i)
	for collection in [slashes, flashes, ripples, links, pulses]:
		for i in range(collection.size() - 1, -1, -1):
			collection[i].t -= delta
			if collection[i].t <= 0:
				collection.remove_at(i)
	queue_redraw()

func _draw() -> void :
	for ring in charge_rings:
		var age: float = 1.0 - ring.t / 0.4
		draw_arc(ring.p + Vector2(0, -20), 12 + 36 * age, 0, TAU, 40, Color(ring.c, 1 - age), 2.5)
	for cloud in smoke:
		var age: float = 1.0 - cloud.t / cloud.life
		draw_circle(cloud.p, cloud.size * (1.0 + age), Color(0.23, 0.28, 0.34, (1.0 - age) * 0.48))
	for blast in blasts:
		var fade: float = blast.t / 0.42
		draw_circle(blast.p, 38.0 * (1.0 - fade) + 5.0, Color(1.0, 0.49, 0.22, fade * 0.65))
		draw_arc(blast.p, 58.0 * (1.0 - fade) + 3.0, 0, TAU, 32, Color(1.0, 0.81, 0.55, fade), 2.0)
	for fragment in fragments:
		draw_rect(Rect2(fragment.p, fragment.size), Color(fragment.c, minf(1.0, fragment.t * 4.0)))
	if rain:
		var rain_count: = [65, 140, 210][quality] as int
		for i in rain_count:
			var p: = Vector2(rain_start + fposmod(i * 53.0 + elapsed * 28, 1024 - rain_start), fposmod(i * 31.0 + elapsed * 130, 640))
			draw_line(p, p + Vector2(-2, 5), Color(0.45, 0.65, 0.8, 0.2))
		for i in (18 if quality > 0 else 6):
			var p: = Vector2(30 + i * 57, 302 + (i * 37) % 175)
			draw_arc(p, 1 + fposmod(elapsed * 7 + i, 6), 0, PI, 8, Color(0.4, 0.65, 0.75, 0.13))
	for ripple in ripples:
		var size: float = 1.5 + 8.0 * (1.0 - ripple.t / 0.42)
		var points: = PackedVector2Array()
		for i in 13:
			var angle: = TAU * i / 12.0
			points.append(ripple.p + Vector2(cos(angle) * size, sin(angle) * size * 0.42))
		draw_polyline(points, Color(0.43, 0.78, 0.92, ripple.t * 0.7))
	for pulse in pulses:
		var alpha: float = pulse.t / 0.16
		draw_line(pulse.from, pulse.to, Color(0.2, 0.78, 1.0, alpha * 0.5), 3.0)
		draw_line(pulse.from, pulse.to, Color(0.8, 0.97, 1.0, alpha))
	for link in links:
		var points: = PackedVector2Array([link.from])
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

	for vent in steam_vents:
		for i in (5 if quality == 2 else 3):
			var progress: = fposmod(elapsed * 0.3 + i * 0.25, 1.0)
			var p: Vector2 = vent + Vector2(sin(progress * 7 + i) * 5, - progress * 40)
			draw_circle(p, 3 + progress * 7, Color(0.45, 0.6, 0.7, (1 - progress) * 0.1))
