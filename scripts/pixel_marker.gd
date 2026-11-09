extends RefCounted
## v0.48.0 · ClaudeHelper: gemeinsamer Pixelmarker für Interaktionsziele.
## Ersetzt die früheren Vektorkreise/-pfeile. Bodenring immer; der Pfeil erscheint
## nur, solange das Ziel noch außer Reichweite ist – in Reichweite reicht die Aktionszeile.
const SHEET := preload("res://assets/ui/marker.png")
const RING := Vector2(32, 14)
const CHEVRON := Vector2(11, 9)

static func draw(canvas: CanvasItem, point: Vector2, near: bool, blocked: bool = false, arrow_height: float = 34.0) -> void:
	var row := 1 if blocked else 0
	var t := Time.get_ticks_msec() * 0.001
	var frame := int(fposmod(t * 3.0, 3.0))
	var origin := (point - RING * 0.5).round()
	canvas.draw_texture_rect_region(SHEET, Rect2(origin, RING), Rect2(Vector2(frame * RING.x, row * RING.y), RING))
	if near:
		return
	var bob := roundf(sin(t * 5.0) * 2.0)
	var tip := (point + Vector2(-CHEVRON.x * 0.5, -arrow_height + bob)).round()
	canvas.draw_texture_rect_region(SHEET, Rect2(tip, CHEVRON), Rect2(Vector2(RING.x * 3, row * RING.y), CHEVRON))
