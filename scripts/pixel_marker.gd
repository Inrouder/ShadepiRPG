extends RefCounted
## v0.48.0 · ClaudeHelper: gemeinsamer Pixelmarker für Interaktionsziele.
## Ersetzt die früheren Vektorkreise/-pfeile. Bodenring immer; der Pfeil erscheint
## nur, solange das Ziel noch außer Reichweite ist – in Reichweite reicht die Aktionszeile.
const SHEET := preload("res://assets/ui/marker.png")
const RING := Vector2(32, 14)
const CHEVRON := Vector2(11, 9)

## Weltknoten zeichnen ihre Kulisse linear gefiltert; Marker laufen deshalb über eigene
## Ebenen mit Nearest-Abtastung. show() ersetzt die Ziele des aktuellen Bilds
## (Einträge: [Punkt, in Reichweite, gesperrt, Pfeilhöhe]); ein leeres Array blendet aus.
## v0.52.0 · ClaudeHelper: Der Bodenring liegt als Bodenmarkierung UNTER den y-sortierten
## Figuren (Ebene direkt vor `actors`), nur der schwebende Pfeil bleibt darüber.
static func show(world: Node2D, entries: Array) -> void:
	var ground: Node2D = world.get_node_or_null("PixelMarkerLayer")
	if ground == null:
		if entries.is_empty(): return
		ground = _layer(world, "PixelMarkerLayer", true)
		_layer(world, "PixelMarkerArrows", false)
	var arrows: Node2D = world.get_node("PixelMarkerArrows")
	for layer in [ground, arrows]:
		layer.set_meta("targets", entries)
		layer.queue_redraw()

static func _layer(world: Node2D, layer_name: String, floor_part: bool) -> Node2D:
	var layer := Node2D.new()
	layer.name = layer_name
	layer.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var unshaded := CanvasItemMaterial.new()
	unshaded.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
	layer.material = unshaded
	layer.set_meta("targets", [])
	world.add_child(layer)
	var actors: Node = world.get("actors")
	if floor_part and actors != null and actors.get_parent() == world:
		world.move_child(layer, actors.get_index())   # nach der Kulisse, vor den Figuren
	elif not floor_part:
		layer.z_index = 3
	layer.draw.connect(func():
		for t: Array in layer.get_meta("targets"):
			if floor_part: draw_ring(layer, t[0], t[2])
			elif not t[1]: draw_arrow(layer, t[0], t[2], t[3]))
	return layer

static func draw_ring(canvas: CanvasItem, point: Vector2, blocked: bool = false) -> void:
	var row := 1 if blocked else 0
	var frame := int(fposmod(Time.get_ticks_msec() * 0.003, 3.0))
	var origin := (point - RING * 0.5).round()
	canvas.draw_texture_rect_region(SHEET, Rect2(origin, RING), Rect2(Vector2(frame * RING.x, row * RING.y), RING))

static func draw_arrow(canvas: CanvasItem, point: Vector2, blocked: bool = false, arrow_height: float = 34.0) -> void:
	var row := 1 if blocked else 0
	var bob := roundf(sin(Time.get_ticks_msec() * 0.005) * 2.0)
	var tip := (point + Vector2(-CHEVRON.x * 0.5, -arrow_height + bob)).round()
	canvas.draw_texture_rect_region(SHEET, Rect2(tip, CHEVRON), Rect2(Vector2(RING.x * 3, row * RING.y), CHEVRON))
