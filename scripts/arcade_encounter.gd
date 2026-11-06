extends Node2D
## A section is saved at its entrance; an interrupted wave restarts fairly.
signal section_changed
signal completed

const WAVE_BREAK := 2.0
var world: Node2D
var sections: Array = []
var section_index := 0
var wave_index := 0
var waiting := false
var finished := true
var break_left := 0.0
var fighters: Array[PixelActor] = []
var spawn_enemy: Callable
var left_gate: StaticBody2D
var right_gate: StaticBody2D

func configure(game: Node2D, plan: Array, spawn: Callable, saved_section: int = 0) -> void:
	world = game
	sections = plan
	spawn_enemy = spawn
	section_index = clampi(saved_section, 0, sections.size() - 1)
	finished = false
	left_gate = _gate()
	right_gate = _gate()
	_prepare_section()
	_start_wave()

func _gate() -> StaticBody2D:
	var body := StaticBody2D.new()
	body.collision_layer = 1
	body.collision_mask = 0
	var shape := CollisionShape2D.new()
	var box := RectangleShape2D.new()
	box.size = Vector2(8, 1280)
	shape.shape = box
	body.add_child(shape)
	add_child(body)
	return body

func _prepare_section() -> void:
	var bounds: Vector2 = sections[section_index].bounds
	left_gate.position = Vector2(bounds.x, 320)
	right_gate.position = Vector2(bounds.y, 320)
	left_gate.get_child(0).set_deferred("disabled", true)
	wave_index = 0
	break_left = 0.0
	waiting = true
	queue_redraw()

func leader() -> PixelActor:
	return world.raven if world.raven_leads() else world.player

func _start_wave() -> void:
	waiting = false
	left_gate.get_child(0).set_deferred("disabled", false)
	# Keep the AI companion with Shadepi when the rear barrier closes.
	if not world.raven_leads() and world.raven.health > 0:
		if world.raven.position.x < left_gate.position.x + 14:
			world.raven.position = leader().position
	fighters.clear()
	for entry: Array in sections[section_index].waves[wave_index]:
		var foe: PixelActor = spawn_enemy.call(_arrival_point(entry[0]), entry[1])
		foe.awareness = INF
		# Readable arrival effect and windup grace, including ranged reinforcements.
		foe.cooldown = 1.3
		fighters.append(foe)
		world.effects.burst(foe.position, Color("ed597e"), 10)
	world.toast("ABSCHNITT %d · WELLE %d / %d" % [section_index + 1, wave_index + 1, sections[section_index].waves.size()])
	queue_redraw()

func _arrival_point(authored: Vector2) -> Vector2:
	# Do not materialize reinforcements directly on either living hero.
	var section: Dictionary = sections[section_index]
	var query := PhysicsShapeQueryParameters2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 8
	query.shape = circle
	query.collision_mask = 1
	for radius in [0, 64, 96, 128]:
		for direction in (1 if radius == 0 else 12):
			var point: Vector2 = authored + Vector2.from_angle(direction * TAU / 12) * radius
			if point.x < section.bounds.x + 20 or point.x > section.bounds.y - 20 or point.y < section.floor.x + 12 or point.y > section.floor.y - 12:
				continue
			var occupied := false
			for actor in [world.player, world.raven]:
				if actor.visible and actor.health > 0 and actor.position.distance_to(point) < 56:
					occupied = true
			for foe in fighters:
				if foe.position.distance_to(point) < 24:
					occupied = true
			if occupied:
				continue
			query.transform = Transform2D(0, point)
			if world.get_world_2d().direct_space_state.intersect_shape(query, 1).is_empty():
				return point
	return authored

func living() -> int:
	var count := 0
	for foe in fighters:
		if is_instance_valid(foe) and foe.health > 0:
			count += 1
	return count

func _process(delta: float) -> void:
	if finished or world.is_busy():
		return
	if waiting:
		if leader().position.x >= sections[section_index].start.x - 16:
			_start_wave()
		return
	if break_left > 0:
		break_left = maxf(0, break_left - delta)
		if break_left == 0:
			wave_index += 1
			_start_wave()
		return
	if living() > 0:
		return
	if wave_index + 1 < sections[section_index].waves.size():
		break_left = WAVE_BREAK
		world.toast("Welle geschafft · Verstärkung in 2 s")
		return
	# Small recovery rewards steady progress without resetting the challenge.
	for actor in [world.player, world.raven]:
		if actor.health > 0:
			actor.health = mini(100, actor.health + 15)
			actor.energy = minf(100, actor.energy + 20)
	if section_index + 1 < sections.size():
		section_index += 1
		_prepare_section()
		section_changed.emit()
		world.toast("ABSCHNITT FREI · WEITER →  +15 LP")
	else:
		finished = true
		left_gate.get_child(0).set_deferred("disabled", true)
		right_gate.get_child(0).set_deferred("disabled", true)
		queue_redraw()
		completed.emit()

func status_text() -> String:
	if finished:
		return "Abschnitt frei · WEITER →"
	if waiting:
		return "WEITER → Abschnitt %d / %d" % [section_index + 1, sections.size()]
	return "Abs. %d/%d · Welle %d/%d · %s" % [section_index + 1, sections.size(), wave_index + 1, sections[section_index].waves.size(), "%.0f s" % ceilf(break_left) if break_left > 0 else "%d übrig" % living()]

func _draw() -> void:
	if finished or sections.is_empty():
		return
	var floor_y: Vector2 = sections[section_index].floor
	for x: float in [left_gate.position.x, right_gate.position.x]:
		if waiting and x == left_gate.position.x:
			continue
		draw_line(Vector2(x, floor_y.x), Vector2(x, floor_y.y), Color(1, 0.25, 0.45, 0.7), 3)
		for y in range(int(floor_y.x), int(floor_y.y), 16):
			draw_line(Vector2(x - 5, y + 6), Vector2(x + 5, y), Color("ff6789"), 2)
	if waiting:
		var p: Vector2 = sections[section_index].start
		draw_polyline(PackedVector2Array([p + Vector2(-14, -10), p, p + Vector2(-14, 10)]), Color("68f4cf"), 4)
