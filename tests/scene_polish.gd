extends SceneTree
## v0.52.0 · ClaudeHelper: kalibrierte Posenblätter, Ringe unter den Figuren, freie Türen,
## Bodenspiegelungen und Kino-Vignette.
var checks := 0
var failures := 0
const Dressing = preload("res://scripts/world_dressing.gd")

func _initialize() -> void: run.call_deferred()

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("FAIL: " + message)

## Jede Pose braucht ringsum einen leeren Rand: sonst zeigt sie ein Stück der Nachbarpose
## oder ist selbst abgeschnitten.
func clean_edge(image: Image, rect: Rect2i) -> bool:
	for x in range(rect.position.x, rect.end.x):
		if image.get_pixel(x, rect.position.y).a > 0.1 or image.get_pixel(x, rect.end.y - 1).a > 0.1: return false
	for y in range(rect.position.y, rect.end.y):
		if image.get_pixel(rect.position.x, y).a > 0.1 or image.get_pixel(rect.end.x - 1, y).a > 0.1: return false
	return true

func regions(node: Variant, out: Array) -> Array:
	if node is Dictionary:
		if node.has("region"): out.append(Rect2i(int(node.region[0]), int(node.region[1]), int(node.region[2]), int(node.region[3])))
		else:
			for value in node.values(): regions(value, out)
	elif node is Array:
		for value in node: regions(value, out)
	return out

func atlas_clean(path: String, rects: Array) -> void:
	var image: Image = load(path).get_image()
	if image.is_compressed(): image.decompress()
	var dirty := 0
	for rect: Rect2i in rects:
		if not Rect2i(Vector2i.ZERO, image.get_size()).encloses(rect) or not clean_edge(image, rect): dirty += 1
	check(dirty == 0 and not rects.is_empty(), "%s: %d of %d poses touch their cell edge" % [path.get_file(), dirty, rects.size()])

func grid(path: String, cols: int, rows: int) -> Array:
	var size: Vector2i = load(path).get_size()
	var out: Array = []
	for r in rows:
		for c in cols: out.append(Rect2i(c * size.x / cols, r * size.y / rows, size.x / cols, size.y / rows))
	return out

func run() -> void:
	# 1 · Posenblätter
	atlas_clean("res://assets/sprites/heroes/combat-poses.png", grid("res://assets/sprites/heroes/combat-poses.png", 8, 4))
	for hero in ["heroes/raven", "heroes/shadepi", "npcs/jackal", "npcs/kenzo", "npcs/punk-1", "npcs/punk-2", "npcs/punk-3", "npcs/punk-4", "npcs/shooter-violet", "npcs/shooter-visor"]:
		atlas_clean("res://assets/sprites/%s.png" % hero, grid("res://assets/sprites/%s.png" % hero, 8, 32))
	var contact: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/sprites/npcs/contact-poses.json"))
	atlas_clean("res://assets/sprites/npcs/contact-poses.png", regions(contact, []))
	var attack: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/memories/attack/actors.json"))
	var sheets := {}
	for identity: String in attack:
		for key: String in attack[identity]:
			var sheet := "bots" if identity == "bot" and key != "combat" else {"idle": "warriors-ready", "run_a": "warriors-run", "run_b": "warriors-run", "combat": "combat", "civilian": "residents", "walk_cycle": "residents-walk", "attack": "bots"}[key] as String
			if not sheets.has(sheet): sheets[sheet] = []
			regions(attack[identity][key], sheets[sheet])
	for sheet: String in sheets:
		if sheet == "warriors-run": continue   # enthält eine bewusst verbundene Doppelpose
		atlas_clean("res://assets/memories/attack/%s.png" % sheet, sheets[sheet])
	# 2 · Requisiten stehen nicht vor Türen und Toren
	var doors := {"ambush": [Rect2(104, 150, 126, 150)], "garage": [Rect2(20, 150, 180, 160), Rect2(215, 150, 180, 160), Rect2(420, 150, 165, 160)]}
	for layout: String in doors:
		for item: Array in Dressing.items(layout):
			for door: Rect2 in doors[layout]:
				check(not door.has_point(item[2]), "%s: %s does not stand in front of a door" % [layout, item[0]])
	# 3 · Spiel
	var w = load("res://scenes/campaign.tscn").instantiate()
	root.add_child(w)
	await process_frame
	w.close_menu(); w.started = true
	w.fresh_entry = false
	w._enter(w.Beat.ROOF)
	for i in 30: await process_frame
	var ring: Node = w.get_node_or_null("PixelMarkerLayer")
	var arrows: Node = w.get_node_or_null("PixelMarkerArrows")
	check(ring != null and ring.get_index() < w.actors.get_index() and ring.z_index == 0, "action ring is drawn before the y-sorted actors, so heroes walk over it")
	check(arrows != null and arrows.z_index > 0, "the hovering arrow stays above the actors")
	var mirror: Sprite2D = w.raven.floor_reflection
	check(w.floor_reflection(w.raven.global_position) > 0.5 and mirror.visible, "wet rooftop reflects the hero")
	check(mirror.get_index() < w.raven.cast_shadow.get_index() and absi(mirror.frame - w.raven.visual.frame) <= 1 and mirror.texture == w.raven.visual.texture and mirror.scale.y < 0.0, "reflection mirrors the current hero frame below the body")
	w.set_visual_quality(0)
	check(w.floor_reflection(w.raven.global_position) == 0.0, "reduced picture style switches reflections off")
	w.set_visual_quality(2)
	w._enter(w.Beat.BOSS)
	for i in 5: await process_frame
	check(w.floor_reflection(Vector2(300, 400)) > 0.3 and w.floor_reflection(Vector2(700, 350)) == 0.0, "penthouse marble reflects, the carpet does not")
	w._enter(w.Beat.LAKE)
	for i in 5: await process_frame
	check(w.floor_reflection(w.player.global_position) == 0.0, "grass at the lake does not reflect")
	var lamps := 0
	w._enter(w.Beat.ROOF)
	for i in 5: await process_frame
	for prop in w.actors.get_children():
		if prop.get("kind") == "lamp":
			lamps += 1
			check(prop.lamp_glows.size() == 2 and prop.lamp_glows[0].visible, "street lamp shows a light cone and a floor glow")
			prop.restore_health(0)
			check(not prop.lamp_glows[0].visible and not prop.lamp_glows[1].visible, "a destroyed lamp is dark")
	check(lamps == 2, "rooftop has its two lamps")
	check(w.cutscene.vignette != null and w.cutscene.vignette.get_index() < w.cutscene.overlay.get_index(), "cinema vignette lies below fades, bars and text")
	w.cutscene.bars = 1.0; w.cutscene._layout_bars()
	check(is_equal_approx(w.cutscene.vignette.material.get_shader_parameter("amount"), 1.0), "vignette follows the film bars")
	w.cutscene.bars = 0.0; w.cutscene._layout_bars()
	check(is_equal_approx(w.cutscene.vignette.material.get_shader_parameter("amount"), 0.0), "vignette is gone during play")
	w.queue_free()
	await process_frame
	print("SCENE POLISH: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
