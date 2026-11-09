extends RefCounted
## v0.35.0 · CodexAI. Parallel walks finish together before the next route leg.

static func walk_pair(cs, actors: Array, targets: Array, speed: float) -> void:
	var ticket: int = cs.generation
	var duration := 0.0
	for i in actors.size():
		duration = maxf(duration, actors[i].position.distance_to(targets[i]) / speed)
		cs.walk(actors[i], targets[i], speed)
	await cs.wait(duration + 0.05)
	if not cs.alive(ticket): return
	# The director owns movement, animation, pause, skip and generation guards.

static func hermite(a: Vector2, b: Vector2, velocity_a: Vector2, velocity_b: Vector2, duration: float, t: float) -> Vector2:
	var t2 := t*t
	var t3 := t2*t
	return (2*t3-3*t2+1)*a + (t3-2*t2+t)*duration*velocity_a + (-2*t3+3*t2)*b + (t3-t2)*duration*velocity_b
