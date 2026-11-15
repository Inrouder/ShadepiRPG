extends RefCounted
## v0.61.0 · CodexAI: generated material/FX atlas, no procedural replacement shapes.
const TEXTURE = preload("res://assets/arcade/props-fx-hq.png")
const CELL := Vector2(256, 256)

static func draw(c: CanvasItem, index: int, rect: Rect2, tint: Color = Color.WHITE) -> void:
	c.draw_texture_rect_region(TEXTURE, rect, Rect2(Vector2(index % 4, index / 4) * CELL, CELL), tint)

static func centered(c: CanvasItem, index: int, point: Vector2, size: Vector2, tint: Color = Color.WHITE) -> void:
	draw(c, index, Rect2(point - size * 0.5, size), tint)
