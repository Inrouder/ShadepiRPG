extends Node2D

var elapsed := 0.0
var quality := 2:
	set(value):
		quality = value
		set_process(quality > 0)
		queue_redraw()

func _ready() -> void:
	z_index = -5

func _process(delta: float) -> void:
	elapsed += delta
	queue_redraw()

func _draw() -> void:
	# Grounded contact shade and a long cast silhouette behind solid scenery.
	for prop in WorldData.PROPS:
		var rect: Rect2 = prop.collision
		var cast := Vector2(20, 22) if rect.get_center().x < 540 else Vector2(-20, 26)
		draw_colored_polygon(PackedVector2Array([rect.position, rect.position + Vector2(rect.size.x, 0), rect.end + cast, rect.position + Vector2(0, rect.size.y) + cast]), Color(0.015, 0.025, 0.05, 0.36))
		draw_rect(rect.grow(3), Color(0.015, 0.025, 0.05, 0.22))
	# Facade contact shading separates walls from the wet walking surface.
	for edge in [Rect2(0, 272, 400, 12), Rect2(452, 256, 572, 12), Rect2(0, 488, 1024, 8)]:
		for i in 6:
			draw_rect(Rect2(edge.position + Vector2(0, i * 2), Vector2(edge.size.x, 2)), Color(0.015, 0.025, 0.05, 0.22 * (1.0 - i / 6.0)))
	if quality == 0:
		return
	# Painted, animated neon reflections; only the broken highlights move.
	var puddles := [
		{"p": Vector2(75, 294), "w": 83.0, "c": Color("d458a2")},
		{"p": Vector2(634, 289), "w": 138.0, "c": Color("42b9cf")},
		{"p": Vector2(890, 290), "w": 116.0, "c": Color("d859a1")}
	]
	for puddle in puddles:
		var base: Vector2 = puddle.p
		var tint: Color = puddle.c
		for i in 26:
			var falloff := 1.0 - i / 26.0
			var offset := sin(i * 2.2 + elapsed * 1.4) * 3
			var width: float = puddle.w * (0.28 + falloff * 0.58)
			var x: float = base.x - width * 0.5 + offset
			tint.a = 0.10 * falloff
			draw_line(Vector2(x, base.y + i * 3), Vector2(x + width, base.y + i * 3), tint, 2)
			if i % 3 == 0:
				tint.a = 0.24 * falloff
				draw_line(Vector2(x + width * 0.2, base.y + i * 3), Vector2(x + width * 0.62, base.y + i * 3), tint)
	# Restrained light shafts below the neon fixtures.
	for lamp in [Vector2(640, 262), Vector2(900, 262)]:
		var color := Color(0.19, 0.7, 0.85, 0.045) if lamp.x < 800 else Color(0.8, 0.25, 0.6, 0.04)
		draw_colored_polygon(PackedVector2Array([lamp + Vector2(-12, 0), lamp + Vector2(12, 0), lamp + Vector2(72, 152), lamp + Vector2(-72, 152)]), color)
