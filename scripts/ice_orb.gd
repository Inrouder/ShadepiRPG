extends Node2D
## Enemy energy balls: swept world-plane collision, raised artwork at core height.
const CORE: Texture2D = preload("res://assets/sprites/npcs/ice-guardian.png")
const LIGHT: Texture2D = preload("res://assets/world/light.png")
var world: Node2D
var owner_boss: Node2D
var direction := Vector2.LEFT
var speed := 190.0
var age := 0.0
var spent := false
var previous := Vector2.ZERO

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	previous = position

func _physics_process(delta: float) -> void:
	if spent: return
	if not is_instance_valid(owner_boss) or owner_boss.is_queued_for_deletion() or world.ice_guardian() != owner_boss:
		finish(); return
	if world.is_busy(): return
	advance(delta)

func advance(delta: float) -> void:
	if spent: return
	age += delta
	previous = position
	var endpoint := position + direction * speed * delta
	var wall: Dictionary = world.trace_scenery(position, endpoint)
	if not wall.is_empty(): endpoint = wall.position
	# Resolve the first object on the swept segment, avoiding tunnelling at low FPS.
	var closest := Geometry2D.get_closest_point_to_segment(world.raven.position, position, endpoint)
	var depth: float = (world.raven.position - position).dot(direction)
	if depth >= 0 and depth <= position.distance_to(endpoint) and world.raven.position.distance_to(closest) < 12.0:
		world.raven.take_damage(20, position)
		position = closest
		finish(); return
	position = endpoint
	if not wall.is_empty() or age >= 5.0 or not Rect2(Vector2.ZERO, world.ice_map_size()).has_point(position):
		if not wall.is_empty(): world.effects.burst(position + Vector2(0,-18), Color("bf7cff"), 4)
		finish(); return
	queue_redraw()

func finish() -> void:
	if spent: return
	spent = true
	set_physics_process(false)
	if is_instance_valid(owner_boss): owner_boss.bolts.erase(self)
	hide()
	queue_free()

func _draw() -> void:
	var point := Vector2(0, -18)
	draw_texture_rect(LIGHT, Rect2(point - Vector2(15,15), Vector2(30,30)), false, Color(0.7,0.25,1,0.7))
	# The guardian's own cyan iris is the ball: no untextured placeholder circles.
	draw_set_transform(point, age * 4, Vector2.ONE)
	draw_texture_rect_region(CORE, Rect2(-6,-6,12,12), Rect2(525,535,210,210), Color(1.2,0.65,1.5))
	draw_set_transform(Vector2.ZERO)
