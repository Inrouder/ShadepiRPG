extends SceneTree
## v0.52.0 · ClaudeHelper: findet Kinoszenen, in denen eine Figur durch ein Hindernis läuft.
## Spielt jede Kampagnenszene frisch ab und prüft bei jedem Bild, ob der Fußpunkt einer
## geführten Figur in einem festen Körper (Wand, Möbel, Requisite) steckt.
## godot --headless --script res://tools/story/walk_audit.gd
var hits := {}

func _initialize() -> void:
	run.call_deferred()

func probe(c, tag: String) -> void:
	var space: PhysicsDirectSpaceState2D = c.get_world_2d().direct_space_state
	for actor in [c.player, c.raven]:
		if not is_instance_valid(actor) or not actor.visible or not c.cutscene.walkers.has(actor): continue
		var query := PhysicsPointQueryParameters2D.new()
		query.position = actor.global_position
		query.collision_mask = 1
		for hit in space.intersect_point(query, 4):
			var body: Node2D = hit.collider
			var key := "%s · %s in %s" % [tag, "Shadepi" if actor == c.player else "Raven", body.name if not str(body.name).begins_with("@") else str(Vector2i(body.global_position))]
			if not hits.has(key): hits[key] = [Vector2i(actor.global_position), 0]
			hits[key][1] += 1

func play(c, tag: String) -> void:
	for i in 9000:
		await physics_frame
		if c.cutscene.waiting_input: c.cutscene.advance()
		if c.in_cinematic(): probe(c, tag)
		elif i > 20: return

func run() -> void:
	var c = load("res://scenes/campaign.tscn").instantiate()
	root.add_child(c)
	Engine.time_scale = 6
	await create_timer(0.3).timeout
	c.close_menu(); c.started = true
	for name: String in ["PACT", "AMBUSH", "GARAGE", "HANGAR", "ECHO", "ROOF", "BOSS", "LAKE"]:
		c.fresh_entry = true
		c._enter(c.Beat[name])
		await play(c, name + " Auftakt")
		if name in ["AMBUSH", "BOSS"]: continue
		for step in 6:
			if c.beat != c.Beat[name] or c.in_cinematic(): break
			c._complete_point()
			await play(c, "%s Schritt %d" % [name, step + 1])
	for key: String in hits:
		print("WALK HIT: %s bei %s (%d Bilder)" % [key, hits[key][0], hits[key][1]])
	print("WALK AUDIT: %d Stellen" % hits.size())
	quit()
