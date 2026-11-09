extends RefCounted
## v0.48.0 · ClaudeHelper: gemeinsamer Pixelmarker für Interaktionsziele.
## Ersetzt die früheren Vektorkreise/-pfeile. Bodenring immer; der Pfeil erscheint
## nur, solange das Ziel noch außer Reichweite ist – in Reichweite reicht die Aktionszeile.
const SHEET := preload("res://assets/ui/marker.png")
const RING := Vector2(32, 14)
const CHEVRON := Vector2(11, 9)

## Weltknoten zeichnen ihre Kulisse linear gefiltert; Marker laufen deshalb über eine
## eigene Ebene mit Nearest-Abtastung. show() ersetzt die Ziele des aktuellen Bilds
## (Einträge: [Punkt, in Reichweite, gesperrt, Pfeilhöhe]); ein leeres Array blendet aus.
static func show(world: Node2D, entries: Array) -> void:
	var layer: Node2D = world.get_node_or_null("PixelMarkerLayer")
	if layer == null:
		if entries.is_empty(): return
		layer = Node2D.new()
		layer.name = "PixelMarkerLayer"
		layer.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		layer.z_index = 3
		var unshaded := CanvasItemMaterial.new()
		unshaded.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
		layer.material = unshaded
		world.add_child(layer)
		layer.set_meta("targets", [])
		layer.draw.connect(func():
			for t: Array in layer.get_meta("targets"):
				draw(layer, t[0], t[1], t[2], t[3]))
	layer.set_meta("targets", entries)
	layer.queue_redraw()

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
