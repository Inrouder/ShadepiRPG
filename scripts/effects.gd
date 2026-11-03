extends Node2D

var world: Node2D
var elapsed := 0.0
var particles: Array[Dictionary] = []
var slashes: Array[Dictionary] = []
var flashes: Array[Dictionary] = []
var rain := true
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

func _process(delta: float) -> void:
	elapsed += delta
	for i in range(particles.size() - 1, -1, -1):
		particles[i].p += particles[i].v * delta
		particles[i].v *= 0.94
		particles[i].t -= delta
		if particles[i].t <= 0:
			particles.remove_at(i)
	for collection in [slashes, flashes]:
		for i in range(collection.size() - 1, -1, -1):
			collection[i].t -= delta
			if collection[i].t <= 0:
				collection.remove_at(i)
	queue_redraw()

func _draw() -> void:
	if rain:
		for i in 150:
			var p := Vector2(fposmod(i * 53.0 + elapsed * 28, 1024), fposmod(i * 31.0 + elapsed * 130, 640))
			draw_line(p, p + Vector2(-2, 5), Color(0.45, 0.65, 0.8, 0.2))
		for i in 18:
			var p := Vector2(30 + i * 57, 302 + (i * 37) % 175)
			draw_arc(p, 1 + fposmod(elapsed * 7 + i, 6), 0, PI, 8, Color(0.4, 0.65, 0.75, 0.13))
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
	for vent in [Vector2(322, 261), Vector2(787, 154)]:
		for i in 4:
			var progress := fposmod(elapsed * 0.3 + i * 0.25, 1.0)
			var p: Vector2 = vent + Vector2(sin(progress * 7 + i) * 5, -progress * 40)
			draw_circle(p, 3 + progress * 7, Color(0.45, 0.6, 0.7, (1 - progress) * 0.1))
