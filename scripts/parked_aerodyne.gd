extends Node2D
## The Aerodyne after the landing: stays on the tower pad for the whole roof
## scene, y-sorted with the heroes. Engines tick and glow while cooling down.
const Flight = preload("res://scripts/aerodyne_flight.gd")

## Touchdown point on the pad (world); the node itself sits at the hull's front edge.
var spot := Flight.PAD_WORLD
var clock := 0.0
var steam: Array[Dictionary] = []

func place(world_spot: Vector2) -> void:
	spot = world_spot
	position = spot + Vector2(0, 30)

func footprint() -> Rect2:
	return Rect2(spot + Vector2(-48, -26), Vector2(96, 50))

func _process(delta: float) -> void:
	clock += delta
	if int(clock * 2.5) != int((clock - delta) * 2.5) and steam.size() < 8:
		steam.append({"p": Vector2(randf_range(-40, 40), randf_range(-36, -6)), "t": 1.2})
	for i in range(steam.size() - 1, -1, -1):
		steam[i].t -= delta
		steam[i].p.y -= delta * 18.0
		if steam[i].t <= 0.0:
			steam.remove_at(i)
	queue_redraw()

func _draw() -> void:
	var center := Vector2(0, -50)
	# Contact shadow on the wet deck.
	draw_set_transform(Vector2(0, -30), 0.0, Vector2(1.0, 0.5))
	draw_circle(Vector2.ZERO, 54.0, Color(0, 0, 0, 0.45))
	draw_set_transform(Vector2.ZERO)
	Flight.draw_aerodyne_3q(self, center, 1.0 / Flight.ROOF_ZOOM, 0.0, false, clock * 0.2)
	for puff in steam:
		var a: float = puff.t / 1.2
		draw_rect(Rect2((center + puff.p).round(), Vector2(4, 4)), Color(0.75, 0.82, 0.92, 0.25 * a))
