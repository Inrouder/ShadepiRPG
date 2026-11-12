extends Node2D
## v0.60.0 · ClaudeHelper (Nutzerauftrag vom 12. November 2026): Durchgangsräume aus den
## gelieferten Kulissenbildern – Gasse vor Ravens Wohnung, Tower-Flur und Lobby, zwei Netz-Ebenen.
## Ein Raum liegt abseits der Stammkarte, bringt Boden, Wände und Kamera selbst mit und meldet,
## wenn die geführte Figur den Ausgang erreicht. Die Welt bleibt dabei unverändert.
signal exit_reached

const ROOMS := {
	# Gasse hinter Ravens Wohnung: ein Bildschirm, Boden läuft perspektivisch nach hinten zu.
	"backalley": {
		"art": preload("res://assets/world/painted/backalley.webp"), "size": Vector2(640, 360), "zoom": 1.0,
		"floor": [Vector2(186, 240), Vector2(455, 240), Vector2(636, 300), Vector2(636, 354), Vector2(4, 354), Vector2(4, 290), Vector2(58, 270), Vector2(118, 254)],
		"solids": [],
		"routes": {"in": [Vector2(58, 278), Vector2(596, 334)]},   # Tür nach v0.60.1 auf Figurenmaß
		# Neonröhren links (pink) und rechts (cyan) beleuchten die Figuren.
		"lights": [[Vector2(140, 250), "ff4fa8", 2.6, 0.75], [Vector2(505, 250), "4fe6e0", 2.6, 0.75], [Vector2(320, 300), "c8b8e8", 3.0, 0.4]],
	},
	# Tower: Flur zwischen Landeplatz (links) und Lobby (rechts).
	"tower_corridor": {
		"art": preload("res://assets/world/painted/tower-corridor.webp"), "size": Vector2(1086, 245.5), "zoom": 1.25,
		"floor": [Vector2(112, 148), Vector2(976, 148), Vector2(976, 206), Vector2(112, 206)],
		"solids": [],
		"routes": {"in": [Vector2(134, 180), Vector2(958, 180)], "out": [Vector2(952, 180), Vector2(130, 180)]},
	},
	# Tower: Lobby vor Kenzōs Penthouse; die Tür zur Suite liegt in der Mitte der Rückwand.
	"tower_lobby": {
		"art": preload("res://assets/world/painted/tower-lobby.webp"), "size": Vector2(1085, 270), "zoom": 1.25,
		"floor": [Vector2(100, 176), Vector2(988, 176), Vector2(988, 228), Vector2(100, 228)],
		"solids": [Rect2(290, 170, 84, 16), Rect2(716, 170, 82, 16)],
		"routes": {"in": [Vector2(122, 204), Vector2(543, 184)], "out": [Vector2(543, 196), Vector2(118, 204)]},
	},
	# Netz-Ebene 2: violettes Datenarchiv; Kristallspeicher stehen als Deckung im Weg.
	"dive_archive": {
		"art": preload("res://assets/world/painted/dive-archive.webp"), "size": Vector2(1086, 362), "zoom": 1.0,
		"floor": [Vector2(6, 150), Vector2(1080, 150), Vector2(1080, 252), Vector2(6, 252)],
		# v0.60.2 · ClaudeHelper: gesperrt ist nur der Sockel; dahinter läuft man durch und wird
		# vom Kristall verdeckt.
		"solids": [Rect2(50, 240, 55, 12), Rect2(374, 214, 47, 12), Rect2(641, 240, 54, 12), Rect2(951, 240, 54, 12)],
		"occluders": [Rect2(50, 172, 55, 80), Rect2(374, 162, 47, 64), Rect2(641, 182, 54, 83), Rect2(951, 172, 54, 80)],
		"routes": {"in": [Vector2(28, 200), Vector2(930, 166)]},
	},
	# Netz-Ebene 3: roter Kern vor dem Wächter.
	"dive_core": {
		"art": preload("res://assets/world/painted/dive-core.webp"), "size": Vector2(1086, 362), "zoom": 1.0,
		"floor": [Vector2(6, 178), Vector2(1080, 178), Vector2(1080, 266), Vector2(6, 266)],
		"solids": [Rect2(15, 254, 70, 12), Rect2(398, 240, 70, 12), Rect2(762, 248, 68, 12)],
		"occluders": [Rect2(15, 178, 70, 88), Rect2(398, 172, 70, 80), Rect2(762, 175, 68, 85)],
		"routes": {"in": [Vector2(122, 226), Vector2(980, 200)]},
	},
}
## Lage aller Räume: weit unter der Stammkarte (0…1024 × 0…640), damit nichts überlappt.
const ORIGIN := Vector2(0, 2400)

var world: Node2D
var key := ""
var config: Dictionary
var route := "in"
var lead: Callable
var locked := false                 # Ausgang gesperrt, solange Gegner leben
var done := false
var exit_radius := 24.0
var body: StaticBody2D
var saved := {}
var covers: Array[Sprite2D] = []
var clock := 0.0

