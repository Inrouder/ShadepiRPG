extends Node2D
## v0.48.0 · ClaudeHelper: Ravens projizierter Towerplan in Kapitel 3.
## Pixelquelle: assets/story/tower-plan.png (tools/story/build_tower_plan.py).
## Frame 0 ist der Grundplan, 1–3 heben Aufzug/Wachetage, Landeplatz und Scanner hervor.

const SHEET := preload("res://assets/story/tower-plan.png")
const FRAME := Vector2(64, 96)
const EMITTER := Vector2(36, 93)   # Projektorpunkt im Quellbild = Knotenposition
const NONE := 0
const ELEVATOR := 1
const PAD := 2
const SCANNER := 3

var world: Node
var highlight := NONE
var reveal := 0.0          # 0 = aus, 1 = vollständig aufgebaut
var target_reveal := 0.0
var clock := 0.0
var pulse := 0.0
var accent: Node2D   # Hervorhebungen mit normaler Mischung, damit Rot/Bernstein/Magenta farbtreu bleiben

func _ready() -> void:
	z_index = 4
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	# Licht addiert sich wie eine echte Projektion zur dunklen Kulisse.
	var glow := CanvasItemMaterial.new()
	glow.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	glow.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED   # Projektion leuchtet selbst
	material = glow
	accent = Node2D.new()
	accent.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	accent.use_parent_material = false
	var accent_material := CanvasItemMaterial.new()
	accent_material.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
	accent.material = accent_material
	add_child(accent)
	accent.draw.connect(_draw_accent)

func show_plan(instant: bool = false) -> void:
	target_reveal = 1.0
	if instant:
		reveal = 1.0
	queue_redraw()

func hide_plan() -> void:
	target_reveal = 0.0

func focus(layer: int) -> void:
	if layer != highlight:
		highlight = layer
		pulse = 1.0
	queue_redraw()

func _paused() -> bool:
	return world != null and (world.menu_open or world.terminal != null)

func _process(delta: float) -> void:
	if _paused():
		return
	clock += delta
	pulse = maxf(0.0, pulse - delta * 1.6)
	reveal = move_toward(reveal, target_reveal, delta * 1.4)
	queue_redraw()
	accent.queue_redraw()

func _draw() -> void:
	if reveal <= 0.0:
		return
	var origin := -EMITTER
	# Aufbau von unten nach oben in ganzen Pixelzeilen.
	var rows := int(round(FRAME.y * reveal))
	var top := int(FRAME.y) - rows
	var flicker := 0.86 + 0.08 * sin(clock * 7.0) + (0.06 if fposmod(clock, 2.7) < 0.06 else 0.0)
	var base := Color(1, 1, 1, flicker)
	var src := Rect2(Vector2(0, top), Vector2(FRAME.x, rows))
	draw_texture_rect_region(SHEET, Rect2(origin + Vector2(0, top), src.size), src, base)
	draw_texture_rect_region(SHEET, Rect2(origin + Vector2(0, top), src.size), src, Color(1, 1, 1, 0.55 * flicker))
	# Wandernde Abtastzeile, pixelgenau und nur innerhalb des aufgebauten Bereichs.
	var scan := int(fposmod(clock * 22.0, FRAME.y - 8.0)) + 2
	if scan >= top:
		draw_rect(Rect2(origin + Vector2(8, scan), Vector2(FRAME.x - 16, 1)), Color(0.72, 0.98, 1.0, 0.16 * flicker))
	# Aufbaukante während des Erscheinens.
	if reveal < 1.0:
		draw_rect(Rect2(origin + Vector2(6, top), Vector2(FRAME.x - 12, 1)), Color(0.72, 0.98, 1.0, 0.55))

func _draw_accent() -> void:
	if reveal <= 0.0 or highlight == NONE:
		return
	var rows := int(round(FRAME.y * reveal))
	var top := int(FRAME.y) - rows
	var glow := 0.7 + 0.3 * sin(clock * 4.0) + pulse * 0.5
	var hsrc := Rect2(Vector2(FRAME.x * highlight, top), Vector2(FRAME.x, rows))
	accent.draw_texture_rect_region(SHEET, Rect2(-EMITTER + Vector2(0, top), hsrc.size), hsrc, Color(1, 1, 1, clampf(glow, 0.0, 1.0)))
