extends Control

var puzzle: RefCounted

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("080f19"))
	for x in range(0, int(size.x), 20):
		draw_line(Vector2(x, 0), Vector2(x, size.y), Color("183342"))
	for y in range(0, int(size.y), 20):
		draw_line(Vector2(0, y), Vector2(size.x, y), Color("183342"))
	if puzzle == null:
		return
	for target in [true, false]:
		var values: Array = puzzle.signal_target if target else puzzle.signal_values
		var points := PackedVector2Array()
		for x in range(0, int(size.x), 2):
			var wave := sin(float(x) / size.x * TAU * values[0] + values[2] * TAU / 8.0)
			var interference := sin(x * 1.7 + puzzle.clock * 20) * 5 if target and puzzle.noise else 0.0
			points.append(Vector2(x, size.y / 2 + wave * values[1] * 10 + interference))
		draw_polyline(points, Color("ffcc77") if target else Color("58edf5"), 2 if target else 1, true)
