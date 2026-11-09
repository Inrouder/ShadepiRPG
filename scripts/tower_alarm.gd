extends Node2D
## v0.48.0 · ClaudeHelper: Alarm der Tower-Flucht aus echten Lichtquellen.
## Ersetzt die frühere rote Vollflächen-Überlagerung und die Vektor-Pfeile:
## Wandbeacons mit rotierendem Reflektor werfen pulsierendes rotes Licht,
## eingelassene Boden-LEDs laufen Richtung Dachausgang, der Aufzug strahlt
## beim Öffnen echtes Licht in den Raum.
## Pixelquelle: assets/story/tower/alarm-lights.png (tools/story/build_alarm_props.py).

const SHEET := preload("res://assets/story/tower/alarm-lights.png")
const BEACON := Vector2(12, 12)
const CHEVRON_SRC := Rect2(48, 2, 10, 7)
## Wandbeacons zwischen den Wandleuchten der Penthouse-Rückwand.
const BEACONS: Array[Vector2] = [Vector2(226, 260), Vector2(478, 260), Vector2(734, 260)]
## Bodenleitlinie zum Dachausgang (rechts).
const FLOOR_Y := 468.0
const FLOOR_X: Array[float] = [92.0, 207.0, 322.0, 437.0, 552.0, 667.0, 782.0, 897.0]

var world: Node
var clock := 0.0
var lights: Array[PointLight2D] = []      # färben Figuren und Requisiten
var glows: Array[Sprite2D] = []            # Lichtschimmer auf der ungeschatteten Kulisse
var lift_light: PointLight2D

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	z_index = 0
	# Beacons und Boden-LEDs leuchten selbst; die Kulisse ist ebenfalls ungeschattet.
	var emissive := CanvasItemMaterial.new()
	emissive.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
	material = emissive
	for point in BEACONS:
		lights.append(world._light(point + Vector2(0, 26), Color("ff2f4a"), 1.25, 0.0, self))
		glows.append(_glow(point + Vector2(0, -6), Vector2(1.3, 1.0)))       # Wandschein
		glows.append(_glow(point + Vector2(0, 70), Vector2(3.0, 0.9)))       # wandernder Reflex auf dem Marmor
	lift_light = world._light(world.LIFT_DOOR + Vector2(0, -20), Color("9ff0ff"), 1.6, 0.0, self)

func _glow(point: Vector2, size: Vector2) -> Sprite2D:
	# Wie die vorhandenen Neon-Halos: additiv und ungeschattet, Farbe aus der Quelle.
	var halo := Sprite2D.new()
	halo.texture = world.light_texture
	halo.position = point
	halo.scale = size
	halo.modulate = Color(1.0, 0.2, 0.28, 0.0)
	var additive := CanvasItemMaterial.new()
	additive.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
	additive.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	halo.material = additive
	add_child(halo)
	return halo

func _paused() -> bool:
	return world.menu_open or world.terminal != null

func _process(delta: float) -> void:
	if not _paused():
		clock += delta
	for i in lights.size():
		# Jeder Reflektor dreht versetzt; hell, wenn er nach vorn zeigt.
		var phase := fposmod(clock * 1.6 + i * 0.27, 1.0)
		var facing := maxf(0.0, cos((phase - 0.35) * TAU))
		var flare := pow(facing, 3.0)
		lights[i].energy = 0.15 + 1.25 * flare
		glows[i * 2].modulate.a = 0.22 + 0.78 * flare
		# Der Reflektor dreht: sein Lichtfleck wandert über den Boden.
		var sweep := sin((phase - 0.35) * TAU)
		glows[i * 2 + 1].position = BEACONS[i] + Vector2(sweep * 70.0, 70.0)
		glows[i * 2 + 1].modulate.a = 0.12 + 0.75 * flare
	lift_light.energy = 1.4 * minf(1.0, world.lift_glow)
	queue_redraw()

func _draw() -> void:
	for i in BEACONS.size():
		var phase := fposmod(clock * 1.6 + i * 0.27, 1.0)
		var frame := int(phase * 4.0) % 4
		var at := (BEACONS[i] - Vector2(BEACON.x * 0.5, BEACON.y)).round()
		draw_texture_rect_region(SHEET, Rect2(at, BEACON), Rect2(Vector2(frame * BEACON.x, 0), BEACON))
	# Lauflicht: die eingelassenen LEDs leuchten nacheinander Richtung Ausgang auf.
	var lead := fposmod(clock * 6.0, float(FLOOR_X.size() + 2))
	for i in FLOOR_X.size():
		var distance := lead - i
		var lit := 1.0 if distance >= 0.0 and distance < 1.0 else (0.62 if distance >= 1.0 and distance < 2.0 else 0.38)
		var at := (Vector2(FLOOR_X[i], FLOOR_Y) - CHEVRON_SRC.size * 0.5).round()
		draw_texture_rect_region(SHEET, Rect2(at, CHEVRON_SRC.size), CHEVRON_SRC, Color(lit, lit, lit, 1.0))
