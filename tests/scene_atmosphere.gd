extends SceneTree
## v0.31.0 · CodexAI: scene selection, clipping, pause and bounded rendering.
const Atmosphere = preload("res://scripts/scene_atmosphere.gd")
const Profiles = preload("res://scripts/atmosphere_profiles.gd")
var checks := 0
var failures := 0
class Fixture extends Node2D:
	var key := "hangar"
	var area := Rect2(0,0,1024,640)
	var menu_open := false
	var terminal: Node
	var memory_scene: Node
	var closed := false
	var filter_material: ShaderMaterial
	func atmosphere_profile() -> String: return key
	func atmosphere_rect() -> Rect2: return area
func _initialize() -> void: run.call_deferred()
func check(ok: bool, text: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("FAIL: " + text)
func inside_or_edge(point: Vector2, polygon: PackedVector2Array) -> bool:
	if Geometry2D.is_point_in_polygon(point,polygon): return true
	# Polygon clipping quantizes boundary vertices; tolerate sub-pixel roundoff only.
	for i in polygon.size():
		if point.distance_to(Geometry2D.get_closest_point_to_segment(point,polygon[i],polygon[(i+1)%polygon.size()])) < 0.02: return true
	return false
func run() -> void:
	var fixture := Fixture.new()
	fixture.filter_material = ShaderMaterial.new()
	fixture.filter_material.shader = preload("res://shaders/atmosphere.gdshader")
	root.add_child(fixture)
	var fx = Atmosphere.new()
	fx.world = fixture
	fixture.add_child(fx)
	fx.set_process(false)
	for key in Profiles.KEYS:
		fixture.key = key
		fx.sync_profile()
		fx.set_quality(2)
		check(fx.profile_key == key and not fx.settings.is_empty(), "environment profile exists: " + key)
		check(fx.settings.get("motes",0) <= 28 and fx.settings.get("packets",0) <= 12, "ambient draw budget is bounded: " + key)
		fx._process(0.5)
		check(is_equal_approx(fx.elapsed,0.5), "environment runs during calm scenes: " + key)
		fx.set_quality(0)
		fx._process(2.0)
		check(is_equal_approx(fx.elapsed,0.5) and fx.amount(28) == 0, "reduced style disables optional motion: " + key)
		fx.set_quality(1)
		check(fx.amount(28) < 28 and fx.amount(28) > 0, "balanced style reduces density: " + key)
	fixture.key = "hangar"
	fx.sync_profile()
	fx.set_quality(2)
	for reason in ["menu_open","terminal","memory_scene","closed"]:
		var marker: Node
		if reason in ["terminal","memory_scene"]:
			marker = Node.new()
			fixture.add_child(marker)
			fixture.set(reason,marker)
		else: fixture.set(reason,true)
		var time: float = fx.elapsed
		fx._process(1.0)
		check(fx.elapsed == time, "environment freezes for " + reason)
		fixture.set(reason,null if marker != null else false)
		if marker != null: marker.queue_free()
	fixture.area = Rect2(230,120,563.2,352)
	fx.sync_profile()
	check(fx.position == fixture.area.position and fx.scale.is_equal_approx(Vector2.ONE*0.55), "compact rooms use exactly the background transform")
	fixture.area = Rect2(0,0,1024,640)
	fixture.key = "lakeside"
	fx.sync_profile()
	check(fx.water != null and fx.water.get_child_count() > 0 and fx.water.z_index == 0, "water is an independent background layer")
	for polygon in fx.water.get_children():
		for point: Vector2 in polygon.polygon:
			check(point.y >= 211.99 and inside_or_edge(point,PackedVector2Array(fx.Painted.WATER_EDGE)), "water texture is clipped below the tree line and inside the shoreline")
		for point in [Vector2(615,390),Vector2(655,400),Vector2(735,440)]:
			check(not Geometry2D.is_point_in_polygon(point,polygon.polygon), "ritual shore stays outside animated water")
	fx.set_quality(0)
	check(not fx.water.visible, "reduced style restores the untouched water background")
	fx.set_quality(2)
	fx._process(0.7)
	fixture.menu_open = true
	var water_clock: Variant = fx.water_material.get_shader_parameter("clock")
	fx._process(1.0)
	check(fx.water_material.get_shader_parameter("clock") == water_clock, "pause freezes the water shader as well as particles")
	fixture.menu_open = false
	seed(731)
	var expected := randf()
	seed(731)
	fx._process(0.3)
	check(is_equal_approx(randf(),expected), "decorative animation never consumes gameplay random state")
	fixture.key = ""
	fx.sync_profile()
	check(fx.settings.is_empty() and fx.water == null, "leaving the lake clears its surface and all scene-specific emitters")
	fx.set_quality(1)
	fixture.key = "lakeside"
	fx.sync_profile()
	check(is_equal_approx(fx.water_material.get_shader_parameter("strength"),0.35), "entering the lake directly in balanced style uses its reduced water motion")
	fixture.queue_free()
	await process_frame
	var w = load("res://scenes/campaign.tscn").instantiate()
	root.add_child(w)
	w._enter(w.Beat.ECHO,0,0,false,false,false,false,2)
	w.scene_atmosphere.sync_profile()
	check(w.scene_atmosphere.profile_key == "compensator" and w.scene_atmosphere.position == w.Painted.CHAMBER_RECT.position, "campaign selects the actual compensator room")
	var feet: Vector2 = w.raven.position
	var sprite_point: Vector2 = w.raven.visual.position
	var sprite_scale: Vector2 = w.raven.visual.scale
	w.scene_atmosphere._process(3.0)
	check(w.raven.position == feet and w.raven.visual.position == sprite_point and w.raven.visual.scale == sprite_scale, "atmosphere never shifts or deforms characters")
	w.menu_open = true
	var rain_clock: float = w.effects.elapsed
	w.effects._process(5)
	check(w.effects.elapsed == rain_clock, "existing rain and steam also freeze when paused")
	w.menu_open = false
	w._enter(w.Beat.END)
	w.scene_atmosphere.sync_profile()
	check(w.scene_atmosphere.profile_key == "lakeside" and w.scene_atmosphere.get_index() < w.actors.get_index(), "lake surface is drawn before actors, preserving their silhouettes")
	w._enter(w.Beat.CHASE)
	w.scene_atmosphere.sync_profile()
	check(w.scene_atmosphere.settings.is_empty(), "vehicle scenes retain their own existing weather renderer")
	w.queue_free()
	await process_frame
	for name in ["attack","sacrifice","legacy"]:
		var scene = load("res://scenes/memories/" + name + ".tscn").instantiate()
		scene.autoplay = false
		root.add_child(scene)
		check(scene.scene_atmosphere.profile_key == {"attack":"memory_attack","sacrifice":"memory_sacrifice","legacy":"memory_temple"}[name], "memory chooses its real setting: " + name)
		scene.toggle_pause()
		var time: float = scene.scene_atmosphere.elapsed
		scene.scene_atmosphere._process(3)
		check(scene.scene_atmosphere.elapsed == time, "memory pause freezes ash and embers: " + name)
		scene.queue_free()
		await process_frame
	print("SCENE ATMOSPHERE: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
