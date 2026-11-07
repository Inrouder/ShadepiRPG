extends Node2D
## Swept hits use world coordinates; the artwork is raised to weapon height.
var world: Node2D
var source: PixelActor
var generation := 0
var direction := Vector2.RIGHT
var ranged := false
var electric := false
var visual_offset := Vector2(0,-24)
var age := 0.0
var travelled := 0.0
func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
var remaining := 240.0
var hit: Array[Node2D] = []

func _physics_process(delta: float) -> void:
	if not is_instance_valid(source) or source.combat_generation != generation:
		queue_free()
		return
	if world.is_busy():
		return
	advance(delta)

func advance(delta: float) -> void:
	age += delta
	var distance := minf(remaining, delta * (580.0 if ranged else 340.0))
	var endpoint := position + direction * distance
	var wall: Dictionary = world.trace_scenery(position, endpoint)
	if not wall.is_empty():
		endpoint = wall.position
		distance = position.distance_to(endpoint)
	var targets: Array = []
	for target in world.special_targets():
		if not is_instance_valid(target) or target in hit:
			continue
		var offset: Vector2 = target.position - position
		var depth := offset.dot(direction)
		if depth >= -7 and depth <= distance and absf(offset.cross(direction)) <= (11.0 if ranged else 25.0) and world._line_clear(position, target.position):
			targets.append([maxf(0, depth), target])
	targets.sort_custom(func(a, b): return a[0] < b[0])
	for entry in targets:
		var target: Node2D = entry[1]
		hit.append(target)
		world.special_hit(target, 62 if ranged else 76, source, false)
		if ranged:
			position += direction * entry[0]
			queue_free()
			return
	position = endpoint
	remaining -= distance
	travelled += distance
	if not wall.is_empty():
		if wall.collider is WorldProp:
			wall.collider.take_damage(62 if ranged else 76)
		world.effects.burst(position, Color("70eaff") if ranged else Color("ff526d"), 10)
		queue_free()
	elif remaining <= 0:
		queue_free()
	queue_redraw()

func _draw() -> void:
	var p := Vector2(0, -24)
	var color := Color("65e8ff") if ranged else Color("ff395b")
	if ranged:
		PixelCombatFX.packet(self, visual_offset, direction, age, electric, false, 1.0, travelled)
	else:
		for i in 3:
			draw_arc(p - direction * i * 5, 24, direction.angle() - 1.1, direction.angle() + 1.1, 20, Color(color, 1.0 - i * 0.3), 3.0 - i * 0.7)
