extends SceneTree
## v0.32.0 · CodexAI: source transparency and in-world continuity regressions.
const Tableau = preload("res://scripts/sanctuary_tableau.gd")
var checks := 0
var failures := 0

func _initialize() -> void: run.call_deferred()

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("FAIL: " + message)

func opaque_bounds(image: Image, rect: Rect2i) -> Rect2:
	var lo := Vector2(INF, INF)
	var hi := Vector2(-INF, -INF)
	for y in range(rect.position.y, rect.end.y):
		for x in range(rect.position.x, rect.end.x):
			if image.get_pixel(x, y).a < 0.7: continue
			lo = lo.min(Vector2(x, y))
			hi = hi.max(Vector2(x + 1, y + 1))
	return Rect2(lo, hi - lo)

func plate_center(image: Image) -> Vector2:
	var total := Vector2.ZERO
	var count := 0
	for y in range(485, 508):
		for x in image.get_width():
			var c := image.get_pixel(x, y)
			if c.a > 0.7 and c.g > 0.27 and c.b > 0.22 and c.r < 0.3:
				total += Vector2(x, y)
				count += 1
	return total / maxf(1, count)

func run() -> void:
	var t := Tableau.new()
	root.add_child(t)
	var hero := PixelActor.new()
	hero.setup(preload("res://assets/sprites/heroes/raven.png"), null)
	root.add_child(hero)
	check(t.sprite.texture_filter == hero.visual.texture_filter, "special poses and normal heroes have identical sampling at gameplay scale")
	check(t.sprite.material == null, "transparent source edges are not forced opaque by the old cutout shader")
	var original := hero.visual.texture.get_image()
	var normal_height := opaque_bounds(original, Rect2i(Vector2i.ZERO, original.get_size())).size.y * hero.visual.scale.y
	var source := t.ART.get_image()
	check(source.get_pixel(0, 0).a == 0.0 and source.get_pixel(source.get_width() - 1, 0).a == 0.0, "atlas background is truly transparent instead of the former gray alpha matte")
	var first_plate := Vector2.ZERO
	for index in 6:
		t.set_pose(index)
		var atlas := t.sprite.texture as AtlasTexture
		var image := source.get_region(Rect2i(atlas.region))
		var bounds := opaque_bounds(image, Rect2i(Vector2i.ZERO, image.get_size()))
		check(bounds.has_area() and bounds.position.x > 0 and bounds.end.x < image.get_width(), "pose %d retains complete hair, clothing and boots inside its own region" % index)
		if index < 3:
			var center := t.to_global((plate_center(image) - t.ANCHORS[index]) * t.sprite.scale)
			if index == 0: first_plate = center
			else: check(center.distance_to(first_plate) < 1.5, "chair footplate stays fixed when switching to contact pose %d" % index)
		if index in [1, 2]:
			var feet := opaque_bounds(image, Rect2i(345, 480, 130, 30)).get_center()
			var feet_world := t.to_global((feet - t.ANCHORS[index]) * t.sprite.scale)
			check(feet_world.distance_to(t.APPROACH) < 5.0, "Raven does not jump forward from her approach position into contact pose %d" % index)
			var body := opaque_bounds(image, Rect2i(310, 75, 165, 435))
			check(absf(body.size.y * t.sprite.scale.y - normal_height) < 8.0, "Raven's contact body remains within the normal hero size range")
		if index == 4:
			check(absf(bounds.size.x * t.sprite.scale.x - normal_height) < 9.0, "sleeping Raven retains the normal body's scale rather than growing on the bed")
			check(bounds.size.x > 2.8 * bounds.size.y, "sleep is a fully horizontal, curled pose")
	t.set_pose(2)
	t.transfer_step(0.5)
	t.set_pose(0)
	check(t.sprite.modulate == Color.WHITE and not t.flow.visible and t.transfer_power == 0.0, "re-entering a pose clears the transfer flash, beam and power together")
	hero.free()
	t.free()
	print("SANCTUARY ART: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