func open(owner_world: Node2D, room_key: String, route_key: String, lead_actor: Callable) -> void:
	world = owner_world
	key = room_key
	config = ROOMS[key]
	route = route_key
	lead = lead_actor
	name = "PassageRoom"
	position = ORIGIN
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	var unshaded := CanvasItemMaterial.new()
	unshaded.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
	material = unshaded
	world.add_child(self)
	world.move_child(self, world.actors.get_index())
	# Boden als Vieleck: jede Kante wird zur Wand, dazu die Hindernisse im Raum.
	body = StaticBody2D.new()
	body.collision_layer = 1
	body.collision_mask = 0
	var points: Array = config.floor
	for i in points.size():
		var a: Vector2 = points[i]
		var b: Vector2 = points[(i + 1) % points.size()]
		var mid := (a + b) * 0.5
		var centre := floor_centre()
		var outward := (b - a).orthogonal().normalized()
		if outward.dot(mid - centre) < 0.0: outward = -outward
		var wall := CollisionPolygon2D.new()
		wall.polygon = PackedVector2Array([a, b, b + outward * 40.0, a + outward * 40.0])
		body.add_child(wall)
	for box: Rect2 in config.solids:
		var shape := CollisionShape2D.new()
		var rect := RectangleShape2D.new()
		rect.size = box.size
		shape.shape = rect
		shape.position = box.get_center()
		body.add_child(shape)
	add_child(body)
	var cam: Camera2D = world.camera
	saved = {"left": cam.limit_left, "top": cam.limit_top, "right": cam.limit_right, "bottom": cam.limit_bottom, "zoom": cam.zoom, "rain": world.effects.rain}
	var view := Vector2(640, 360) / float(config.zoom)
	var size: Vector2 = config.size
	var pad := Vector2(maxf(0.0, view.x - size.x), maxf(0.0, view.y - size.y)) * 0.5
	cam.limit_left = int(position.x - pad.x)
	cam.limit_top = int(position.y - pad.y)
	cam.limit_right = int(ceilf(position.x + size.x + pad.x))
	cam.limit_bottom = int(ceilf(position.y + size.y + pad.y))
	cam.zoom = Vector2.ONE * float(config.zoom)
	world.effects.rain = false
	# Verdecker: Bildausschnitte, die nach ihrem Sockel einsortiert werden – wer dahinter steht,
	# verschwindet hinter Säule oder Datenwand.
	var art: Texture2D = config.art
	var ratio: Vector2 = art.get_size() / size
	for box: Rect2 in config.get("occluders", []):
		var cover := Sprite2D.new()
		cover.texture = art
		cover.centered = false
		cover.region_enabled = true
		cover.region_rect = Rect2(box.position * ratio, box.size * ratio)
		cover.scale = Vector2.ONE / ratio
		cover.offset = Vector2(0, -box.size.y * ratio.y)
		cover.position = ORIGIN + Vector2(box.position.x, box.end.y)
		cover.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		cover.material = material
		world.actors.add_child(cover)
		covers.append(cover)
	for lamp: Array in config.get("lights", []):
		world._light(lamp[0], Color(lamp[1]), lamp[2], lamp[3], self)
	_follow()

func close() -> void:
	if not is_instance_valid(world):
		return
	var cam: Camera2D = world.camera
	if not saved.is_empty():
		cam.limit_left = saved.left
		cam.limit_top = saved.top
		cam.limit_right = saved.right
		cam.limit_bottom = saved.bottom
		cam.zoom = saved.zoom
		world.effects.rain = saved.rain
		saved = {}
	for cover in covers:
		if is_instance_valid(cover):
			cover.get_parent().remove_child(cover)
			cover.queue_free()
	covers.clear()
	if is_instance_valid(body): body.collision_layer = 0
	if get_parent() != null: get_parent().remove_child(self)
	queue_free()

func point(local: Vector2) -> Vector2:
	return ORIGIN + local

func entry() -> Vector2:
	return point(config.routes[route][0])

func exit() -> Vector2:
	return point(config.routes[route][1])

func floor_centre() -> Vector2:
	var sum := Vector2.ZERO
	for p: Vector2 in config.floor: sum += p
	return sum / float(config.floor.size())

## Umschließendes Rechteck des Bodens in Weltkoordinaten.
func floor_bounds() -> Rect2:
	var box := Rect2(config.floor[0], Vector2.ZERO)
	for p: Vector2 in config.floor: box = box.expand(p)
	return Rect2(box.position + ORIGIN, box.size)

## Liegt der Punkt (mit Abstand) in einem Hindernis oder außerhalb des Bodens?
func blocked(global_point: Vector2, radius: float) -> bool:
	var local := global_point - ORIGIN
	for box: Rect2 in config.solids:
		if box.grow(radius).has_point(local): return true
	return not Geometry2D.is_point_in_polygon(local, PackedVector2Array(config.floor))

func contains(global_point: Vector2) -> bool:
	return Geometry2D.is_point_in_polygon(global_point - ORIGIN, PackedVector2Array(config.floor))

func _follow() -> void:
	var actor: Node2D = lead.call() if lead.is_valid() else null
	if is_instance_valid(actor) and not world.in_cinematic():
		world.camera.position = actor.position + Vector2(0, -34)
		world.camera.zoom = Vector2.ONE * float(config.zoom)

func _process(delta: float) -> void:
	clock += delta
	_follow()
	queue_redraw()
	if done or locked or world.is_busy():
		return
	var actor: Node2D = lead.call() if lead.is_valid() else null
	if is_instance_valid(actor) and actor.position.distance_to(exit()) <= exit_radius:
		done = true
		exit_reached.emit()

func _draw() -> void:
	var size: Vector2 = config.size
	draw_rect(Rect2(-600, -400, size.x + 1200, size.y + 800), Color("05060b"))
	draw_texture_rect(config.art, Rect2(Vector2.ZERO, size), false)
